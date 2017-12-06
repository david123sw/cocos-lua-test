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

    local csbNode = cc.CSLoader:createNode("csd/test000.csb")--test000   --CreateRoom
    gta.assert(csbNode)
    csbNode:setAnchorPoint(gta.anchorMiddleMode)
    csbNode:setPosition(gta.winCenter)
--    gta.adjustSceneDisplay(csbNode)
    csbNode:addTo(self)
    gta.adjustSceneDisplay(csbNode)

    local ttt = {a="bbb", b=3, c={a=1, b=2}}
    dump(ttt)

    local ddd = clone(ttt)
    dump(ddd)

    ttt.a = "bbbnew"
    dump(ttt)

    ddd.a = "bbbnew2"
    dump(ddd)

end

return LoadingScene