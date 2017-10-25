
local MyApp = class("MyApp", cc.load("mvc").AppBase)

require "app.utilities.gta"

function MyApp:onCreate()
    math.randomseed(os.time())
    print("vslog:gta:getOS:"..gta.getOS())
    print("vslog:gta:getOS2:"..gta.getOS2())
    print("vslog:gta:getOS3:"..gta.getOS3())
    print("vslog:gta:getOS4:"..gta.getOS4())

    print("vslog:gta_new:getOS:"..gta:getOS())
    print("vslog:gta_new:getOS2:"..gta:getOS2())
    print("vslog:gta_new:getOS3:"..gta:getOS3())
    print("vslog:gta_new:getOS4:"..gta:getOS4())
    print("vslog:App running from here...new change one")

    for k,v in pairs(gta_copy) do
        print("gta_copy:k", k, "value:", v)
    end

    gta.cclog("A" .. " platform is xxx:" .. device.platform)
    gta.cclog("B" .. " platform is xxx:" .. tostring(os.date()))

    gta.cclog("test dump print", {a=1, b=2, c=3})

    gta.cclog("test dump print", {a=1, b=4, c=3})

    gta.log("test dump print", {a=1, b=4, c=3})
end

return MyApp
