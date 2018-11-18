
cc.exports.extension = {}

extension.type_wxshare = "weixin_share" --微信分享(android)
extension.type_wxmessage = "weixin_message" --微信分享(ios)
extension.type_wxtoken = "weixin_token" --获取微信token
extension.type_weixin_pay = "weixin_pay" --微信支付
extension.type_appstore_pay = "appstore_pay" --ios appstore pay
extension.type_ali_pay = "ali_pay" --支付宝
extension.qq_login = "qq_login" --QQ登录
extension.qq_share = "qq_share" --QQ分享
extension.horizontal_flip = "horizontal_flip" --android屏幕翻转
extension.ding_talk_share = "ding_talk_share" --钉钉分享
extension.type_charging_status = "power_charging_status" --手机充电状态

--支付类型
extension.PAY_TYPE_ALI = "pay_type_ali"
extension.PAY_TYPE_WEIXIN = "pay_type_weixin"
extension.PAY_TYPE_APPLE = "pay_type_apple"
extension.PAY_APPLE_URL = "http://114.55.111.161:8018/pay/app"

--录音相关
extension.voice_init        = "voice_init"
extension.voice_get_url     = "voice_url"
extension.voice_finish      = "voice_finish"
extension.voice_finish_play = "voice_finishplay"

--设备信息
extension.getBattery = "getBattery"
extension.getNetType = "getNetType"
extension.getLocation = "location"
extension.getClipboard = "getClipboard"

--apk download
extension.downloadDown = "apkDownload"

extension.SHARE_TYPE_SESSION = "session"
extension.SHARE_TYPE_TIMELINE = "timeline"
extension.shareUrl = ""

if gt.isIOSPlatform() then
	extension.SHARE_TYPE_SESSION = "WXSceneSession"
	extension.SHARE_TYPE_TIMELINE = "WXSceneTimeline"
end

--orderInfo
extension.orderInfo = ""
--copypasteInfo
extension.copyPasteInfo = ""

local APIClass = 'org/extension/ExtensionApi'

if gt.isIOSPlatform() then
	extension.luaBridge = require("cocos/cocos2d/luaoc")
elseif gt.isAndroidPlatform() then
	extension.luaBridge = require("cocos/cocos2d/luaj")
end


extension.callBackHandler = {}--保存回调函数
-- 提供java 和 oc回调
cc.exports.extension_callback = function(jsonObj)
	dump(jsonObj)
    local cjson = require("cjson")
    local respJson = cjson.decode(tostring(jsonObj))
	dump(respJson)
    local call_back = extension.callBackHandler[respJson.type]
    if call_back then
		gt.log("extension call_back "..respJson.type)
        printInfo("回调函数这里-----------------------")
        call_back(respJson)
	else
		gt.log("extension no call_back for "..respJson.type)
	end
end

--获取设备信息---
extension.getDeviceInfo = function()
    local ok
	local device = ""
    if gt.isAndroidPlatform() then
        ok, device = extension.luaBridge.callStaticMethod(
            APIClass,
            'getDeviceInfo',
			nil,
            '()Ljava/lang/String;'
        )
    elseif (gt.isIOSPlatform()) then
        ok, device = extension.luaBridge.callStaticMethod(
            'AppController',
            'getDeviceInfo'
        )
    end
    return device
end

--获取设备ID---
extension.getDeviceId = function()
    local ok
	local device = "abc"
    if gt.isAndroidPlatform() then
        ok, device = extension.luaBridge.callStaticMethod(
            APIClass,
            'getDeviceId',
			nil,
            '()Ljava/lang/String;'
        )
    elseif (gt.isIOSPlatform()) then
        ok, device = extension.luaBridge.callStaticMethod(
            'AppController',
            'getDeviceId'
        )
    end
    return device
end

--设置屏幕方向---
extension.setRequestedOrientation = function(so)
    if (gt.isIOSPlatform()) then
        --nothing
    elseif (gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'setRequestedOrientation',
			{so},
            '(Ljava/lang/String;)V'
        )
    end
end

