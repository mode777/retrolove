local sw,sh = love.window.getDimensions()
local fontName = "frontend/Roboto-Bold.ttf"
local fontSize = {4,6,7,8,15}
local cm = require(ENGINE_PATH)

local fonts =  {}
for i=1, #fontSize do
    table.insert( fonts, cm.sourceFont.new(fontName,fontSize[i]*(sh/100)) )
end

return
{
    font = fonts,
    bgColor = {255,255,255},
    color1 = {255,138,0},
    color2 = {0,118,255}
}