local OS = require("frontend/OS")
local cfg = require("frontend/config")
local bLeft, bRight, bStart = cine.input.getVirtualInput("Left"),cine.input.getVirtualInput("Right"),cine.input.getVirtualInput("Start")
local scene = {}

local sw,sh = love.window.getDimensions()

--I. General definitions and asset loading

local color_bg, color1, color2 = cfg.bgColor, cfg.color1, cfg.color2
love.graphics.setBackgroundColor(unpack(color_bg))

local sFont = cfg.font[2]
local sFont2 = cfg.font[3]
local sFont3 = cfg.font[1]
local sFont4 = cfg.font[4]
local sSidebar = cine.sourceImage.new("frontend/sidebar.png")
local sArrow = cine.sourceImage.new("frontend/arrow.png")
local id = love.image.newImageData(1,2)
id:setPixel(0,0,255,255,255,0)
id:setPixel(0,1,255,255,255,255)
local gSource = cine.sourceImage.new(id)

local selection = require("frontend/selectMenu")
local menu = require("frontend/menu")
local reset
local selector

--Ia. Data
local filter =
{
    --platform={cine.data.equals,"Arcade"},
    --genres={cine.data.equals,"Alex" }
}
local database = cine.serialize.load("game_database.lua")


-- III.Sidebars
local sidebarLayer = cine.layer.new()
sidebarLayer:setZIndex(2)
local sidebarTextLayer = cine.layer.new()
sidebarTextLayer:setZIndex(3)

local gradient_l = cine.sprite.new(-0.38*sh,sh*0.38,gSource)
gradient_l:center("left","bottom")
gradient_l:setSca(sh*0.62,sh*0.25)
gradient_l:setRot(math.rad(90))
sidebarLayer:insertSprite(gradient_l)

local sidebar_l = cine.sprite.new(sh*0.17,sh*0.52,sSidebar)
sidebar_l:setTint(unpack(color1))
sidebar_l:setSca(sh*0.35/sSidebar:getImage():getHeight())
sidebar_l:center("right","top")
sidebar_l:setTweenStyle("easeout")
sidebarLayer:insertSprite(sidebar_l)

local optionsText = cine.sprite.new(sh*0.13,sh*0.69,sFont, " Options")
optionsText:setTint(unpack(color_bg))
optionsText:setRot(math.rad(90))
optionsText:center()
sidebarLayer:insertSprite(optionsText)

local optionsArrow = cine.sprite.new(sh*0.07, sh*0.69,sArrow)
optionsArrow:center()
optionsArrow:setTint(unpack(color_bg))
optionsArrow:setSca(sh*0.10/sArrow:getImage():getHeight())
sidebarLayer:insertSprite(optionsArrow)