--是否正在充电---
extension.isBatteryCharging = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            "AppController",
            'isDeviceCharging'
        )
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isBatteryCharging',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--是否是华为全面屏手机---
extension.isHuaWeiFullAspect = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
        return false
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isHuaWeiFullAspect',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--是否安装腾讯应用宝---
extension.isQQDownloaderInstalled = function(name)
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
        return false
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isQQDownloaderInstalled',
			{name},
            '(Ljava/lang/String;)Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--腾讯应用宝安装APP---
extension.jumpToQQDownloaderAndInstallApp = function(name)
    local ok
	local ret = false
    if (gt.isIOSPlatform()) then
        --忽略
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'jumpToQQDownloaderAndInstallApp',
			{name},
            '(Ljava/lang/String;)V'
        )
        if true == ok then
           gt.openWX = true
        end
    end
end

--是否安装QQ---
extension.isQQInstalled = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
       ok, ret = extension.luaBridge.callStaticMethod(
            "AppController",
            'isQQInstalled'
        )
    elseif (gt.isAndroidPlatform()) then
        ret = extension.isQQDownloaderInstalled("com.tencent.mobileqq")
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--是否安装闲聊---
extension.isXianLiaoInstalled = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
       ok, ret = extension.luaBridge.callStaticMethod(
            "AppController",
            'isXianLiaoInstalled'
        )
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isXianLiaoInstalled',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--闲聊分享
--text--->{shareType=shareType, shareText=shareText}
--url---->{shareType=shareType, shareText=shareText, shareTitle=shareTitle, shareDesc=shareDesc, shareUrl=shareUrl, sharePreUrl=sharePreUrl}
extension.shareXianLiao = function(msgDic)
    if (gt.isIOSPlatform()) then
       extension.luaBridge.callStaticMethod(
            "AppController",
            'xianLiaoShareMsg',
            msgDic
        )
    elseif (gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'shareXianLiao',
			{msgDic.shareType, msgDic.shareText, msgDic.shareTitle, msgDic.shareDesc, msgDic.shareUrl, msgDic.sharePreUrl},
            '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V'
        )
    end
end

--是否安装钉钉
extension.isDingTalkInstalled = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
       ok, ret = extension.luaBridge.callStaticMethod(
            "AppController",
            'isDingTalkInstalled'
        )
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isDingTalkInstalled',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--是否安装钉钉支持分享1
extension.isDingTalkSupportAPI = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
    ok, ret = extension.luaBridge.callStaticMethod(
        "AppController",
        'isDingTalkSupportOpenAPI'
        )
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isDingTalkSupportAPI',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--是否安装钉钉支持分享2
extension.isDingTalkSupportDingAPI = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
        --默认不支持
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isDingTalkSupportDingAPI',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--打开钉钉
extension.openDingTalk = function()
	local ok
	local ret = false
    if (gt.isIOSPlatform()) then
       ok, ret = extension.luaBridge.callStaticMethod(
            "AppController",
            'openDingTalk'
        )
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'openDingTalk',
			nil,
            '()Z'
        )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end

--钉钉分享
--text--->{shareType=shareType, shareText=shareText}
--url---->{shareType=shareType, shareText=shareText, shareTitle=shareTitle, shareDesc=shareDesc, shareUrl=shareUrl, sharePreUrl=sharePreUrl}
extension.shareDingTalk = function(msgDic)
    if (gt.isIOSPlatform()) then
       extension.luaBridge.callStaticMethod(
            'AppController',
            'dingTalkShareMsg',
            msgDic
        )
    elseif (gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'shareDingTalk',
			{msgDic.shareType, msgDic.shareText, msgDic.shareTitle, msgDic.shareDesc, msgDic.shareUrl, msgDic.sharePreUrl},
            '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V'
        )
    end
end

extension.getVirtualBarHeightWrap = function()
    local ok
    local wrap
    if gt.isAndroidPlatform() then
        ok, wrap = extension.luaBridge.callStaticMethod(
            APIClass,
            'getVirtualBarHeightWrap',
			nil,
            '()Ljava/lang/String;'
        )
    end
    return wrap
end

extension.getAndroidVirtualBarHeight = function(call_back)
    extension.callBackHandler[extension.horizontal_flip] = call_back
    local ok
	local barHeight = 0
    ok, barHeight = extension.luaBridge.callStaticMethod(
        APIClass,
        'getNavigationBarHeight',
		nil,
        '()I'
    )
    return barHeight
