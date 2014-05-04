local input = cine.input
local scene = {}
local layer = cine.layer.new()
local cfg = require("frontend/config")
local sw, sh = love.window.getDimensions()
local font = cfg.font[2]
local smFont = cfg.font[1]
local selection = require("frontend/selectMenu")

local function waitInput()
    while not input.getCurrentInput() do
        cine.thread.yield()
    end
    return input.getCurrentInput()
end

function scene:onLoad()
    love.graphics.setBackgroundColor(unpack(cfg.bgColor))
    local controller = cine.sprite.new(sw/2, sh/2+sh*0.1, cine.sourceImage.new("frontend/360_controller.png"))
    controller:center()
    controller:setTint(255,255,255,100)
    controller:setSca(sh*0.6/controller:getSource():getImage():getHeight())
    local status = cine.sprite.new(sh*0.1, sh*0.1, font, "Input configuration \r\n(press button to continue)")
    local status2 = cine.sprite.new(sh*0.1, sh*0.2, smFont, "")
    layer:insertSprite(controller)
    layer:insertSprite(status)
    layer:insertSprite(status2)
    status:setTint(unpack(cfg.color1))
    status2:setTint(unpack(cfg.color2))
    local choice = 2
    while choice == 2 do
        cine.input.setMappingTable({})
        status2:setIndex("")
        status:setIndex("Input configuration \r\n(press button to continue)")
        waitInput()
        local inputs = {"Up","Down","Left","Right","Y","B","A","X","LB","RB","LT","RT","Back","Start"}

        for i=1, #inputs do
            local button = input.newVirtualInput(inputs[i])
            status:setIndex("Press input for \""..inputs[i].."\"...")
            cine.thread.wait(0.25)
            button:map(waitInput())
            local data = {input.getCurrentInput() }
            if data[1] == "keyboard" then data = string.format("Keyboard '%s'-key",data[2]) end
            if data[1] == "mouse" then data = string.format("Mouse Button '%s'",data[2]) end
            if data[1] == "joystick" then data = string.format("Joystick %s %s",data[2],table.concat({data[3]," ",data[4]," ",data[5]})) end
            status2:setIndex(status2:getIndex()..inputs[i]..": "..data.."\r\n")
        end
        choice = selection("Is this correct?",{"Yes","No"})
    end
    self:stop()
    cine.serialize.save(input.getMappingTable(),"buttons.lua")
    --initialize your scene here
end

function scene:onUpdate()
    --update your scene here.
end

function scene:onStop()
    cine.layer.remove(layer)
    --define what is going to happen when your scene stops
end

return scene