local cm = require(ENGINE_PATH)
local scene = {}
local cfg = require("frontend/config")

function scene:onLoad()
    local color_bg, color1, color2 = cfg.bgColor, cfg.color1, cfg.color2
    love.graphics.setBackgroundColor(unpack(color_bg))
    local sw,sh = love.window.getDimensions()
    local layer = cm.layer.new()
    local sprite = cm.sprite.new(sw/2,-265,cm.sourceImage.new("frontend/lovelogo.png"))
    --sprite:setTint(unpack(color1))
    sprite:center("middle","bottom")
    local iD = love.image.newImageData(3,3)
    iD:setPixel(1,1,0,0,0,255)
    local shadow = cm.sprite.new(sw/2,sh/2-15,cm.sourceImage.new(iD))
    local sfx = love.audio.newSource("frontend/sounds/fadein.wav", "static")
    sfx:play()
    shadow:setSca(256/10,64/10)
    shadow:setTint(255,255,255,0)
    shadow:center()
    layer:insertSprite(shadow)
    layer:insertSprite(sprite)
    shadow:moveScaTo(256/2,64/2,1)
    shadow:moveTintTo(255,255,255,128,1)
    sprite:setTweenStyle("easein")
    sprite:moveScaTo(0.8,1.2,0.4)
    cm.thread.waitThread(sprite:movePosTo(sw/2,sh/2,1))
    cm.thread.waitThread(sprite:moveScaTo(1.2,0.8,0.1))
    shadow:moveScaTo(256/2.5,64/2.5,0.25)
    shadow:moveTintTo(255,255,255,100,0.25)
    sprite:setTweenStyle("easeout")
    sprite:moveScaTo(0.8,1.2,0.25)
    cm.thread.waitThread(sprite:movePos(0,-100,0.25))
    shadow:moveScaTo(256/2,64/2,0.15)
    shadow:moveTintTo(255,255,255,128,0.15)
    sprite:setTweenStyle("easein")
    cm.thread.waitThread(sprite:movePosTo(sw/2,sh/2,0.15))
    cm.thread.waitThread(sprite:moveScaTo(1,1,0.1))
    local sfx2 = love.audio.newSource("frontend/sounds/logo.wav", "static")
    cm.thread.wait(1)
    --rolling
    sprite:center()
    sprite:movePos(0,-128)
    sprite:setTweenStyle("easeout")
    shadow:setTweenStyle("easeout")
    sprite:movePos(60,0,1)
    local r,g,b = unpack(color2)
    shadow:movePos(60,0,1)
    sprite:moveRot(math.rad(30),1)
    local r,g,b = unpack(color1)
    sprite:moveTintTo(r,g,b,255,0.5)

    local sFont4 = cfg.font[5]
    local sRetro = cm.sprite.new(sw/2-50,sh/2,sFont4,"retrr ")
    sRetro:setTweenStyle("easeinout")
    sRetro:center("right","top")
    sRetro:setIndex("retro")
    local r,g,b = unpack(color1)
    sRetro:setTint(r,g,b,0)
    local sLove = cm.sprite.new(sw/2+50,sh/2,sFont4,"löve")
    sRetro:setTweenStyle("easeinout")
    local r,g,b = unpack(color2)
    sLove:setTint(r,g,b,0)
    layer:insertSprite(sRetro)
    layer:insertSprite(sLove)
    sfx2:play()
    sRetro:moveTint(0,0,0,255,1)
    sRetro:movePos(50,0,1)
    cm.thread.wait(1)
    sprite:movePos(-60,0,1)
    local r,g,b = unpack(color2)
    shadow:movePos(-60,0,1)
    sprite:moveRot(math.rad(-30),1)
    local r,g,b = unpack(color2)
    sprite:moveTintTo(r,g,b,255,1)
    sLove:moveTint(0,0,0,255,1)
    sLove:movePos(-50,0,1)

    cm.thread.wait(2.5)
    local sprite = cm.sprite.new(0,0,cm.sourceRectangle.new(),{sw,sh})
    sprite:setTint(255,255,255,0)
    layer:insertSprite(sprite)
    sprite:moveTintTo(255,255,255,255,1)
    cm.thread.wait(1)
    cm.layer.remove(layer)
    cm.thread.wait(0.25)
    self:stop()
    --initialize your scene here
end

function scene:onUpdate()
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene