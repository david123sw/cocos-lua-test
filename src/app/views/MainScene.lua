require "app.utilities.gta"

local MainScene = class("MainScene", cc.load("mvc").ViewBase)

MainScene.attachments = MainScene.attachments or {}

function MainScene:onCreate()
    print("MainScene:onCreate")
end

function MainScene:ctor(entryType)
    print("MainScene:ctor")
    -- -- add background image
    -- display.newSprite("HelloWorld.png")
    -- :move(display.center)
    -- :addTo(self)

    -- -- add HelloWorld label
    -- cc.Label:createWithSystemFont("Hello World", "Arial", 40)
    -- :move(display.cx, display.cy + 200)
    -- :addTo(self)
    local scene = require("app/views/LoadingScene"):create(nil)
    gta.assert(scene)
    scene:addTo(self)

    MainScene.attachments.mainSceneRef = scene
end

return MainScene
