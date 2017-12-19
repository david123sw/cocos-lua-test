--refer url as following:
--http://www.runoob.com/lua/lua-data-types.html

--lua actions ref
--http://www.cnblogs.com/kane0526/p/5924568.html

--c++ actions ref
--http://blog.csdn.net/arxi/article/details/31384865

local gta = {} or gta
--const definitions
gta.IS_DEBUG = true
gta.APP_ENTRY_IP = "not defined"
gta.APP_ENTRY_PORT = "not defined"
gta.winSize = cc.Director:getInstance():getVisibleSize()
gta.winCenter = cc.p(gta.winSize.width * 0.5, gta.winSize.height * 0.5)
gta.anchorMiddleMode = cc.p(0.5, 0.5)

--ccs event name(not used)
gta.ccsEventName = gta.ccsEventName or {}
gta.ccsEventName.TOUCH_BEGAN = 0
gta.ccsEventName.TOUCH_MOVED = 1
gta.ccsEventName.TOUCH_ENDED = 2
gta.ccsEventName.TOUCH_CANCELLED = 3

--node generic
function gta.assert(node)
    assert(node ~= nil, "Load DisplayObject Failed, Stop")
end

function gta.adjustSceneDisplay(node)
    -- gta.assert(node)
    print("widSize:width:"..gta.winSize.width.."&height:"..gta.winSize.height)
    node:setContentSize(gta.winSize)
    ccui.Helper:doLayout(node)
end

function gta.countChildrenNodeNum(node)
    gta.assert(node)
    local children = node:getChildren()
    local count = 0
    for k,v in ipairs(children) do
        count = count + 1
    end
    return count
end

function gta.sceneCleanUp(node)
    -- gta.assert(node)
    if node then
    node:stopAllActions()
    node:removeAllChildren()
    node:removeFromParent()
    end
end
-- defaultGenerics ===> {["CheckBox"] = true, ["Button"] = true]}
-- excepts         ===> {["nameA"] = true, ["nameB"] = true, ["nameC"] = true}
function gta.disableNodeZoomMode(root, excepts, defaultGenerics)
    assert(root ~= nil)
    local children = root:getChildren()
    for k,v in ipairs(children) do
        local generic = v:getDescription()
        local name = v:getName()
        if nil ~= defaultGenerics[generic] and nil == excepts[name] then
            v:setZoomScale(0)
        end
        disableNodeZoomMode(v, excepts, defaultGenerics)
    end
end
--

function gta.convEnNum2CnNum(invalue)
    local size = #tostring(invalue)
    local cnNum = ""
    local ref = {"一","二","三","四","五","六","七","八","九"}
    for i = 1, size do
        cnNum = cnNum .. ref[tonumber(string.sub(invalue, i, i))]
    end
    return cnNum
end

function gta:getOS(...)
    print("gta:getOS")
    local args = {...}
    local count = 0
    for k,v in pairs(args) do
        count = count + 1
    end

    local aaa = 3.0001
    local bbb = 3
    if aaa == bbb then
        print("aaa == bbb")
    else
        print("aaa != bbb")
    end

    local b,e = string.find("Hello Lua user", "Lua%a, %d, %s, %l", 8)
    gta.isMember()
    print('find str ret:'..tostring(b).."--"..tostring(e))

    print("--ccc--"..string.format("%#7.3f", 13))

    print("change en to cn:", gta.convEnNum2CnNum(131234))

    local tablemap = {["cc"] = "1", [2] = "b", a = "c"}
    -- local tableconcat = table.concat(tablemap)
    print("----after concat:", tableconcat)

    local co = coroutine.create(function(a)
        local r = coroutine.yield(a+1)
        print("aaa:", r)
    end)
    local status,r = coroutine.resume(co, 1)
    print('status:', status, "r:", r)
    local status1,r1 = coroutine.resume(co, 100)
    print('status1:', status1, "r1:", r1)

    -- io.read("*a") io.read("*n") io.read.read("*|") io.close()
    -- io.seek("end", -1) io.seek("set") io.seek("end")

    -- collectgarbage("collect") collectgarbage("count")

    assert(0 == 0, "not equal")
    debug.debug()

    return "ret from getOSxxxx" .. count .. "2mi3" .. tostring(2^3)
end

function gta.isMember()
    print("call isMember")
end

