local cm = require("engine")
local bUp, bDown, bX, bA, bBack, bRB, bLB = cm.input.getVirtualInput("Up") ,cm.input.getVirtualInput("Down"),cm.input.getVirtualInput("X"),cm.input.getVirtualInput("A"),cm.input.getVirtualInput("Back"),cm.input.getVirtualInput("RB"),cm.input.getVirtualInput("LB")
local menu = {}

function menu.new(Font,Size, Layer)
    local color = {255,255,255}
    local currentI
    local prevI
    local layer
    local ox, oy = 0,0
    local x,y = 0,0
    local cam
    local delay = 0.25
    local font
    local items = {}
    local threads_active = true
    local callback
    local pause

    local i = {}

    function i:activate()
        pause = false
    end

    function i:deactivate()
        pause = true
    end

    function i:getActive()
        return pause
    end

    function i:setActive(bool)
        pause = bool
    end

    function i:setColor(r,g,b)
        color = {r,g,b}
    end

    function i:setFont(name,size)
        if type(name) == "string" then font = cm.sourceFont.new(name,size)
        else font = name
        end
    end

    function i:setIndex(index)
        if index > #items then index = 1 end
        if index < 1 then index = #items end
        currentI = index
    end

    function i:getIndex()
        return currentI
    end

    function i:setPos(X,Y)
        ox, oy = X,Y
        cam:setPos(x-ox,y-oy)
    end

    function i:delete()
        if layer then cm.layer.remove(layer) end
    end

    function i:getLayer()
        return layer
    end

    function i:getCam()
        return cam
    end

    function i:addItem(desc,callback,callback2)
        local sprite = cm.sprite.new(0,#items*font:getLineHeight(),font,desc)
        sprite:setTint(color[1],color[2],color[3],128)
        sprite:center("left","middle")
        sprite.execute = callback
        sprite.options = callback2
        table.insert(items,sprite)
        if #items == 1 then currentI = 1 end
        layer:insertSprite(sprite )
        return #items, sprite
    end

    function i:setItemDescription(index,desc)
        items[index]:setIndex(desc)
    end

    function i:registerCallback(func)
        callback = func
    end

    local function getLetter(index)
        if index < 1 then index = #items end
        if index > #items then index = 1 end
        local currentLetter = items[index]:getIndex():sub(0,1)
        if currentLetter:match("[0-9]") then currentLetter = "number" end
        return currentLetter
    end

    local function findNextLetter()
        local currentLetter = getLetter(currentI)
        for i=currentI, #items do
            local letter = getLetter(i)
            if letter ~= currentLetter then return i end
        end
        return 1
    end


    local function findPreviousLetter()
        local currentLetter = getLetter(currentI)
        if currentLetter ~= getLetter(currentI-1) then currentLetter = getLetter(currentI-1) end
        for i=currentI-1, 1,-1 do
            local letter = items[i]:getIndex():sub(0,1)
            if letter:match("[0-9]") then letter = "number" end
            if letter ~= currentLetter then return i+1 end
        end
        return #items
    end

    local speed
    local sfx = love.audio.newSource("frontend/sounds/beep-shinymetal.wav", "static")
    function i:update()
        if not pause and #items > 0 then
            if bA:isReleased() then items[currentI]:execute() end
            if bBack:isReleased() then if items[currentI].options then items[currentI]:options() end end
            if not bUp:isDown() and not bDown:isDown() then speed = 1 end
            if bDown:isDown() then i:setIndex(currentI+1) cm.thread.wait(delay/speed) end
            if bLB:isDown() then i:setIndex(findNextLetter()) cm.thread.wait(delay) end
            if bUp:isDown() then i:setIndex(currentI-1) cm.thread.wait(delay/speed) end
            if bRB:isDown() then i:setIndex(findPreviousLetter()) cm.thread.wait(delay) end
            speed = speed+0.33
            if currentI ~= prevI then
                sfx:play()
                if prevI then
                    items[prevI]:moveTintTo(color[1],color[2],color[3],128,delay)
                    items[prevI]:moveScaTo(1,1,delay)
                end
                items[currentI]:moveTintTo(color[1],color[2],color[3],255,delay)
                items[currentI]:moveScaTo(1.125,1.125,delay)
                local x = cam:getPos()
                cam:movePosTo(x,-oy+(currentI-1)*font:getLineHeight(),delay)
                prevI = currentI
                if callback then callback(currentI) end
            end
        end
    end

    if Font then i:setFont(Font,Size) end
    layer = Layer or cm.layer.new()
    cam = cm.camera.new()
    cam:setTweenStyle("easeout")
    layer:setCamera(cam)

    return i
end

return menu