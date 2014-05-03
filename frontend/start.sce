local cm = require(ENGINE_PATH)
local scene = {}
function scene:onLoad()
    love.mouse.setVisible(false)
    cm.thread.waitThread(cm.runScene("frontend/animation.sce"))
    if not love.filesystem.exists("buttons.lua") then cm.thread.waitThread(cm.scene.new("frontend/buttonMapping.sce"):run())
    else cm.input.setMappingTable(cm.serialize.load("buttons.lua"))
    end
    --initialize your scene here
end

function scene:onUpdate()
    cm.thread.waitThread(cm.scene.new("frontend/updateDatabase.sce"):run())
    cm.thread.waitThread(cm.scene.new("frontend/newMenu.sce"):run())
    --update your scene here.
end

function scene:onStop()
    --define what is going to happen when your scene stops
end

return scene