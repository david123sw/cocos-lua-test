--refer url as following:
--http://www.runoob.com/lua/lua-data-types.html
local gta = {} or gta
gta.IS_DEBUG = true
gta.APP_ENTRY_IP = "not defined"
gta.APP_ENTRY_PORT = "not defined"

function gta:getOS()
    print("gta:getOS")
    return "ret from getOSxxxx"
end

gta.getOS2 = function()
    print("gta:getOS2")
    return "ret from getOS2"
end

local function getOS3()
    print("gta:getOS3")
    return "ret from getOS3"
end
gta.getOS3 = getOS3

function gta.getOS4()
    print("gta:getOS4")
    -- local t000 = {}
    -- local t111 = {}
    -- setmetatable(t000, {__index=t111})
    -- assert(3 == 3)

    -- local t000 = {}
    -- local ttt = enum(t000)
    -- for ele in ttt do
    -- end
    local t = {1, 2, 3}
    print("-----xxxx:"..#t)

    local tt = {5, 2, 3}
    print("-----xxxx:"..#tt)

    local ttt = {1, 2, 6}
    print("-----xxxx:"..#ttt)

    local html = [[
        <html>
        <head></head>
        <body>
            <a href="http://www.runoob.com/">tec</a>
        </body>
        </html>
        ]]
    print(html)

    return "ret from getOS4"
end

local function dump_value_(v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function gta.cclog(tag, ...)
    local tag_ = tag or ""

    local function tableParser(invalue)
        local parseString = ""
        local params = invalue or ""
        local paramsType = type(params)
        local paramsSize = #params
        local parseParamsCount = 0

        if "string" == paramsType then
            parseString = "" .. params
        elseif "table" == paramsType then
            local tmp = "{"
            for k,v in pairs(params) do
                parseParamsCount = parseParamsCount + 1
                if "table" ~= v then
                    tmp = tmp .. tostring(k) .. ":" .. tostring(v)
                    if paramsSize - 1 > parseParamsCount then
                        tmp = tmp .. ","
                    end
                else
                    tmp = tmp .. tostring(k) .. ":" .. tableParser(v) .. ","
                end
            end
            parseString = parseString .. tmp .. "}"
        end

        return parseString
    end

    tag_ = tag_ .. ":" ..  tableParser(...)

    -- local params = ... or ""
    -- local t_ = type(params)
    -- if "string" == t_ then
    --     tag_ = tag_ .. params
    -- elseif "table" == t_ then
    --     local tmp = "{"
    --     for k,v in pairs(params) do
    --         tmp = tmp .. tostring(k) .. ":" .. tostring(v) .. ""
    --     end
    --     tag_ = tag_ .. ":" .. tmp .. "}"
    -- end

    if gta.IS_DEBUG then
    print(os.date("%c") .. " debug------------------------------------------ " .. " "  .. tag_)
    end
end

function gta.log(msg, ...)
	msg = msg .. " "
	local args = {...}
	for i,v in ipairs(args) do
		msg = msg .. tostring(v) .. " "
	end
	print(os.date("%Y-%m-%d %H:%M:%S") .. "------lua log:" .. msg)
	if cc.PLATFORM_OS_WINDOWS == "windows" then
		local file = io.open("gameclient.log", "a")
		if file then
			file:write(msg.."\n")
			file:close()
		end
	end
end

cc.exports.gta = gta

cc.exports.gta_copy = {
    a = 1,
    b = 2
}
gta_copy.c = 3