end

extension.addPhoneChargingStatusChecker = function (call_back)
    extension.callBackHandler[extension.type_charging_status] = call_back
    return extension.isBatteryCharging()
end

--获得app版本号
extension.getAppVersion = function()
    local ok
	local version = ""

    if gt.isAndroidPlatform() then
        ok, version = extension.luaBridge.callStaticMethod(
            APIClass,
            'getAppVersion',
			nil,
            '()Ljava/lang/String;'
        )
    elseif (gt.isIOSPlatform()) then
        ok, version = extension.luaBridge.callStaticMethod(
            'AppController',
            'getAppVersion'
        )
                        
    end
    return version
end

extension.jumpToiOSGPS = function ()
    extension.luaBridge.callStaticMethod(
            'AppController',
            'jumpToGPS'
    )
end

extension.getPasteBoard = function ()
    local ok
    local paste

    if gt.isAndroidPlatform() then
        --无变动
    elseif (gt.isIOSPlatform()) then
        ok, paste = extension.luaBridge.callStaticMethod(
            'AppController',
            'getRoomId'
        )             
    end
    return paste
end

--从分享进房间
extension.getURLRoomID = function()
    local ok
	local roomid = ""

    if gt.isAndroidPlatform() then
        ok, roomid = extension.luaBridge.callStaticMethod(
            APIClass,
            'getRoomId',
			nil,
            '()Ljava/lang/String;'
        )
    elseif (gt.isIOSPlatform()) then
        ok, roomid = extension.luaBridge.callStaticMethod(
            'AppController',
            'getRoomId'
        )
                        
    end
    return roomid
end


--从分享进房间
extension.getClipboradText = function(call_back)
    extension.callBackHandler[extension.getClipboard] = call_back--注册回调函数
    local ok
	local clipboradText = ""

    if gt.isAndroidPlatform() then
        ok, clipboradText = extension.luaBridge.callStaticMethod(
            APIClass,
            'getClipboardText',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        ok, clipboradText = extension.luaBridge.callStaticMethod(
            'AppController',
            'getRoomId'
        )
    end
    return clipboradText
end


--获取电池剩余容量
extension.get_Battery = function(call_back) 
    extension.callBackHandler[extension.getBattery] = call_back--注册回调函数
    local ok
	local ret = 100
	if(gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'GetBattery',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
                'nettools',
                'getBatteryLeve'
            )
		ret = ret * 100
    end

	return ret
end

-- 获取地理位置
extension.get_Location = function(call_back)
    extension.callBackHandler[extension.getLocation] = extension._getLocationHandler--注册回调函数
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'GetLocation',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'AppController',
            'getGDLocation'
        )
    end
end