gta.getOS2 = function(...)
    print("gta:getOS2:")
    local args = {...}
    local count = 0
    for k,v in pairs(args) do
        count = count + 1
        print("k,"..k.."v,"..tostring(v))
    end
    print("gta:getOS2:params count:"..count)

    -- local arg = select("1", args)
    -- print("args seq here:", #arg)

    return "ret from getOS2"
end

local function getOS3(...)
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
    local t = {"abc", "eee", nil, 3}
    print("-----xxxx:"..#t)

    local tt = {5, 12, 3}
    print("-----xxxx:"..#tt)

    local ttt = {[44]=2, [3]=5, [200]=3}
    print("-----xxxx:"..#ttt.."---:")

    local tttt = {[5]=2, [3]=5, [1]=3}
    print("-----xxxx:"..#tttt.."---:")

    local ttttt = {b=2, c=5, d=3}
    print("-----xxxx:"..#ttttt.."---:")

    local html = [[
        <html>
        <head></head>
        <body>
            <a href="http://www.runoob.com/">tec</a>
        </body>
        </html>
        ]]
    print(html)

    local i
    for i = 1, 10 do
        print(i .. "\n")
    end

    local days = {} --= {"Suanday","Monday","Tuesday",3,"Wednesday","Thursday","Friday","Saturday"}
    days[1] = "s"
    days[2] = "ss"
    days[3] = nil
    days[4] = "ssss"  
    -- local days = {[1]="aaaa", [3]="b", a="ccc"}
    print("days count:"..#days.."first->")
    for i,v in ipairs(days) do  print(v) end

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

    local function tableSize(invalue)
        local size = 0
        if "table" ~= type(invalue) then
            return size
        end
        for k,v in pairs(invalue) do
            size = size + 1
        end
        return size
    end

    local recursiveCount = 0
    local function tableParser(invalue)
        local parseString = ""
        local params = invalue or ""
        local paramsType = type(params)
        local paramsSize = tableSize(invalue)
        local parseParamsCount = 0
        recursiveCount = recursiveCount + 1
        local recursiveTab = string.rep("\t", recursiveCount)
        local recursiveReturn = string.rep("\r\n", recursiveCount - #recursiveTab + 1)
        recursiveReturn = recursiveReturn .. recursiveTab

        if "string" == paramsType then
            parseString = "" .. params
        elseif "table" == paramsType then
            local tmp = "{\r\n"
            for k,v in pairs(params) do
                parseParamsCount = parseParamsCount + 1
                if "table" ~= type(v) then
                    tmp = tmp .. recursiveTab .. tostring(k) .. " = " .. tostring(v)
                else                
                    tmp = tmp .. recursiveTab .. tostring(k) .. " = " .. tableParser(v)
                end
                if paramsSize - 1 >= parseParamsCount then
                    tmp = tmp .. ",\r\n"
                end
            end
            parseString = parseString .. tmp .. recursiveReturn .. "}"
        end

        return parseString
    end

    if ... then
        tag_ = tag_ .. ":" ..  tableParser(...)
    end
    
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

--[[
    -- Meta class
    Shape = {area = 0}
    -- 基础类方法 new
    function Shape:new (o,side)
      o = o or {}
      setmetatable(o, self)
      self.__index = self
      side = side or 0
      self.area = side*side;
      return o
    end
    -- 基础类方法 printArea
    function Shape:printArea ()
      print("面积为 ",self.area)
    end
    
    -- 创建对象
    myshape = Shape:new(nil,10)
    myshape:printArea()
    
    Square = Shape:new()
    -- 派生类方法 new
    function Square:new (o,side)
      o = o or Shape:new(o,side)
      setmetatable(o, self)
      self.__index = self
      return o
    end
    
    -- 派生类方法 printArea
    function Square:printArea ()
      print("正方形面积为 ",self.area)
    end
    
    -- 创建对象
    mysquare = Square:new(nil,10)
    mysquare:printArea()
]]

--            local excepts = {"PopDoubleRateCheck_1", "PopDoubleRateCheck_2", "PopDoubleRateCheck_3"}
--            local validFlag = false
--            for k,v in pairs(excepts) do
--                local pt = sender:getTouchBeganPosition()
--                local validItem1 = ccui.Helper:seekWidgetByName(bottom, v)
--                local aabb = validItem1:getBoundingBox()
--                local worldPt = validItem1:getParent():convertToNodeSpaceAR(pt)
--                validFlag = cc.rectContainsPoint(aabb, worldPt)
--                if validFlag then break end
--            end

--            if not validFlag then
--                self.GameNiuNiuConfigs.DynamicStatusCollection.IsClickDoubleRate = false
--                if self.GameNiuNiuConfigs.DisplayNodes.LayoutPopDoubleRateNode then self.GameNiuNiuConfigs.DisplayNodes.LayoutPopDoubleRateNode:setVisible(false) end
--                ccui.Helper:seekWidgetByName(bottom, "Image_Pop"):setRotation(180)
--            else
--                panelTouchNode:setSwallowTouches(false)
--            end

[[--addSpine : function() {
        cc.director.purgeCachedData();
        this.spineInst = sp.SkeletonAnimation("x.json", "x.atlas", 0.5);
        this.spineInst.setPosition(cc.p(cc.winSize.width / 2, cc.winSize.height / 2));
        this.spineInst.setAnimation(0, "x", false);
        this.spineInst.setStartListener(function(evt){
            cc.log("spineInst start");
        });
        var that = this;
        this.spineInst.setEndListener(function (evt) {
            cc.log("spineInst finish");
            that.spineInst.removeFromParent(true);
            that.spineInst = null;
        });
        this.spineInst.setCompleteListener(function(evt) {
            cc.log("spineInst complete");
        });
        //this.spineInst.setAnimationListener(this, function(obj, trackIndex, type, event, loopCount) {
        //    cc.log("spineInst All Listener" + type);
        //    switch(type) {
        //        case 0:
        //            break;
        //        case 1:
        //            break;
        //        case 2:
        //            break;
        //        case 3:
        //            break;
        //    }
        //});
        this.addChild(this.spineInst);
    },
--]]
