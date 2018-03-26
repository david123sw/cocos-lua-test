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

--    local listener = cc.EventListenerTouchOneByOne:create()
--	listener:setSwallowTouches(false)
--	listener:registerScriptHandler(handler(self, self.onTouchHandCardAreaBegan), cc.Handler.EVENT_TOUCH_BEGAN)
--    listener:registerScriptHandler(handler(self, self.onTouchHandCardAreaMoved), cc.Handler.EVENT_TOUCH_MOVED)
--	listener:registerScriptHandler(handler(self, self.onTouchHandCardAreaEned), cc.Handler.EVENT_TOUCH_ENDED)
--	local eventDispatcher = self:getEventDispatcher()
--    eventDispatcher:addEventListenerWithFixedPriority(listener, -1);
--    self.handCardAreaListener = listener

[[--addSpine : function() {
        cc.director.purgeCachedData();
        this.spineInst = sp.SkeletonAnimation("x.json", "x.atlas", 0.5);
	//if encounter with errors,use
	//sp.SkeletonAnimation.createWithJsonFile("x.json", "x.atlas", 0.5);
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
--	#define USE_WIN32_CONSOLE
--	
--	#ifdef USE_WIN32_CONSOLE
--	AllocConsole();
--	freopen("CONIN$", "r", stdin);
--	freopen("CONOUT$", "w", stdout);
--	freopen("CONOUT$", "w", stderr);
--	#endif
--
--	open cocos androld log
--	in cocos2d-x/cocos/Android.mk
--	under -fexceptions
--	LOCAL_CFLAGS += -DCOCOS2D_DEBUG=1 -DANDROID
--
--	in CCLuaStack.cpp
--	mod lua_print()
--	#ifdef ANDROID
--		__android_log_print(ANDROID_LOG_DEBUG, "cocos2d-lua", "%s", t.c_str());
--	#else
--		CCLOG("[LUA-print] %s", t.c_str());
--	#endif
--
[[
	function LoginScene:hasServerMaintainceNotice()
    gt.showLoadingTips(gt.getLocationString("LTKey_0003"))

    if self.xhr == nil then
        self.xhr = cc.XMLHttpRequest:new()
        self.xhr.timeout = 30 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.SERVER_MAINTAIN_NOTICE
    self.xhr:open("GET", url)
    self.xhr:registerScriptHandler(function ()
        if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then

        gt.removeLoadingTips()

        local bit = require("bit")
        local function unicode_to_utf8(convertStr)
            if type(convertStr)~="string" then
                return convertStr
            end

            local resultStr=""
                local i=1
            while true do
                local num1=string.byte(convertStr,i)
                local unicode

                if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
                    unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
                    i=i+6
                elseif num1~=nil then
                    unicode=num1
                    i=i+1
                else
                    break
                end

                if unicode <= 0x007f then
                    resultStr=resultStr..string.char(bit.band(unicode,0x7f))
                elseif unicode >= 0x0080 and unicode <= 0x07ff then
                    resultStr=resultStr..string.char(bit.bor(0xc0,bit.band(bit.rshift(unicode,6),0x1f)))
                    resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
                elseif unicode >= 0x0800 and unicode <= 0xffff then
                    resultStr=resultStr..string.char(bit.bor(0xe0,bit.band(bit.rshift(unicode,12),0x0f)))
                    resultStr=resultStr..string.char(bit.bor(0x80,bit.band(bit.rshift(unicode,6),0x3f)))
                    resultStr=resultStr..string.char(bit.bor(0x80,bit.band(unicode,0x3f)))
                end
            end
            resultStr=resultStr..'\0'
            return resultStr
        end

        require("json")
        local prepare, num = string.gsub(self.xhr.response, "\\", "\\\\")
        local xhrParsedResp = json.decode(prepare)
        gt.dump(xhrParsedResp)
        self.serverNoticeTitle = 0 > #xhrParsedResp.title and unicode_to_utf8(xhrParsedResp.title) or ""
        self.serverNoticeBody = 0 > #xhrParsedResp.body and unicode_to_utf8(xhrParsedResp.body) or ""
        if 0 < #self.serverNoticeBody then
            self.isServerShutdownOrMaintain = true
        else
            self.isServerShutdownOrMaintain = false
        end
        if self.isServerShutdownOrMaintain then
		    self:showServerShutdownOrMaintainTips()
        end

        elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
            -- 网络问题,异常断开
        end
        self.xhr:unregisterScriptHandler()
    end)
    self.xhr:send()
end
]]

         <activity
            android:name=".wxapi.WXEntryActivity"
            android:exported="true"
            android:label="@string/wx_api"
            android:screenOrientation="portrait"
            android:theme="@style/wxActivityTheme">
        </activity>       <activity
            android:name=".wxapi.WXEntryActivity"
            android:exported="true"
            android:label="@string/wx_api"
            android:screenOrientation="portrait"
            android:theme="@style/wxActivityTheme">
        </activity>

    <string name="app_name">上饶棋牌测试</string>
    <string name="wx_api">WXEntryActivity</string>
    <style name="wxActivityTheme" parent="@android:style/Theme">
    	<item name="android:windowIsTranslucent">true</item>
    </style>

            self.listViewRightChoice_niu_more_lv:setInnerContainerPosition(cc.p(0, offset + (-200) + (curIndex-1) * 50))
            self.listViewRightChoice_niu_more_lv:refreshView()
            self.listViewRightChoice_niu_more_lv:getInnerContainer():setPosition(cc.p(0, offset + (-200) + (curIndex-1) * 50))


            cc.utils:captureScreen(function(succeed, outputFile)  
                   if succeed then  
                     local winSize = cc.Director:getInstance():getWinSize()  
                     local sp = cc.Sprite:create(outputFile)  
                     self:addChild(sp, 0, 1000)  
                     sp:setPosition(winSize.width / 2, winSize.height / 2)  
                     sp:setScale(0.5) -- 显示缩放  
                     print(outputFile)  
                   else  
                       cc.showTextTips("截屏失败")  
                   end  
            end, "resultscreenshot.png") 

android-paste-&-enter
		public void checkSystemClipboard() {
		ClipboardManager cbm = (ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
		if(null != cbm.getText())
		{
			String linkUrl = this.getCompleteUrl(cbm.getText().toString());
			if("" != linkUrl)
			{
				AppActivity.roomid = Uri.parse(linkUrl).getQueryParameter("roomid");
				cbm.setText("");
			}
		}
	}
	
	public String getCompleteUrl(String text) {
	    Pattern p = Pattern.compile("((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?", Pattern.CASE_INSENSITIVE);
	    Matcher matcher = p.matcher(text);
	    matcher.find();
	    return matcher.group();
	}public void checkSystemClipboard() {
		ClipboardManager cbm = (ClipboardManager)getSystemService(Context.CLIPBOARD_SERVICE);
		Log.d("xxxxxxxxxxxxxxxxxxxxxxxxxxx:", cbm.getText().toString());
		Log.d("xxxxxxxxxxxxxxxxxxxxxxxxxxx:", this.getCompleteUrl(cbm.getText().toString()));
		AppActivity.roomid = Uri.parse(this.getCompleteUrl(cbm.getText().toString())).getQueryParameter("roomid");
	}
	
	public String getCompleteUrl(String text) {
	    Pattern p = Pattern.compile("((http|ftp|https)://)(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?", Pattern.CASE_INSENSITIVE);
	    Matcher matcher = p.matcher(text);
	    return matcher.find() ? matcher.group() : "";
	}


	//copy android assets
    public void copyAssetsFile(final String srcFile) {
    	final File fs = new File(getFilesDir(), srcFile);
    	Log.d(Constant.LOG_TAG, "fs manifest write path:" + fs);
    	if(fs.exists())
    	{
    		Log.d(Constant.LOG_TAG, "fs manifest exist");
    		return;
    	}
    	
    	new Thread() {
    		public void run() {
    			Log.d(Constant.LOG_TAG, "manifest copy");
    			try {
    				AssetManager am = getAssets();
    				InputStream is = am.open("res/" + srcFile);
    				FileOutputStream fos = new FileOutputStream(fs);
    				byte[] buffer = new byte[512];
    				int len = 0;
    				while((len=is.read(buffer)) != -1) {
    					fos.write(buffer, 0, len);
    				}
    				fos.close();
    				is.close();
    			} catch (Exception e) {
    				e.printStackTrace();
    			}
    		}
    	}.start();
    }

    private void getAppVersion(){
    	try {
	    	PackageManager pm = this.getApplicationContext().getPackageManager();  
	        PackageInfo pi = pm.getPackageInfo(this.getApplicationContext().getPackageName(), 0);  
	        appVersion = pi.versionName; 
		} catch (Exception e) {
			e.printStackTrace();
		}
    
	}


//android recorder&playing
public boolean startAudioRecording() {
    	audioPrepath = audioPrepath + System.currentTimeMillis() + ".amr";
    	File file = new File(audioPrepath);
    	if(file.exists()) {
    		if(file.delete())
    		{
    			try {
    				file.createNewFile();
    			}catch(IOException e) {
    				e.printStackTrace();
    			}
    		}else {
    			try {
    				file.createNewFile();
    			}catch(IOException e) {
    				e.printStackTrace();
    			}
    		}
    	}
    	
    	audioMR = new MediaRecorder();
    	audioMR.setAudioSource(MediaRecorder.AudioSource.MIC);
    	audioMR.setOutputFormat(MediaRecorder.OutputFormat.AMR_NB);
    	audioMR.setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB);
    	audioMR.setOutputFile(audioPrepath);
    	audioMR.setMaxDuration(20000);
    	
    	try {
    		audioMR.prepare();
    	}catch(IOException e) {
    		e.printStackTrace();
    	}
    	
    	audioMR.start();
    	mpBeginTm = System.currentTimeMillis();
    	return true;
    }
    
    public boolean stopAudioRecording() {
    	if(null != audioMR) {
    		mpEndTm = System.currentTimeMillis();
    		audioMR.stop();
    		audioMR.reset();
    		audioMR.release();
    		audioMR = null;
    	}
    	return true;
    }
    
    public void playAudioRecording(final String extraUrl) {
    	audioMP = new MediaPlayer();
    	try {
    		if("" != extraUrl) {
    			audioMP.reset();
    			audioMP.setDataSource(extraUrl);
    			audioMP.setAudioStreamType(AudioManager.STREAM_MUSIC);
    			audioMP.prepareAsync();
    			audioMP.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
					
					@Override
					public void onPrepared(MediaPlayer mp) {
						audioMP.start();
					}
				});
    		}
    		else {
    			audioMP.setDataSource(audioPrepath);
    			audioMP.prepare();
    			audioMP.start();
    		}
    		audioMP.setVolume(1.0f, 1.0f);
    	}catch(IOException e) {
    		e.printStackTrace();
    	}
    }
    
    public void stopPlayAudioRecording() {
    	if(null != audioMP) {
    		audioMP.stop();
    		audioMP.release();
    		audioMP = null;
    	}
    }


    //26 androi8.0
sdkVerNum = Build.VERSION.SDK_INT;
		is8SDK = sdkVerNum >= 26;

NSString* parseUrlFromStr(NSString *string)
{
    NSError *error;
    NSString *regularStr = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularStr options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        NSString* substringForMatch = [string substringWithRange:match.range];
        NSLog(@"isUrlType %@",substringForMatch);
        return substringForMatch;
    }
    return NULL;
}

	local headSpr = gt.seekNodeByName(csbNode, "Spr_head")
--	headSpr:removeFromParent(true)
--	headSpr:setPosition(cc.p(0, 0))
	--headSpr:setScale(81.0/96.0)
	--头像遮罩
--	local stencil = cc.Sprite:create("image/NiuNiu/play/avatar_shader.png")
--	local clipper = cc.ClippingNode:create()
--	clipper:setStencil(stencil)
--	clipper:setInverted(true)
--	clipper:setAlphaThreshold(0)
--	local x, y = headFrameBtn:getPosition()
--	local headFrameSize = headFrameBtn:getContentSize()
--	clipper:setPosition(cc.p(headFrameSize.width / 2, headFrameSize.height / 2))
--	clipper:addChild(headSpr)
--	headFrameBtn:addChild(clipper)
--
--svn diff --diff-cmd "diff" -x "-q" . | grep Index | cut -d " " -f 2
