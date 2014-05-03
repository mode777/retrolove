local cm = require(ENGINE_PATH)
local scene = {}
--input.loadMapping("buttons.lua")
local buttonUp = cm.input.newVirtualInput("up")
local buttonDown = cm.input.newVirtualInput("down")
local buttonLeft = cm.input.newVirtualInput("left")
local buttonRight = cm.input.newVirtualInput("right")

local function waitInput()
    while not input.getCurrentInput() do
        cm.thread.yield()
    end
    return input.getCurrentInput()
end

function scene:onLoad()
    buttonUp:map(waitInput())
    buttonDown:map(waitInput())
    buttonLeft:map(waitInput())
    buttonRight:map(waitInput())

    --buttonUp:map("keyboard","up")
    --buttonUp:map("keyboard","w")
    --buttonUp:map("mouse","wu")
    --buttonUp:map("joystick",1,"hat",1,"u")
    --buttonUp:map("joystick",1,"axis",2,"-")
    --initialize your scene here
end

local move = 0
function scene:onUpdate()
    local x,y = love.mouse.getPosition()
    local mx,my = 0,0
    if buttonLeft:isDown() then mx = -1
    elseif buttonRight:isDown() then mx = 1
    end
    love.mouse.setY(x+my,y+my)
    --if buttonUp:isReleased() then print("up") end
    --if input.getCurrentInput() then print(input.getCurrentInput()) end
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene