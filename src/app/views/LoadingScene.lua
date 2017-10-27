require "app.utilities.gta"
-- local LoadingScene = class("LoadingScene", cc.load("mvc").ViewBase)

local LoadingScene = class("LoadingScene", function()
    return cc.Scene:create()
end)

function LoadingScene:onCreate()
    gta.cclog("LoadingScene:onCreate")
end

function LoadingScene:ctor(entryType)
    gta.cclog("LoadingScene:ctor")

    local csbNode = cc.CSLoader:createNode("csd/test000.csb")
    gta.assert(csbNode)
    csbNode:setAnchorPoint(gta.anchorMiddleMode)
    csbNode:setPosition(gta.winCenter)
    csbNode:addTo(self)
end

return LoadingScene