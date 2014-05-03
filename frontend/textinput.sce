local cm = require(ENGINE_PATH)
local input = require("frontend/input")
local scene = {}

local currentIndex = {1,1}
local previousIndex = {}
local grid
local cfg = cm.serialize.load("frontend/config.lua")
local sw,sh = love.window.getDimensions()
local font = cm.sourceFont.new("frontend/Roboto-Bold.ttf",cfg.fontSize[3]*(sh/100))
local layer = cm.layer.new()
local text = cm.sprite.new(50,400,font,"")
local keyboardLayer

local targetString = ""

local function createTextGrid(data,x,y)
    if keyboardLayer then cm.layer.remove(keyboardLayer) end
    if grid then grid:clear() end
    keyboardLayer = cm.layer.new()
    grid = cm.grid.new(x,y)
    local sbox = cm.sourceRectangle.new(0.5*(sh/100),cfg.color1)
    local size= font:getLineHeight()

    for i=1, data:len()  do
        local content = string.char(data:byte(i))
        local x,y = grid:getCoordinates(i)
        local sprite = cm.sprite.new(x*size,y*size,font,content)
        sprite:center()
        sprite:movePiv(-1*(sh/100),0.5*(sh/100))
        sprite:setTint(unpack(cfg.color1))
        local box = cm.sprite.new(x*size,y*size, sbox, {size,size})
        --box:setTint(unpack(cfg.color1))
        box:center()
        keyboardLayer:insertSprite(box)
        keyboardLayer:insertSprite(sprite)
        grid:setCell(x,y,{sprite,box})
    end
end

local charSets =
{
    "abcdefghijklmnopqrstuvwxyz",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "1234567890!@#$/^&*()-\\\":;,?"
}

function scene:onLoad()
    layer:insertSprite(text)
    createTextGrid(charSets[1],9,3)
    cm.textinput.setTarget("")

    --createTextGrid(charSets[2],9,3)
    --createTextGrid("1234567890!@#$/^&*()-'\":;,?",9,3)
    --initialize your scene here
end

local setIndex = 1
local delay = 0.20
function scene:onUpdate()
    if input:getCurrentInput() then print(input:getCurrentInput()) end
    text:setIndex(cm.textinput.getTarget(true))
    if (currentIndex[1] ~= previousIndex[1]) or (currentIndex[2] ~= previousIndex[2]) then
        local x,y
        local text,box
        if previousIndex[1] then
            x,y = unpack(previousIndex)
            text,box = unpack(grid:getCell(x,y))
            local r,g,b = unpack(cfg.color1)
            text:moveTintTo(r,g,b,255,0.5)
            r,g,b = unpack(cfg.bgColor)
            box:moveTintTo(r,g,b,255,0.5)
        end
        x,y = unpack(currentIndex)
        text,box = unpack(grid:getCell(x,y))
        local r,g,b = unpack(cfg.bgColor)
        text:moveTintTo(r,g,b,255,0.5)
        r,g,b = unpack(cfg.color2)
        box:moveTintTo(r,g,b,255,0.5)
        previousIndex[1],previousIndex[2] = currentIndex[1],currentIndex[2]
    end
    if input.down() then
        currentIndex[2] = currentIndex[2]+1 cm.thread.wait(delay)
        while not grid:getCell(unpack(currentIndex)) do
            currentIndex[2] = currentIndex[2]+1
        end
    end
    if input.up() then
        currentIndex[2] = currentIndex[2]-1 cm.thread.wait(delay)
        while not grid:getCell(unpack(currentIndex)) do
            currentIndex[2] = currentIndex[2]-1
        end
    end
    if input.right() then
        currentIndex[1] = currentIndex[1]+1 cm.thread.wait(delay)
        while not grid:getCell(unpack(currentIndex)) do
            currentIndex[1] = currentIndex[1]+1
        end
    end
    if input.left() then
        currentIndex[1] = currentIndex[1]-1 cm.thread.wait(delay)
        while not grid:getCell(unpack(currentIndex)) do
            currentIndex[1] = currentIndex[1]-1
        end
    end
    if input.option() then
        setIndex= setIndex < #charSets and setIndex+1 or 1
        print(setIndex)
        createTextGrid(charSets[setIndex],9,3)
        currentIndex = {1,1}
        previousIndex = {}
        cm.thread.wait(delay)
    end
    if input.select() then
        cm.textinput.insert(grid:getCell(unpack(currentIndex))[1]:getIndex())
        cm.thread.wait(delay)
    end
    if input.cancel() then
        print("test")
        cm.textinput.delete()
        cm.thread.wait(delay)
    end
    if input.previous() then
        cm.textinput.moveIndex("left")
        cm.thread.wait(delay)
    end
    if input.next() then
        cm.textinput.moveIndex("right")
        cm.thread.wait(delay)
    end
    if input.space() then
        cm.textinput.insert(" ")
        cm.thread.wait(delay)
    end
    local char = cm.getLoveEvent("textinput")
    if char then cm.textinput.insert(char) end
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene