local cm = require(ENGINE_PATH)
local OS = require("frontend/OS")
local selection = require("frontend/selectMenu")
local key = "bc51d144ab1bf6e34b67686425f524c9b2582c63"
local R_IN = love.thread.getChannel("webRequestIN")
local R_OUT = love.thread.getChannel("webRequestOUT")
local W_IN = love.thread.getChannel("webDownloadIN")
local W_OUT = love.thread.getChannel("webRequestOUT")
local webRequest = love.thread.newThread("frontend/webRequest.lua")
webRequest:start()
local json = require("frontend/json")

local cfg = require("frontend/config")
local sw,sh = love.window.getDimensions()
local layer = cm.layer.new()
local color_bg, color1, color2 = cfg.bgColor, cfg.color1, cfg.color2
love.graphics.setBackgroundColor(unpack(color_bg))

local sFont = cfg.font[2]
local sFont2 = cfg.font[3]
local sFont3 = cfg.font[1]
local status = cm.sprite.new(sh*0.1,sh*0.1,sFont,"")
status:setTint(unpack(color1))
local status2 = cm.sprite.new(sh*0.20,sh*0.20,sFont3,"")
local r,g,b = unpack(color2)
status2:setTint(r,g,b,128)
status2:center()
layer:insertSprite(status)
local box = cm.sourceRectangle.new()
local r,g,b = unpack(color1)
local bar_under = cm.sprite.new(sh*0.2,sh-sh*0.2,box,{sw-sh*0.4,20})
bar_under:setTint(r,g,b,60)
local bar = cm.sprite.new(sh*0.2,sh-sh*0.2,box,{sw-sh*0.4,20})
bar:setTint(r,g,b)

layer:insertSprite(bar_under)
layer:insertSprite(bar)


local romNames = cm.serialize.load("romnames.lua") or {}

local database = cm.serialize.load("game_database.lua") or {games={},genres={},developers={},years={},platforms={}}
local cfg = cm.serialize.load("emuConf.lua") or error("No emulation configuration found")
local searches ={}
local queries = {}
local downloads = {}

local function dbRef(type,entry) --count values for database
    if database[type][entry] then
        database[type][entry] = database[type][entry]+1
    else
        database[type][entry] = 1
    end
end

local function clearFilename(name)
    name = name:gsub("%..?.?.?.?$","")
    if romNames[name] then name = romNames[name] end
    name = name:gsub("%s%(.+%)","") --remove good-tool tags
    name = name:gsub("%s%[.+%]","") --remove good-tool tags
    return name
end

local function loadScreen(func)
    local layer = cm.layer.new()
    local sprite = cm.sprite.new(sw/2,sh/2,cm.sourceImage.new("assets/loading.png"))
    sprite:setTint(unpack(color2))
    sprite:center()
    layer:insertSprite(sprite)
    while not func() do
        cm.thread.waitThread(sprite:moveRot(math.rad(-90),0.125))
    end
    cm.layer.remove(layer)
end

local function queryDatabase(ressourceType,ressourceID,fields_string)
    cm.thread.new(function()
        local queryString = "http://www.giantbomb.com/api/"..ressourceType.."/"..ressourceID.."/?api_key="..key.."&format=json"
        if fields_string then queryString = queryString.."&field_list="..fields_string end
        R_IN:push(queryString)
        if webRequest:getError() then error(webRequest:getError()) end
        local result
        print("Getting Information for "..ressourceType.." ID:"..ressourceID)
        local wait = true
        while wait do
            cm.thread.yield()
            result = R_OUT:peek()
            if result then
                if result[1] == queryString then R_OUT:pop() wait=false end
            end
        end
        local decoded = json.decode(result[2])
        if not decoded then error("Your web request didn't return json: "..queryString.." "..result[2]) end
        if decoded.error ~= "OK" then error("Search \""..queryString.."\" returned: "..decoded.error) end
        queries[ressourceType..ressourceID] = decoded.results
    end):run()
end

local function download(url,filename)
    cm.thread.new(function()
        W_IN:push({url,filename})
        if webRequest:getError() then error(webRequest:getError()) end
        local result
        print("Downloading: "..url)
        local wait = true
        while wait do
            cm.thread.yield()
            result = W_OUT:peek()
            if result == filename then W_OUT:pop() wait = false end
        end
        downloads[filename] = true
        print("Download finished: "..filename)
    end):run()
end

local function searchGame(name,platform)
    cm.thread.new(function()
        local filename = name
        name = clearFilename(name)
        local webname = name:gsub("%s","%%20") --replace space with %20
        local queryString = "http://www.giantbomb.com/api/search/?api_key="..key.."&format=json&query=\""..webname.."\"&resources=game&field_list=name,id,platforms,original_release_date,deck"
        R_IN:push(queryString)
        if webRequest:getError() then error(webRequest:getError()) end
        local result
        print("Searching for game: "..name)
        local wait = true
        while wait do
            cm.thread.yield()
            result = R_OUT:peek()
            if result then
                if result[1] == queryString then R_OUT:pop() wait=false end
            end
        end
        local decoded = json.decode(result[2])
        if not decoded then error("Your web request didn't return json: "..queryString) end
        if decoded.error ~= "OK" then error(decoded.error) end
        if not decoded.number_of_total_results then print(result[2]) end
        local result = decoded.results
        local resultTable = {}
        for _,entry in pairs(result) do
            local game = {}
            local add = false
            if entry.platforms then
                local platforms = {}
                for i,v in ipairs(entry.platforms) do
                    if v.name == platform then add = true end
                end
            else
                add = true
            end
            if add then
                game.platform = {platform}
                game.name = entry.name
                game.id = entry.id
                if entry.deck then game.description = entry.deck else game.description = entry.name end
                if entry.original_release_date then game.year = string.sub(entry.original_release_date,1,4) else game.year = 0 end
                dbRef("years",game.year)
                dbRef("platforms",platform)
                table.insert(resultTable,game)
            end
        end

        print("Found "..#resultTable.." matching game(s).")
        searches[filename] = resultTable
    end):run()
end

local scene = {}

function scene:onLoad()
    local function addGame(name,platform,disambiguate)
        --check Database
        local existing = cm.data.filter( database.games,{filename={cm.data.equals,name}} )
        --print(#existing)
        if #existing > 0 then
            print(name.." for "..platform.." is already in database")
            return
        end
        --Search the game
        local foundGame
        searchGame(name,platform)

        --Show a loading screen
        status:setIndex(name..": Searching for Game.")
        loadScreen(function() return searches[name] end)

        --Handle matches
        if #searches[name] == 0 then --no matches
            local screenName = clearFilename(name)
            foundGame = {name=screenName,filename={name},platform={platform},image="NOIMG.png",year=0,id=0,description=screenName,genres={}}
        elseif #searches[name] == 1 then
            foundGame = searches[name][1]
        else
            --Filter results
            local screenName = clearFilename(name)
            local filteredByExactName = cm.data.filter(searches[name],{name={cm.data.equals,screenName}})
            --Choose match
            if #filteredByExactName == 1 or #searches[name] == 1 then
                foundGame = filteredByExactName[1]
            else
                if disambiguate then
                    local resultID
                    local options = {}
                    for i,v in ipairs(searches[name]) do
                        table.insert(options,v.name..": "..v.year)
                    end
                    resultID = selection(name,options)
                    if resultID == 0 then
                        foundGame = {name=screenName,filename={name},platform={platform},image="NOIMG.png",year=0,id=0,description=screenName,genres={}}
                    else
                        foundGame = searches[name][resultID]
                    end
                else
                    return name
                end
            end
        end

        --delete results
        searches[name] = nil

        --check if game exists already for another platform
        local existing = cm.data.filter( database.games,{name={cm.data.equals,foundGame.name}} )
        if #existing > 0 then
            table.insert(existing[1].platform,platform)
            table.insert(existing[1].filename,name)
            print("Adding another release for "..existing[1].name)
            return
        end

        --get further information for found game (if game was found)
        if foundGame.id ~= 0 then
            print("Getting more information for "..foundGame.name..".")
            queryDatabase("game",foundGame.id,"developers,genres,image,reviews,aliases")

            --Show a loading screen
            status:setIndex(name..": Getting more Information.")
            loadScreen(function() return queries["game"..foundGame.id] end)

            --getInformation
            local details = queries["game"..foundGame.id]

            if details.aliases then
                if type(details.aliases) == "table" then
                    foundGame.aliases = {}
                    for i,v in pairs(details.aliases) do
                        table.insert(foundGame.aliases,v.name)
                    end
                else
                    foundGame.aliases = {details.aliases }
                end
            end
            if details.developers then
                if type(details.developers) == "table" then
                    foundGame.developers = {}
                    for i,v in pairs(details.developers) do
                        table.insert(foundGame.developers,v.name)
                        dbRef("developers",v.name)
                    end
                else
                    foundGame.developers = {details.developers }
                    dbRef("developers",details.developers)
                end
            end
            if details.genres then
                if type(details.genres) == "table" then
                    foundGame.genres = {}
                    for i,v in pairs(details.genres) do
                        table.insert(foundGame.genres,v.name)
                        dbRef("genres",v.name)
                    end
                else
                    foundGame.genres = {details.genres }
                    dbRef("genres",details.genres)
                end
            end

            --download image
            if not love.filesystem.exists(foundGame.id..".jpg") and not love.filesystem.exists(foundGame.id..".png") then
                if details.image then
                    if details.image.super_url then
                        local _,_,format = string.match(details.image.super_url, "(.-)([^\\]-([^%.]+))$")

                        download(details.image.super_url,foundGame.id.."."..format)

                        --show loading screen
                        status:setIndex(name..": Downloading art.")
                        loadScreen(function() return downloads[foundGame.id.."."..format] end)

                        --register image
                        foundGame.image = foundGame.id.."."..format
                        downloads[foundGame.id.."."..format] = nil
                    else
                        foundGame.image = "NOIMG.png"
                    end
                else
                    foundGame.image = "NOIMG.png"
                end
            else
                if love.filesystem.exists(foundGame.id..".jpg") then foundGame.image=foundGame.id..".jpg" end
                if love.filesystem.exists(foundGame.id..".png") then foundGame.image=foundGame.id..".png" end
            end
            --delete detail query
            queries["game"..foundGame.id] = nil
        end

        --add found game to database
        foundGame.filename = {name}
        table.insert(database.games,foundGame)
        return true
    end
    --------------------------------------------------------------------------------------------------
    local update
    layer:insertSprite(status)
    layer:insertSprite(status2)

    --get all filenames
    status:setIndex("Collecting filenames...")
    local filenames = {}
    local excludedNames = cm.serialize.load("excludedGames.lua") or {}
    for platformName, platform in pairs(cfg) do
        local pc = 0
        if platform.romPath then
            filenames[platformName] = {}
            for _,file in OS.getFolderContents(platform.romPath) do
                if not excludedNames[file] then
                    local extension = file:match(".-%.(..?.?.)$")
                    for ext in platform.extensions:gmatch("[^%s]+") do
                        if ext == "DIR" and not extension then filenames[platformName][file.." "] = true end
                        if ext == extension then filenames[platformName][file] = true end
                    end
                end
            end
        else
            filenames[platformName] = {}
            --pc games
        end
    end

    --check database
    status:setIndex("Updating database...")
    local remove = {}
    for i=1, #database.games do
        if not database.games[i] then --clear fake entries
            table.remove(database.games,i)
        else
            for j=1, #database.games[i].filename do --check files
                local platform = database.games[i].platform[j]
                local filename = database.games[i].filename[j]
                if filename == nil then --clear fake entries
                    table.remove(database.games[i].platform, j)
                    table.remove(database.games[i].filename, j)
                    break
                end
                if not filenames[platform] then cm.thread.wait(5) error("No configuration for platform \""..platform.."\" found. (But games in database)") end
                if filenames[platform][filename] then
                    filenames[platform][filename] = nil --file already in databse, remove from new files
                else -- file not present anymore remove
                    update = true
                    status:setIndex("Removing "..filename)
                    cm.thread.wait(0.1)
                    table.remove(database.games[i].platform, j)
                    table.remove(database.games[i].filename, j)
                end
            end
        end
    end

    --collecting games to add
     local amount = {}
     local roms = 0
     local str = ""
     for name, files in pairs(filenames) do
         amount[name] = 0
         str = str..name..": "
         for file in pairs(files) do
             amount[name] = amount[name] + 1
             roms = roms +1
         end
         str = str..amount[name].."\r\n"
     end

     --init
    status2:setIndex(str)
    bar:setSca(0,1)

    --count roms
    local currentRom = 0

    if roms > 0 then
        local choice = selection("Found "..roms.." new games. Add to database?",{"Yes","No"})
        if choice == 1 then
            update = true
        --searching for games
            local later = {}
            for platform,files in pairs(filenames) do
                for file in pairs(files) do
                    local result = addGame(file, platform)
                    if type(result) == "string" then
                        print("Storing for disambiguation")
                        table.insert(later, {result,platform})
                    else
                        currentRom = currentRom+1
                        bar:setSca(currentRom/roms,1)
                    end
                end
            end

            --disambiguation
            for _,data in ipairs(later) do
                addGame(data[1], data[2],true)
                currentRom = currentRom+1
                bar:setSca(currentRom/roms,1)
            end
            --serializing data
        end
    end
    if update then
        --make backup
        local backup = cm.serialize.load("game_database.lua")
        cm.serialize.save(backup,"game_database.bak")
        cm.serialize.save(database,"game_database.lua")
    end
    status:setIndex("Finished building rom database")
    self:stop()
end

function scene:onUpdate()

end

function scene:onStop()
    print(stop)
    cm.layer.clearAll()
end

return scene