extension.decodeURI = function(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

extension._getLocationHandler = function(data)
    if(gt.isAndroidPlatform()) then
        local status = data.status
        if (tonumber(status) == 1) then 
            gt.location = extension.decodeURI(data.code)
            --local locationArr = string.split(gt.location,"#")
            ---gt.location = --string.format("%s#%s",locationArr[1],locationArr[2],)
        else
            
            gt.location = ""
        end
    elseif (gt.isIOSPlatform()) then
        local latStr = data.latitude
        local lonStr = data.longitude
        local addStr = data.geoLocation
        if latStr == nil or lonStr == nil or addStr == nil then
            gt.location = ""
        else
            gt.location = string.format("%f#%f#%s",tonumber(latStr), tonumber(lonStr), addStr);
        end
    else
        gt.location = ""
    end
    if gt.location and string.len(gt.location) > 0 then
        gt.location = string.gsub(gt.location,"[(*null)*]","")
    end

    local curScene = cc.Director:getInstance():getRunningScene()
    gt.log("extension._getLocationHandler,curScene:getName() = "..curScene:getName())
    if curScene:getName() == "zipaiScene" then
        curScene:onUpdateGpCallback()
    end
end


--是否安装微信
extension.isInstallWeiXin = function()
	local ok
	local ret = false
    if(gt.isIOSPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
                "wxlogin",
                'isWechatInstalled'
               )
    elseif (gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
                    APIClass,
                    'checkInstallWeixin',
					nil,
                    '()Z'
                )
    end
	if ret == true or ret == 1 then
		return true
	end
    return false
end


--分享图片???
extension.shareToImage = function(shareTo, filePath, call_back)
    if(not extension.isInstallWeiXin())then
        gt.log("非微信登录无法分享")
        return 
    end
    local ok, text
    if ( gt.isIOSPlatform() ) then
        extension.callBackHandler[extension.type_wxmessage] = call_back --注册回调函数
        extension.luaBridge.callStaticMethod("wxlogin",
            "sendImageContent",
            {shareTo = shareTo, filePath = filePath}
			)
    elseif (gt.isAndroidPlatform()) then
        extension.callBackHandler[extension.type_wxshare] = call_back --注册回调函数
        ok, text = extension.luaBridge.callStaticMethod(
            APIClass,
            "weixinShareImg",
			{shareTo, filePath},
            '(Ljava/lang/String;Ljava/lang/String;)V'
            )
        if true == ok then
           gt.openWX = true
        end
    end
end

--分享链接
extension.shareToURL = function(shareTo, title, message, url, call_back)
    if(not extension.isInstallWeiXin())then
        gt.log("非微信登录无法邀请")
        return 
    end

    local ok, text
    if ( gt.isIOSPlatform() ) then
		extension.callBackHandler[extension.type_wxmessage] = call_back --注册回调函数
        extension.luaBridge.callStaticMethod(
            "wxlogin",
            "sendLinkContent",
            {shareTo = shareTo, title = title, text = message, url = url}
		)
    elseif (gt.isAndroidPlatform()) then
		extension.callBackHandler[extension.type_wxshare] = call_back --注册回调函数
        ok, text = extension.luaBridge.callStaticMethod(
            APIClass,
            "weixinShareApp",
			{shareTo, title, message, url},
            '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V'
        )
        if true == ok then
           gt.openWX = true
        end
    end
end

--获取QQ登录
--ios android 对于返回的json解析不一样,特别注意一下
extension.getQQLogin = function (call_back)
    if (not call_back) then
        gt.log("error getQQLogin need a call_back")
        return
    end

    extension.callBackHandler[extension.qq_login] = call_back --注册回调函数
    if(gt.isAndroidPlatform()) then
        gt.log("extension.getQQLogin android")
        extension.luaBridge.callStaticMethod(
            APIClass,
            'requestQQLogin',
			{gt.qqAPPID},
            '(Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        gt.log("extension.getQQLogin ios");
        extension.luaBridge.callStaticMethod(
            'AppController',
            'requestQQLogin'
        )
    end
end

--获取微信登陆token
extension.getWeixinToken = function(call_back) 
    if(not call_back) then
        gt.log("error getWeixinToken need a call_back")
        return
    end
    extension.callBackHandler[extension.type_wxtoken] = call_back --注册回调函数
    gt.log("-------->extension.getWeixinToken:"..gt.wxId)

    if(gt.isAndroidPlatform()) then
        gt.log("extension.getWeixinToken android")
        extension.luaBridge.callStaticMethod(
            APIClass,
            'getWeixinToken',
			{gt.wxId},
            '(Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        gt.log("extension.getWeixinToken ios");
        extension.luaBridge.callStaticMethod(
            'wxlogin',
            'sendAuthReqForLoginWX',
            {wxid = gt.wxId}
        )
    end
end


--获取手机号码
extension.getPhoneNumber = function() 
    if(gt.isAndroidPlatform()) then
        local ok, tel = extension.luaBridge.callStaticMethod(
            APIClass,
            'getPhoneNumber',
			nil,
            '()Ljava/lang/String;'
        )
        return tel
    end
    return ""
end

--录音初始化
extension.voiceInit = function(appid, istest) 
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'voiceInit',
			{appid},
            '(Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voiceInit',
            {appid = appid, ifDebug = istest}
        )
    end
end

--录音登录
extension.yayaLogin = function(uid, unick) 
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'voiceLogin',
			{uid, unick},
            '(Ljava/lang/String;Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voiceLogin',
            {uid = uid, unick = unick}
        )
    end
end

--开始录音
extension.voiceStart = function() 
    if(gt.isAndroidPlatform()) then
        return extension.luaBridge.callStaticMethod(
            APIClass,
            'voiceStart',
			nil,
            '()Z'
        )
    elseif (gt.isIOSPlatform()) then
        return extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voiceStart'
        )
    end
