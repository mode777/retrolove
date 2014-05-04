local cm = require(ENGINE_PATH)
local scene = {}
function scene:onLoad()
    love.mouse.setVisible(false)
    cine.thread.waitThread(cine.system.runScene("frontend/animation.sce"))
    if not love.filesystem.exists("buttons.lua") then cine.thread.waitThread(cine.scene.new("frontend/buttonMapping.sce"):run())
    else cine.input.setMappingTable(cine.serialize.load("buttons.lua"))
    end
    --initialize your scene here
end

function scene:onUpdate()
    cine.thread.waitThread(cine.scene.new("frontend/updateDatabase.sce"):run())
    cine.thread.waitThread(cine.scene.new("frontend/newMenu.sce"):run())
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene