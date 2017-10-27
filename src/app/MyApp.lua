
local MyApp = class("MyApp", cc.load("mvc").AppBase)

require "app.utilities.gta"

function MyApp:onCreate()
    math.randomseed(os.time())
    print("vslog:gta:getOS:"..gta.getOS({a=3, b=5}, 3, 4, 56))
    print("vslog:gta:getOS2:"..gta.getOS2({a=3, b=5}, 3, 4, 56))
    print("vslog:gta:getOS3:"..gta.getOS3())
    print("vslog:gta:getOS4:"..gta.getOS4())

    print("vslog:gta_new:getOS:"..gta:getOS({a=3, b=5}, 3, 4, 56))
    print("vslog:gta_new:getOS2:"..gta:getOS2({a=3, b=5}, 3))
    print("vslog:gta_new:getOS3:"..gta:getOS3())
    print("vslog:gta_new:getOS4:"..gta:getOS4())
    print("vslog:App running from here...new change one")

    for k,v in pairs(gta_copy) do
        print("gta_copy:k", k, "value:", v)
    end

    gta.cclog("A" .. " platform is xxx:" .. device.platform)
    gta.cclog("B" .. " platform is xxx:" .. tostring(os.date()))

    gta.cclog("test dump print", {a=1, b={d=5, e=78}, c=3})

    local testTable = {a=1, kk={a=5, b={e=5, f="aa"}}, c=3}
    gta.cclog("test dump print", testTable)

    gta.log("test dump print", {a=1, b={a=5, b=6}, c=3})

    -- begin my cocos app render
    cc.Director:getInstance():setDisplayStats(true)

end

-- function MyApp:run()
--     gta.cclog("running...")
-- end

-- function MyApp:onEnterBackground()
--     gta.cclog("enter background")
-- end

-- function MyApp:onEnterForeground()
--     gta.cclog("enter foreground")
-- end

return MyApp