end

--停止录音
extension.voiceStop = function(call_back)
    gt.log("--------voiceStop")
    extension.callBackHandler[extension.voice_finish] = call_back --注册回调函数
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'voiceStop',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voiceStop'
        )
    end
end

--上传录音
extension.voiceupload = function(call_back, path, time)
    gt.log("--------voiceupload path", path)
    extension.callBackHandler[extension.voice_get_url] = call_back --注册回调函数
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'voiceupload',
			{path, time},
            '(Ljava/lang/String;Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voiceupload',
            {path = path, time = time}
        )
    end
end

--播放录音
extension.voicePlay = function(call_back, url)
    extension.callBackHandler[extension.voice_finish_play] = call_back --注册回调函数
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'voicePlay',
			{url},
            '(Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voicePlay',
            {url = url}
        )
    end
end

--停止语音播放
extension.stopVoicePlay = function()
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'stopAllVoice',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'voicePlayStop'
        )
    end
end

--获取录音长度
extension.getVoiceDuration = function(url)
    local ok
	local duration = 0
    if(gt.isAndroidPlatform()) then
        ok, duration = extension.luaBridge.callStaticMethod(
            APIClass,
            'getVoiceDuration',
			{url},
            '(Ljava/lang/String;)I'
        )
    elseif (gt.isIOSPlatform()) then
        
    end
    return duration
end

--录音退出
extension.yayaLoginOut = function()
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'yayaLoginOut',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'yayavoice',
            'yayaLoginOut'
        )
    end
end

-- 网络是否可用
extension.isNetworkAvailable = function()
    local ok
	local ret = true
    if(gt.isAndroidPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            APIClass,
            'isNetworkAvailable',
			nil,
            '()Z'
        )
    elseif (gt.isIOSPlatform()) then
        ok, ret = extension.luaBridge.callStaticMethod(
            'nettools',
            'checkNetState'
        )
        gt.log("ifnet....",ret)
    end
    game.networkAvailable = ret
    return ret
end

--下载Apk
extension.downLoadApk = function(call_back, url, writablePath)
    gt.log("--------down load apk url：" .. url)
    extension.callBackHandler[extension.downloadDown] = call_back --注册回调函数
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'downloadApk',
			{url, writablePath},
            '(Ljava/lang/String;Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then               
    end
end

-- 支付
extension.pay = function(type, orderInfo)
	extension.orderInfo = orderInfo
	if(type == extension.PAY_TYPE_ALI) then
		if gt.isAndroidPlatform() then
			extension.AndroidAlipay(orderInfo)
		end
	elseif(type == extension.PAY_TYPE_WEIXIN) then
		if extension.isInstallWeiXin() then
			if gt.isAndroidPlatform() then
				extension.AndroidWXPay(orderInfo)
            end
		else
			gt.log("未安装微信")
		end
	elseif(type == extension.PAY_TYPE_APPLE) then
		extension.IosPay(orderInfo)
	end
end

-- 安卓微信支付
extension.AndroidWXPay = function(orderInfo)
	local function payHandler(jsonData)
		gt.log("callback android wxpay")
        local status = jsonData.status
        if(status == 1) then
            gt.log("微信支付成功")
        else
            gt.log("微信支付取消 errorCode", jsonData.code)
        end
	end

	extension.callBackHandler[extension.type_weixin_pay] = payHandler
	gt.log("call AndroidWXPay", orderInfo);
	extension.luaBridge.callStaticMethod(
		'org/extension/ExtensionApi',
		'weixinPay',
		{tostring(orderInfo)},
		'(Ljava/lang/String;)V'
	)
end

-- 安卓支付宝支付
extension.AndroidAlipay = function(orderInfo)
	local function payHandler(jsonData)
		gt.log("callback android alipay")
        local status = jsonData.status
        if(status == 1) then
            gt.log("支付宝支付成功")
        else
            gt.log("支付宝支付取消")
        end
	end

	extension.callBackHandler[extension.type_ali_pay] = payHandler
	gt.log("call AndroidAliPay", orderInfo);
	extension.luaBridge.callStaticMethod(
        'org/extension/ExtensionApi',
        'alipay',
		{tostring(orderInfo)},
        '(Ljava/lang/String;)V'
	)