local optionsMenu = menu.new(sFont)
local l = optionsMenu:getLayer()
local _,top,_,bottom = sidebar_l:getBBox()
l:setViewport(0,top,sw,bottom)
optionsMenu:addItem("Show all",function()
    filter = {}
    selector:setIndex(1)
    reset=true
end)
optionsMenu:addItem("Show favourites",function()
    filter = { favourite={cine.data.isTrue} }
    selector:setIndex(1)
    reset=true
end)
optionsMenu:addItem("Show platform",function()
    local platforms = {}
    for name, amount in pairs(database.platforms) do
        table.insert(platforms,name)
    end
    local choice = selection("Select platform",platforms)
    if choice ~= 0 then
        filter = { platform={cine.data.equals,platforms[choice]} }
        selector:setIndex(1)
        reset=true
    end
end)
optionsMenu:addItem("Show genre",function()
    local genres = {}
    for name, amount in pairs(database.genres) do table.insert(genres,{name=name,amount=amount}) end
    table.sort(genres,function(a,b) return a.amount>b.amount end)
    local sortedGenres = {}
    for i=1, math.min(17,#genres) do sortedGenres[i] = genres[i].name end
    local choice = selection("Select genre",sortedGenres)
    if choice ~= 0 then
        filter = { genres={cine.data.equals,sortedGenres[choice]} }
        selector:setIndex(1)
        reset=true
    end
end)
optionsMenu:addItem("Show developer",function()
    local developers = {}
    for name, amount in pairs(database.developers) do table.insert(developers,{name=name,amount=amount}) end
    table.sort(developers,function(a,b) return a.amount>b.amount end)
    local sortedDevelopers = {}
    for i=1, math.min(17,#developers) do sortedDevelopers[i] = developers[i].name end
    local choice = selection("Select developer",sortedDevelopers)
    if choice ~= 0 then
        filter = { developers={cine.data.equals,sortedDevelopers[choice]} }
        selector:setIndex(1)
        reset=true
    end
end)
optionsMenu:setPos(-sh*0.45,sh*0.6)
local c = optionsMenu:getCam()
sidebar_l:setAttributeLink(c,"pos_x",nil,function(a,b) return -a+b end)

local sidebar_r = cine.sprite.new(sw-sh*0.17,sh*0.52,sSidebar)
sidebar_r:setTint(unpack(color2))
sidebar_r:center("right","bottom")
sidebar_r:setTweenStyle("easeout")
sidebar_r:setSca(-sh*0.35/sSidebar:getImage():getHeight())
sidebarLayer:insertSprite(sidebar_r)

local infoText = cine.sprite.new(sw-sh*0.13,sh*0.69,sFont," Info")
infoText:setTint(unpack(color_bg))
infoText:setRot(math.rad(90))
infoText:center()
sidebarLayer:insertSprite(infoText)

local infoArrow = cine.sprite.new(sw-sh*0.07, sh*0.69,sArrow)
infoArrow:center()
infoArrow:setTint(unpack(color_bg))
infoArrow:setSca(-sh*0.10/sArrow:getImage():getHeight())
sidebarLayer:insertSprite(infoArrow)

local textDescription = cine.sprite.new(sw,sh*0.52+sFont3:getLineHeight(),sFont3,"No games available")
textDescription:setTint(unpack(color_bg))
sidebarTextLayer:insertSprite(textDescription)

--initialize your scene here

sidebar_l:setChild(optionsArrow)
sidebar_l:setChild(optionsText)
sidebar_l:setChild(gradient_l)

local aOpen = love.audio.newSource("frontend/sounds/open.wav", "static")
local aClose = love.audio.newSource("frontend/sounds/close.wav", "static")

local sidebar_l_out = false
local function sidebar_l_scroll()
    local scax,scay = optionsArrow:getSca()
    local x,_ = sidebar_l:getPos()
    local w,_ = sidebar_l:getSize()
    local scax = sidebar_l:getSca()
    if sidebar_l_out then
        aClose:play()
        sidebar_l:movePosTo(sh*0.17, sh*0.52,0.5)
    else
        aOpen:play()
        sidebar_l:movePos(w*scax-x,0,0.5)
    end
    sidebar_l_out = not sidebar_l_out
end

sidebar_r:setChild(infoArrow)
sidebar_r:setChild(infoText)
sidebar_r:setChild(textDescription)

local sidebar_r_out = false
local function sidebar_r_scroll()
    local scax,scay = infoArrow:getSca()
    local x,_ = sidebar_r:getPos()
    local w,_ = sidebar_r:getSize()
    local scax = sidebar_r:getSca()
    if sidebar_r_out then
        aClose:play()
        sidebar_r:movePosTo(sw-sh*0.17,sh*0.52,0.5)
    else
        aOpen:play()
        sidebar_r:movePos((w*scax)+sh*0.17,0,0.5)
    end
    sidebar_r_out = not sidebar_r_out
end

sidebar_l:registerEvent("onClicked",sidebar_l_scroll)
sidebar_r:registerEvent("onClicked",sidebar_r_scroll)

local _,top,_,bottom = sidebar_l:getBBox()
sidebarTextLayer:setViewport(0,top,sw,bottom)

-- IV. Art Layer
local artLayer = cine.layer.new()
artLayer:setZIndex(4)
artLayer:setViewport(0,0,sw,sh*0.38)

local artSprite

-- V. Title
local titleGradient = cine.sprite.new(0,sh*0.38,gSource)
titleGradient:setTint(0,0,0,128)
titleGradient:center("left","bottom")
titleGradient:setSca(sw,(sh*0.38)/10)
titleGradient:setZIndex(3)
artLayer:insertSprite(titleGradient)
local bgGradient = cine.sprite.new(0,sh*0.38,gSource)
bgGradient:setTint(0,0,0,128)
bgGradient:center("left","bottom")
bgGradient:setSca(sw,(sh*0.38)/3)
bgGradient:setZIndex(3)
artLayer:insertSprite(bgGradient)

local titleText = cine.sprite.new(sh*0.11,sh*0.38,sFont4,"No game available")
titleText:center("left","bottom")
titleText:setZIndex(4)
artLayer:insertSprite(titleText)

local sourceLogo = cine.sourceTileset.new("frontend/logos.png",128)
local logo = cine.sprite.new(sw-sh*0.11,sh*0.38,sourceLogo,1)
logo:setZIndex(5)
logo:center("right","bottom")
artLayer:insertSprite(logo)

-- VI. Updating the frontend

local myData

local function updateSelector(currentIndex)
    local currentItem = myData[currentIndex]
    local name = myData[currentIndex].name--:len() < 23 and myData[currentIndex].name or string.sub(myData[currentIndex].name,1,17).."..."
    titleText:setIndex(name)
    local platform
    if #myData[currentIndex].platform == 0 then
        platform = "No"
    elseif #myData[currentIndex].platform > 1 then
        platform = myData[currentIndex].platform[1]
        for i=2, #myData[currentIndex].platform do
            if myData[currentIndex].platform[i] ~= platform then
                platform = "Multi"
            end
        end
    end
    if not platform then  platform = myData[currentIndex].platform[1] end
    if platform == "Super Nintendo Entertainment System" then logo:setIndex(1)
    elseif  platform == "Neo Geo" then logo:setIndex(2)
    elseif  platform == "Genesis" then logo:setIndex(3)
    elseif  platform == "Nintendo Entertainment System" then logo:setIndex(4)
    elseif  platform == "Arcade" then logo:setIndex(5)
    elseif  platform == "Sega Master System" then logo:setIndex(6)
    elseif  platform == "TurboGrafx-16" then logo:setIndex(7)
    elseif  platform == "PlayStation" then logo:setIndex(8)
    elseif  platform == "PC" then logo:setIndex(9)
    elseif  platform == "Multi" then logo:setIndex(10)
    elseif  platform == "No" then logo:setIndex(11)
    end
    local newImg = currentIndex
    cine.thread.new(function()
        cine.thread.wait(0.25)
        if selector:getIndex() ~= newImg then return end
        local sourceArt = love.filesystem.exists(myData[currentIndex].image) and cine.sourceImage.new(myData[currentIndex].image) or cine.sourceImage.new("NOIMG.png")
        local sprite = cine.sprite.new(0,0)
        if artSprite then artSprite:setZIndex(1) end
        sprite:setZIndex(2)
        sprite:setSource(sourceArt)
        local aw,_ = sourceArt:getSize()
        sprite:moveScaTo(sw/aw)
        sprite:setTweenStyle("easeout")
        sprite:setPos(0,0)
        --sprite:center("left","top")
        local _,y1,_,y2 = sprite:getBBox()
        local delta = (y2-y1) - (sh*0.38)
        sprite:movePos(0,-delta,delta/40)
        sprite:setTint(255,255,255,0)
        artLayer:insertSprite(sprite)
        cine.thread.yield()
        cine.thread.waitThread(sprite:moveTint(0,0,0,255,0.5))
        if artSprite then artLayer:removeSprite(artSprite) end
        artSprite = sprite
    end):run()
    textDescription:setPos(sw,sh*0.52+sFont3:getLineHeight())
    local description = myData[currentIndex].description
    if myData[currentIndex].year ~= 0 then description = description.."\r\nYear: "..myData[currentIndex].year end
    if myData[currentIndex].genres then
        if #myData[currentIndex].genres > 0 then
            description = description.."\r\nGenres: "
            for i,v in pairs(myData[currentIndex].genres) do
                description = description..v..", "
            end
            description = description:sub(1,-3)
        end
    end
    textDescription:setIndex(description)
    local w = sidebar_r:getSize()
    local scax = math.abs(sidebar_r:getSca())
    local textW = w*scax-sh*0.17-sw*0.05
    local _,th = sFont3:getSize(description,textW)
    textDescription:setSize(textW,th)
    local _,y1,_,y2 = sidebar_r:getBBox()
    local sidebarH = (y2-y1)-sFont3:getLineHeight()
    if th > sidebarH then
        textDescription:movePos(0,-(th-sidebarH),(th-sidebarH)/17)
    end
end


local function buildSelector()
    database = cine.serialize.load("game_database.lua") or {}
    --print("Games in Database:"..#database.games)
    myData = database.games or {}
    myData = cine.data.filter(myData,filter)
    table.sort(myData,function(a,b) return tostring(a.name)<tostring(b.name) end)
    selector = menu.new(sFont)
    selector:setPos(sh*0.21,sh*0.62)
    selector:setColor(unpack(color2))

    for i=1, #myData do
        selector:addItem(myData[i].name,function() --enter key
            if #myData[i].platform == 0 then
                local choice = selection("No file to run. Delete from Database?",{"Yes","No"})
                if choice == 1 then
                    local id = cine.data.find(database.games,{name={cine.data.equals,myData[i].name}})
                    table.remove(database.games,id)
                    cine.serialize.save(database,"game_database.lua")
                    reset = true
                end
            elseif #myData[i].platform == 1 then
                OS.runEmulator(myData[i].platform[1],myData[i].filename[1])
            else
                local choice = selection("Select platform",myData[i].platform)
                if choice ~= 0 then OS.runEmulator(myData[i].platform[choice],myData[i].filename[choice]) end
            end
        end,
        function() --options key
            local options = {"Delete from database","Delete from disk" }
            if myData[i].favourite then table.insert(options,1,"Remove from favourites")
            else table.insert(options,1,"Add to favourites")
            end
            local choice = selection("Game options",options)
            if choice == 2 or choice == 3 then
                local excluded = cine.serialize.load("excludedGames.lua") or {}
                local id = cine.data.find(database.games,{name={cine.data.equals,myData[i].name}})
                for j=1, #myData[i].filename do
                    if choice == 3 then
                        OS.deleteRom(myData[i].platform[j],myData[i].filename[j])
                    else
                        excluded[myData[i].filename[j]] = true
                    end
                end
                table.remove(database.games,id)
                cine.serialize.save(database,"game_database.lua")
                cine.serialize.save(excluded,"excludedGames.lua")
                reset = true
            elseif choice==1 then
                local id = cine.data.find(database.games,{name={cine.data.equals,myData[i].name}})
                if myData[i].favourite then
                    database.games[id].favourite = nil
                else
                    database.games[id].favourite = true
                end
                cine.serialize.save(database,"game_database.lua")
            end

        end)
    end
    selector:registerCallback(updateSelector)
    selector:getLayer():setZIndex(1)
end

buildSelector()


local r_out = false
local l_out = false

function scene:onUpdate()
    if l_out then optionsMenu:update()
    else selector:update()
    end
    if reset then
        local index = selector:getIndex()
        local active = selector:getActive()
        cine.thread.wait(0.25)
        selector:delete()
        buildSelector()
        selector:setIndex(index)
        reset = false
    end
    if bLeft:isPressed() then
        if r_out then sidebar_r_scroll() r_out = false end
        if l_out then
            sidebar_l_scroll()
            l_out = false
        elseif not l_out then
            sidebar_l_scroll()
            l_out = true
        end
        cine.thread.wait(0.25)
    end
    if bRight:isPressed() then
        if l_out then sidebar_l_scroll() l_out = false end
        if r_out then
            sidebar_r_scroll()
            r_out = false
        elseif not r_out then
            sidebar_r_scroll()
            r_out = true
        end
        cine.thread.wait(0.25)
    end
    if bStart:isPressed() then
        local choice = selection("System Menu",{"Update Database","Configure Keys","Reboot","Shutdown","Exit"})
        if choice == 1 then self:stop() end
        if choice == 2 then  end
        if choice == 3 then OS.reboot() end
        if choice == 4 then OS.shutdown() end
        if choice == 5 then love.event.quit() end
        cine.thread.wait(0.5)
    end
end

function scene:onStop()
    cine.layer.clearAll()
    --define what is going to happen when your scene stops
end

return scene