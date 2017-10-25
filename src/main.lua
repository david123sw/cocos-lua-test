
cc.FileUtils:getInstance():setPopupNotify(true)
local writePath = cc.FileUtils:getInstance():getWritablePath()
print("vslog:running from resPath", writePath)
local DEBUG_PLATFORM = "win32"--config
if not "win32" == DEBUG_PLATFORM then
    local resSearchPaths = {
        "src/",
        "res/",
        writablePath,
        writablePath .. "src/",
        writablePath .. "res/"
    }
    cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)
else
    print("target platform is win32")
end

require "socket"
require "config"
require "cocos.init"

local function main()
    require("app.MyApp"):create():run()
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