end

-- IOS支付
extension.IOSPay = function(orderInfo)
	local function payHandler(jsonData)
		gt.log("callback ios pay")
        local status = jsonData.status
        if(status == 1) then
            gt.log("IOS 支付成功")
        else
            gt.log("IOS 支付取消")
        end
	end

	extension.callBackHandler[extension.type_appstore_pay] = payHandler
	gt.log("call iosPay", orderInfo)
	extension.luaBridge.callStaticMethod(
		'iospay',
		'makePurchase',
		{identifier = 'com.you9.klqp.dn'..orderInfo}
	)

end

extension.CopyTextToClipboard=function ( str )
    extension.copyPasteInfo = str
    if(gt.isAndroidPlatform()) then
        gt.log("extension.CopyTextToClipboard android:"..str)
        extension.luaBridge.callStaticMethod(
            APIClass,
            'copyTextToClipboard',
			{str},
            '(Ljava/lang/String;)V'
        )
	elseif (gt.isIOSPlatform()) then
		extension.luaBridge.callStaticMethod(
            'AppController',
            'copyToClipboard',
			{text = str}
        )          
    end
end


--打开微信
extension.openWechat = function ()
    local ok, text
    if gt.isAndroidPlatform() then
        ok, text = extension.luaBridge.callStaticMethod(
             APIClass,
             'openWechat',
		 	nil,
             '()V'
         )
         if true == ok then
            gt.openWX = true
         end
    elseif (gt.isIOSPlatform()) then
        cc.Application:getInstance():openURL("wechat://")
    end
end


--开启权限界面
extension.openAppPermissions = function()
    if(gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'getAppDetailSettingIntent',
			nil,
            '()V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.jumpToiOSGPS()
    end
end

--保存图片
extension.saveImageToGallery = function (srcPath)
    if gt.isAndroidPlatform() then
        ok, text = extension.luaBridge.callStaticMethod(
             APIClass,
             'copyImageToGallery',
		    {tostring(srcPath)},
            '(Ljava/lang/String;)V'
         )
    elseif (gt.isIOSPlatform()) then
        local fileName = "fullScreenShot.png"
        cc.utils:captureScreen(function(succeed, outputFile)
            if succeed then
                gt.log("capture path:"..outputFile)
                extension.luaBridge.callStaticMethod(
                    'AppController',
                    'saveToImageGallery',
                    {path = outputFile}
                )
            else
                gt.log("屏幕截图失败")
                require("app/views/CommonTips"):create("图片保存失败，请再试一次")
            end
        end, fileName)
    end
end

--QQ分享
--ios
--link--->{title=title, description=description, url=url, previewImgUrl=previewImgUrl}
--text--->{text=text}
--image-->{image=image, title=title, description=description, absoluteImage=absoluteImage}
--android
--第6个参数是发文字的appIcon预览，无需变动
extension.qqShareMsg = function (msgDict, call_back)
    if(not call_back) then
        gt.log("qqShareMsg can set a call_back")
    end
    extension.callBackHandler[extension.qq_share] = call_back --注册回调函数

    if (gt.isAndroidPlatform()) then
        extension.luaBridge.callStaticMethod(
            APIClass,
            'qqShareMsg',
			{msgDict.text == nil and "" or msgDict.text, 
            msgDict.absoluteImage == nil and "" or msgDict.absoluteImage,
            msgDict.title == nil and "" or msgDict.title, 
            msgDict.description == nil and "" or msgDict.description, 
            msgDict.url == nil and "" or msgDict.url, 
            msgDict.previewImgUrl == nil and "" or msgDict.previewImgUrl,
            msgDict.previewImgUrl == nil and "" or msgDict.previewImgUrl},
            '(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V'
        )
    elseif (gt.isIOSPlatform()) then
        extension.luaBridge.callStaticMethod(
            'AppController',
            'qqShareMsg',
            msgDict
        )
    end
end