local cfg = require("frontend/config")
local Color1,Color2,Color3 = cfg.bgColor, cfg.color1, cfg.color2
local bUp, bDown, bX, bA = cine.input.getVirtualInput("Up") ,cine.input.getVirtualInput("Down"),cine.input.getVirtualInput("X"),cine.input.getVirtualInput("A")
local Font = cfg.font[1]

local function selectMenu(Title, Options)
    local layer2 = cine.layer.new()
    local layer = cine.layer.new()
    local sw,sh = love.window.getDimensions()
    local cam = cine.camera.new()
    cam:setPos(0,sh)
    cam:setTweenStyle("easeout")
    layer:setCamera(cam)
    local lHeight = Font:getLineHeight()
    local height = lHeight + lHeight*#Options
    local y = sh/2-height/2
    local box = cine.sourceRectangle.new()
    local iD = love.image.newImageData(3,3)
    iD:setPixel(1,1,0,0,0,255)

    local optionsSprites = {}
    local width = 0
    for i,text in ipairs(Options) do
        local sprite = cine.sprite.new(sw/2,y+lHeight*i+lHeight/2, Font, text)
        local r,g,b = unpack(Color3)
        sprite:setTint(r,g,b,128)
        sprite:setSca(0.9,0.9)
        sprite:center("middle","middle")

        local w = sprite:getSize()
        width = math.max(width,w)
        table.insert(optionsSprites,sprite)
    end

    local title = cine.sprite.new(sw/2,y,Font,Title)
    title:center("middle","top")
    print("------------------")
    local w = title:getSize()
    width = math.max(w,width)
    local x = sw/2-width/2
    local shadow = cine.sprite.new(sw/2,sh/2,cine.sourceImage.new(iD))
    shadow:setSca(width,height)
    shadow:center("middle","middle")
    local coverBox = cine.sprite.new(0,0,box,{sw,sh})
    coverBox:setTint(0,0,0,0)
    local sbox2 = cine.sprite.new(x-20,y,box,{width+20,height})
    sbox2:setTint(unpack(Color1))
    local sbox1 = cine.sprite.new(x-20,y,box,{width+20,lHeight})
    sbox1:setTint(unpack(Color2))

    layer:insertSprite(shadow)
    layer2:insertSprite(coverBox)
    layer:insertSprite(sbox2)
    layer:insertSprite(sbox1)
    layer:insertSprite(title)
    for _,v in ipairs(optionsSprites) do
        layer:insertSprite(v)
    end

    local choice
    local index = 1
    local oldindex

    local function indexChange()
        local r,g,b = unpack(Color3)
        if oldindex then
            optionsSprites[oldindex]:moveTintTo(r,g,b,128,0.25)
            optionsSprites[oldindex]:moveScaTo(0.9,0.9,0.25)
        end
        optionsSprites[index]:moveTintTo(r,g,b,255,0.25)
        optionsSprites[index]:moveScaTo(1,1,0.25)
        oldindex = index
    end
    local sfx = love.audio.newSource("frontend/sounds/open.wav", "static")
    local sfx2 = love.audio.newSource("frontend/sounds/close.wav", "static")
    sfx:play()
    coverBox:moveTintTo(0,0,0,32,0.5)
    cine.thread.waitThread(cam:movePosTo(0,0,0.5))
    local sfx = love.audio.newSource("frontend/sounds/two_tone_nav.wav", "static")
    --cine.thread.wait(0.25)
    while not choice do
        if index ~= oldindex then indexChange() end
        if bDown.isDown() then index = index < #Options and index+1 or 1 sfx:play() cine.thread.wait(0.25) end
        if bUp.isDown() then index = index > 1 and index-1 or #Options sfx:play() cine.thread.wait(0.25) end
        if bA.isPressed() then choice = index end
        if bX.isPressed() then choice = 0 end
        cine.thread.yield()
    end
    cam:setTweenStyle("easeout")
    coverBox:moveTintTo(0,0,0,0,0.5)
    sfx2:play()
    cine.thread.waitThread(cam:movePosTo(0,-sh,0.5))
    cine.layer.remove(layer)
    cine.layer.remove(layer2)
    return choice
end



return selectMenu