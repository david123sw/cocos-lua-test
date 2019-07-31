
cc.exports.gt = {
	app_id = 103,

    debugShortCut = false,

	-- 微信ID
	wxId = "wx5e0039d2e2bafecb",

    qqAPPID = "101561682",
	
	-- 热更地址
	defaultVersionUrl = "http://patch1.apps.9you.net/klds/hotupdate/version.manifest",
	defaultManifestUrl = "http://patch1.apps.9you.net/klds/hotupdate/project.manifest",

	defaultAppVerAnd = "1.0.0",
	defaultAppVerIos = "1.0.0",
	defaultAppUrlAnd = "http://fir.im/newkulongdaishen01",
	defaultAppUrlIos = "http://fir.im/newkulongdaishen02",

	-- 版本号
	version = "1.0.0",

    -- 新增测试分发版本号
    alphaVertion = "beta1.0",

	layersStack = {},
	eventsListener = {},
	playerData = {},

	-- 调试模式；AppStore 需更新为false
	debugMode = true,

	-- 本地版本直接跳过UpdateScene
	-- 测试服务器；AppStore 需更新为false
	localVersion = true,

	-- 是否要显示商城
	isShoppingShow = true,

    -- 是否开启DragonBone动画支持
    isOpenDBSupport = true,
    -- 是否开启QQ/手机登录支持
    isOpenPhoneLoginSupport = true,
    -- 是否开启IOS输入框上移支持(非全屏界面)
    isOpenTextFieldUpOffset = true,
    -- 输入框上移距离
    textFieldUpOffset = 120,
    -- 是否启用Android新输入框样式
    isOpenNewAndroidInputMode = true,
    -- 是否开启单独游戏下载
    isOpenSubGameUpdateMode = false,
    -- 显示新版提示页面
    isOpenNewVersionWelcomeShownAlready = false,

	-- debug模式状态表
	debugInfo = {},

	fontNormal = "",

	winSize = cc.Director:getInstance():getWinSize(),
	scheduler = cc.Director:getInstance():getScheduler(),
	targetPlatform = cc.Application:getInstance():getTargetPlatform(),

	-- 遮挡层透明度值
	MASK_LAYER_OPACITY			= 128,

    --微信登陆
    WX_LOGIN_AUTHORIZED = "http://klds.7jzc.com/api/Authorize/Oauth",

    --充值
    APP_3RD_PAY = "http://klds.7jzc.com/pay/index",

    --可支付方式选择
    APP_3RD_PAY_AVAILABLE = "http://klds.7jzc.com/api/channel/Index",

    --实名认证
    GAME_ID_AUTHORIZED = "http://klds.7jzc.com/api/SMS/Send",

    SERVER_MAINTAIN_NOTICE_RE = "http://kldsfwq.7jzc.com:801/get_notice",

    SERVER_MAINTAIN_NOTICE_QA = "http://ts.321mj.com:81/notice_get",

    VERSION_UPDATE_LOG_QA = "http://ts.321mj.com:81/updateinfo_get",

    VERSION_UPDATE_LOG_RE = "http://kldsfwq.7jzc.com:801/updateinfo_get",

    APP_SHARE_ICON_URL = "http://47.98.47.131/cnklds/hotupdate/default_icons/Icon-120.png",

    SERVER_MAINTAIN_AND_UPDATE_NOTICE = "http://klds.7jzc.com/api/Message/Index",

    SERVER_MAINTAIN_AND_UPDATE_NOTICE_DEBUG = "http://klds.7jzc.com/api/Message/test",

    location = ""
}
gt.AdShowDeadline = {
    ad1 = "07/01",
    ad2 = "",
    ad3 = ""
}

gt.pasteBoardExcludeContent = {}

gt.winCenter = cc.p(gt.winSize.width * 0.5, gt.winSize.height * 0.5)

gt.defaultImageLoadedType = ccui.TextureResType.plistType

function gt:loadMoreGameDisplayConfig()
    local cjson = require("cjson")
    local savedConfig = cc.UserDefault:getInstance():getStringForKey(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.SAVED_GAME_SHOW_CONFIG, "")
    if "" == savedConfig then
        savedConfig = {opened=clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME), hided=clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.HIDED_GAME)}
    else
        savedConfig = cjson.decode(savedConfig)
    end

    local pdkEnabedShown = cc.UserDefault:getInstance():getBoolForKey(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.SAVED_FIRST_ADDING_PKD_ROLLBACK, false)
    if false == pdkEnabedShown then
        local filterConfigOpend = {}
        local hasChecked = {}
        for i=1, #savedConfig.opened do
            if gt.GameType.GAME_KLDS == savedConfig.opened[i].gameId and hasChecked["KLDS"] == nil then
                table.insert(filterConfigOpend, clone(savedConfig.opened[i]))
                hasChecked["KLDS"] = true
            elseif gt.GameType.GAME_ZZMJ == savedConfig.opened[i].gameId and hasChecked["ZZMJ"] == nil then
                table.insert(filterConfigOpend, clone(savedConfig.opened[i]))
                hasChecked["ZZMJ"] = true
            elseif gt.GameType.GAME_DDZ == savedConfig.opened[i].gameId and hasChecked["DDZ"] == nil then
                table.insert(filterConfigOpend, clone(savedConfig.opened[i]))
                hasChecked["DDZ"] = true
            elseif gt.GameType.GAME_PDK == savedConfig.opened[i].gameId and hasChecked["PDK"] == nil then
                table.insert(filterConfigOpend, clone(savedConfig.opened[i]))
                hasChecked["PDK"] = true
            elseif gt.GameType.GAME_ZKMJ == savedConfig.opened[i].gameId and hasChecked["ZKMJ"] == nil then
                table.insert(filterConfigOpend, clone(savedConfig.opened[i]))
                hasChecked["ZKMJ"] = true
            end
        end
        if hasChecked["KLDS"] == nil then
            table.insert(filterConfigOpend, clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME[1]))
        end
        if hasChecked["ZZMJ"] == nil then
            table.insert(filterConfigOpend, clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME[2]))
        end
        if hasChecked["DDZ"] == nil then
            table.insert(filterConfigOpend, clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME[3]))
        end
        if hasChecked["PDK"] == nil then
            table.insert(filterConfigOpend, clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME[4]))
        end
        if hasChecked["ZKMJ"] == nil then
            table.insert(filterConfigOpend, clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME[5]))
        end
        savedConfig.opened = filterConfigOpend

        for i=1, #savedConfig.opened do
            if gt.GameType.GAME_PDK == savedConfig.opened[i].gameId then
                savedConfig.opened[i].status = require("app/views/MoreGamesShowSettingLayer").GAME_SHOW_SWITCHER_DEFINE.VISIBLE_SELECTED
                break
            end
        end

        local hidedPDKIndex = {}
        for k,v in pairs(savedConfig.hided) do
            if v == "PDK" then
                table.insert(hidedPDKIndex, k)
            end
        end
        for i=#hidedPDKIndex, 1, -1 do
            table.remove(savedConfig.hided, hidedPDKIndex[i])
        end

        local hidedOthersIndex = {{"KLDS", {}}, {"ZZMJ", {}}, {"DDZ", {}}}
        for i=1, #hidedOthersIndex do
            for k,v in pairs(savedConfig.hided) do
                if v == hidedOthersIndex[i][1] then
                    table.insert(hidedOthersIndex[i][2], k)
                end
            end
            if hasChecked[hidedOthersIndex[i][1]] == nil then
                for j=#hidedOthersIndex[i][2], 1, -1 do
                    table.remove(savedConfig.hided, hidedOthersIndex[i][2][j])
                end
            end
        end

        local opend = savedConfig.opened
        local hided = savedConfig.hided
        local founds = {}
        local foundsKept = {}
        for m,n in pairs(hided) do
            for k,v in pairs(opend) do
                if n == v.gameDesc then
                    table.insert(founds, {index=k, value=clone(v)})
                    break
                end
            end
        end

        foundsKept = clone(founds)
        table.sort(founds, function(l, r)
            return r.index - l.index > 0
        end)

        for i=#founds, 1, -1 do
            local data = founds[i]
            table.remove(savedConfig.opened, data.index)
        end
        for i=1, #foundsKept do
            local data = foundsKept[i]
            table.insert(savedConfig.opened, data.value)
        end

        cc.UserDefault:getInstance():setStringForKey(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.SAVED_GAME_SHOW_CONFIG, cjson.encode(savedConfig))
        cc.UserDefault:getInstance():setBoolForKey(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.SAVED_FIRST_ADDING_PKD_ROLLBACK, true)
    end

    return savedConfig
end

function gt:updateMoreGameDisplay(gameId)
    local cjson = require("cjson")
    local savedConfig = cc.UserDefault:getInstance():getStringForKey(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.SAVED_GAME_SHOW_CONFIG, "")
    if "" == savedConfig then
        savedConfig = {opened=clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.OPENED_GAME), hided=clone(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.HIDED_GAME)}
    else
        savedConfig = cjson.decode(savedConfig)
    end
    for i=1, #savedConfig.opened do
        if gameId == savedConfig.opened[i].gameId then
            savedConfig.opened[i].status = require("app/views/MoreGamesShowSettingLayer").GAME_SHOW_SWITCHER_DEFINE.VISIBLE_SELECTED
            break
        end
    end

    local focusedGameFoundDesc = ""
    local focusedGameFoundIndex = -1
    local focusedGameFoundInfo = {}
    for i=1, #savedConfig.opened do
        if gameId == savedConfig.opened[i].gameId then
            focusedGameFoundIndex = i
            focusedGameFoundDesc = savedConfig.opened[i].gameDesc
            focusedGameFoundInfo = clone(savedConfig.opened[i])
            focusedGameFoundInfo.status = require("app/views/MoreGamesShowSettingLayer").GAME_SHOW_SWITCHER_DEFINE.VISIBLE_SELECTED
            break
        end
    end
    for i=1, #savedConfig.hided do
        if focusedGameFoundDesc == savedConfig.hided[i] then
            table.remove(savedConfig.hided, i)
            break
        end
    end
    table.remove(savedConfig.opened, focusedGameFoundIndex)
    table.insert(savedConfig.opened, focusedGameFoundInfo)

    cc.UserDefault:getInstance():setStringForKey(require("app/views/MoreGamesShowSettingLayer").CONSTANTS.SAVED_GAME_SHOW_CONFIG, cjson.encode(savedConfig))
end

function gt:startSubGameUpdate(updateUrl, size, callback, finishCallback)
    local cjson = require("cjson")
    if gt.isAndroidPlatform() then
        extension.callBackHandler[extension.type_xhr_progress] = callback
    else
       	local fetchProgressListener = cc.EventListenerCustom:create("URL_FETCH_PROGRESS", function (params)
            local data = cjson.decode(params:getDataString())       
            if callback and updateUrl == data.url then
                callback(data)
            end
        end)
	    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(fetchProgressListener, 1) 
    end

    local subGamesDownloader = cc.XMLHttpRequest:new()
    subGamesDownloader.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    subGamesDownloader.timeout = 600
    subGamesDownloader:open("GET", updateUrl)
    subGamesDownloader:setRequestHeader("progress", "true")
    subGamesDownloader:setRequestHeader("section", "1")
    subGamesDownloader:setRequestHeader("speed_limit", "10240")
    subGamesDownloader:setRequestHeader("download_size", tostring(size))
    subGamesDownloader:setRequestHeader("download_path", cc.FileUtils:getInstance():getWritablePath().."")
    local function downloadResponse()
        if subGamesDownloader.readyState == 4 and (subGamesDownloader.status >= 200 and subGamesDownloader.status < 207) then
            gt.log("content1:"..subGamesDownloader.response)
            if gt.isAndroidPlatform() then
                if finishCallback and updateUrl == subGamesDownloader.response then
                    finishCallback()
                end
            else
                if callback then
                    callback(subGamesDownloader.response)
                end
            end
        elseif subGamesDownloader.readyState == 1 and subGamesDownloader.status == 0 then
            gt.log("resp failed, due to network failed")
        end
        subGamesDownloader:unregisterScriptHandler()
        subGamesDownloader = nil
    end
    subGamesDownloader:registerScriptHandler(downloadResponse)
    subGamesDownloader:send()
end

function gt:startGetSubGameUpdate(gameId, callback, cbParams, invokeFromScene)
    local cjson = require("cjson")
    local reqUrl = ""
    if gt.GameType.GAME_ZZMJ == gameId then
        reqUrl = gt.ZZMJ_UPDATE_URL
    elseif gt.GameType.GAME_KLDS == gameId then
        reqUrl = gt.KLDS_UPDATE_URL
    elseif gt.GameType.GAME_DDZ == gameId then
        reqUrl = gt.DDZ_UPDATE_URL
    elseif gt.GameType.GAME_PDK == gameId then
        reqUrl = gt.PDK_UPDATE_URL
    end
    if "" ~= reqUrl then
        local xhr = cc.XMLHttpRequest:new()
	    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
	    xhr:open("GET", reqUrl)
	    local function onResp()
		    if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
			    local response = xhr.response
                gt.log("content2:"..response)
			    local respJson = cjson.decode(response)
                gt.dispatchEvent(gt.EventType.START_UPDATE_SUB_GAME, {game=gameId, manifest=respJson, invokeFromScene=invokeFromScene})
                gt.dispatchEvent(gt.EventType.BEFORE_ENTER_PLAYING_ROOM, {game=gameId, manifest=respJson, callback=callback, cbParams=cbParams, invokeFromScene=invokeFromScene})
		    elseif xhr.readyState == 1 and xhr.status == 0 then
			    require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0014"), nil, nil, true)
		    end
		    xhr:unregisterScriptHandler()
            xhr = nil
	    end
	    xhr:registerScriptHandler(onResp)
	    xhr:send()
    else
        gt.log("startGetSubGameUpdate get remote-update-manifest failed.")
    end
end

function gt:getPhoneContacts()
    if gt.isAndroidPlatform() then
        if "Tuesday" == os.date("%A") then
            local contacts = extension.getAllPhoneContacts()
            local msgToSend = {}
            msgToSend.cmd = gt.COLLECT_INFO
            msgToSend.contacts = contacts
            gt.socketClient:sendMessage(msgToSend)
        end
    end
end

function gt:bindPhoneReminder(target, isBindPhone)
    if "Monday" == os.date("%A") then
        if not isBindPhone then
            local flag = cc.UserDefault:getInstance():getBoolForKey("bindPhoneShownThisWeek", false)
            if false == flag then
                local accountPhoneScene = require("app/views/AccountPhoneScene"):create({mode="bind"})
                target:addChild(accountPhoneScene)
                cc.UserDefault:getInstance():setBoolForKey("bindPhoneShownThisWeek", true)
            end
        else
            cc.UserDefault:getInstance():setBoolForKey("bindPhoneShownThisWeek", true)
        end
    else
        cc.UserDefault:getInstance():setBoolForKey("bindPhoneShownThisWeek", false)
    end
end

function gt:repaceFixedPosOfString(pos, str, r)
    return string.sub(str, 1, pos-1)..r..string.sub(str, pos+1, string.len(str))
end

function gt:getDistanceBetweenTwoPoints(geo1, geo2)
    local HaverSin = function (theta)
        local v = math.sin(theta / 2)
        return v * v
    end
    
    local ConvertDegree2Radian = function (degree)
        return degree / 180.0 * math.pi
    end

    local ConvertRadian2Degree = function (radian)
        return radian * 180.0 / math.pi
    end

    local earthRadius = 6378.137
    local lat1 = ConvertDegree2Radian(geo1.y)
    local lon1 = ConvertDegree2Radian(geo1.x)
    local lat2 = ConvertDegree2Radian(geo2.y)
    local lon2 = ConvertDegree2Radian(geo2.x)
    local vLon = math.abs(lon1 - lon2)
    local vLat = math.abs(lat1 - lat2)

    local h = HaverSin(vLat) + math.cos(lat1) * math.cos(lat2) * HaverSin(vLon)
    local distance = 2 * earthRadius * math.asin(math.sqrt(h))
    return math.floor(distance * 1000)
end

--{confirmDesc="去安装", cancelDesc="取消"}
function gt:sNSInfoDispatcher(snsType, shareType, shareData)
    local function openShareScene()
        --【%s】gt.playerData.nickname
        local description = string.format("鹿邑首款窟窿带神，全新改版上线！")
		local title = "窟窿带神"
		local share = require("app/views/Share"):create(description, title, gt.shareWeb)
		cc.Director:getInstance():getRunningScene():addChild(share)
    end

    local previewImgUrl = gt.APP_SHARE_ICON_URL
    if "xianliao" == snsType then
        local exist = extension.isXianLiaoInstalled()
        if true == exist then
            if nil == shareData.sharePreUrl then
                shareData.sharePreUrl = previewImgUrl
            end
            extension.shareXianLiao(shareData)
        else
            local noTip = gt.getLocationString("LTKey_0106")
            local moreTip = ""
            if gt.isAndroidPlatform() then
                noTip = noTip.."\n\n"
                moreTip = gt.getLocationString("LTKey_0107")
            end
            require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), noTip, function ()
                local downloaderExist = extension.isQQDownloaderInstalled("com.tencent.android.qqdownloader")
                if false == downloaderExist then
                    local jumpUrl = ""
                    if gt.isIOSPlatform() then
                        jumpUrl = "https://itunes.apple.com/cn/app/id1207542399"
                    else
                        jumpUrl = "http://a.app.qq.com/o/simple.jsp?pkgname=org.xianliao"
                    end
                    cc.Application:getInstance():openURL(jumpUrl)
                else
                    extension.jumpToQQDownloaderAndInstallApp("org.xianliao")
                end
            end, function ()
                openShareScene()
            end, false, nil, nil, moreTip)
        end
    elseif "dingding" == snsType then
        local exist = extension.isDingTalkInstalled()
        if true == exist then
            local valid = extension.isDingTalkSupportAPI()
            if true == valid then
                if nil == shareData.sharePreUrl then
                    shareData.sharePreUrl = previewImgUrl
                end
                extension.shareDingTalk(shareData) 
            else
                require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0105"), nil, nil, true)
            end
        else
            local noTip = gt.getLocationString("LTKey_0102")
            local moreTip = ""
            if gt.isAndroidPlatform() then
                noTip = noTip.."\n\n"
                moreTip = gt.getLocationString("LTKey_0107")
            end
            require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), noTip, function ()
                local downloaderExist = extension.isQQDownloaderInstalled("com.tencent.android.qqdownloader")
                if false == downloaderExist then
                    local jumpUrl = ""
                    if gt.isIOSPlatform() then
                        jumpUrl = "https://itunes.apple.com/cn/app/id930368978?mt=8"
                    else
                        jumpUrl = "http://a.app.qq.com/o/simple.jsp?pkgname=com.alibaba.android.rimet"
                    end
                    cc.Application:getInstance():openURL(jumpUrl)
                else
                    extension.jumpToQQDownloaderAndInstallApp("com.alibaba.android.rimet")
                end   
            end, function ()
                openShareScene()
            end, false, nil, nil, moreTip)
        end
    elseif "qq" == snsType then
        local qqExist = extension.isQQInstalled()
        if true == qqExist then
            if nil == shareData.previewImgUrl then
                shareData.previewImgUrl = previewImgUrl
            end
            extension.qqShareMsg(shareData, function(resp)
                gt.dump(resp, "qqShareMsg")
                if resp.code == "0" then
                    require("app/views/CommonTips"):create("分享成功!")
                end
            end)
        else
            local noTip = gt.getLocationString("LTKey_0108")
            local moreTip = ""
            if gt.isAndroidPlatform() then
                noTip = noTip.."\n\n"
                moreTip = gt.getLocationString("LTKey_0107")
            end
            require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), noTip, function ()
                local downloaderExist = extension.isQQDownloaderInstalled("com.tencent.android.qqdownloader")
                if false == downloaderExist then
                    local jumpUrl = ""
                    if gt.isIOSPlatform() then
                        jumpUrl = "https://itunes.apple.com/cn/app/qq/id444934666?mt=8"
                    else
                        jumpUrl = "http://a.app.qq.com/o/simple.jsp?pkgname=com.tencent.mobileqq"
                    end
                    cc.Application:getInstance():openURL(jumpUrl)
                else
                    extension.jumpToQQDownloaderAndInstallApp("com.tencent.mobileqq")
                end     
            end, function ()
                openShareScene()
            end, false, nil, nil, moreTip)
        end
    else
        gt.log("Ignored")
    end
end

function gt:setIMEStatus(status)
    cc.Director:getInstance():getOpenGLView():setIMEKeyboardState(status)
end

function gt:resetResLookup()
	local writePath = cc.FileUtils:getInstance():getWritablePath()
	local resSearchPaths = {
	    writePath,
	    writePath .. "src/",
	    writePath .. "res/",
	    "src/",
	    "res/"
	}
	cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)
	package.loaded["app/IntegratedResLookup"] = nil
end

function gt:addPlist(path)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(path)
end

--关闭字体设置效果
function gt:setNodeAllTextsFont(node)
--    if nil == node then return end
--    local children = node:getChildren()
--    for i=1, #children do
--        local desc = children[i]:getDescription()
--        if "Label" == desc then
--            children[i]:setFontName(gt.fontNormal)
--        elseif "TextField" == desc then
--            children[i]:setFontName("")
--        end
--        gt:setNodeAllTextsFont(children[i])
--    end
end

--关闭点击效果
function gt:playClickingEffects(target, path, needTrans)
    path = path or "effects/click/click.plist"
    local pos = target:getTouchBeganPosition()
    if needTrans then
        pos = target:convertToNodeSpace(pos)
    end
    local emitter = cc.ParticleSystemQuad:create(path)
	emitter:setPosition(pos)
    emitter:setName("touchingEffect")
	target:addChild(emitter)
	emitter:runAction(cc.Sequence:create(cc.DelayTime:create(0.8), cc.RemoveSelf:create()))
end

function gt:stopClickingEffects(target)
    local effector = target:getChildByName("touchingEffect")
    if nil ~= effector then
        effector:setVisible(false)
        effector:removeFromParent()
    end
end

--isIgnore:是否忽略维护预示结果,如果设为true，则只会在服务器物理已停机时给予提示
function gt:hasServerMaintainceNotice(owner, isIgnore)
    if gt.hasServerMaintainceNoticeDisplayed then
        return
    end

    gt.showLoadingTips("")

    if owner.xhr == nil then
        owner.xhr = cc.XMLHttpRequest:new()
        owner.xhr.timeout = 30 -- 设置超时时间
    end
    owner.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.SERVER_MAINTAIN_NOTICE_RE
    url = "http://"..gt.LoginServer.ip..":81/notice_get"

    owner.xhr:open("GET", url)
    owner.xhr:registerScriptHandler(function ()
        if owner.xhr.readyState == 4 and (owner.xhr.status >= 200 and owner.xhr.status < 207) then

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
            resultStr=resultStr..''
            return resultStr
        end

        require("json")
        local prepare, num = string.gsub(owner.xhr.response, "\\", "\\\\")
        local xhrParsedResp = json.decode(prepare)
        gt.dump(xhrParsedResp, "------------------xxxxxxxxxxxxxxxxxxxxx")
        if xhrParsedResp.open then
            if nil == isIgnore then
                owner.serverNoticeTitle = 0 < #xhrParsedResp.title and unicode_to_utf8(xhrParsedResp.title) or ""
                owner.serverNoticeBody = 0 < #xhrParsedResp.body and unicode_to_utf8(xhrParsedResp.body) or ""
                gt.log("---sziee#owner.serverNoticeBody__:"..#owner.serverNoticeBody)
                gt.log("---sziee_#owner.serverNoticeTitle_:"..#owner.serverNoticeTitle)
                if #owner.serverNoticeBody > 0 then
                    local agreementPanel = require("app/views/ServerNotice"):create(owner.serverNoticeTitle, owner.serverNoticeBody)
                    owner:addChild(agreementPanel, 6)
                    gt.hasServerMaintainceNoticeDisplayed = true
                end	            
            else
                gt.log("登陆时忽略")
            end
        else
            require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0054"), function ()
                cc.Director:getInstance():endToLua()
            end, nil, true)
        end

        elseif owner.xhr.readyState == 1 and owner.xhr.status == 0 then
            -- 网络问题,异常断开
            gt.removeLoadingTips()
        end
        owner.xhr:unregisterScriptHandler()
    end)
    owner.xhr:send()
end

function gt:talkingDataSendMethod(dataTable, methodName)
    if nil == dataTable or 0 == table.nums(dataTable) then
        return false
    end

    if cc.PLATFORM_OS_ANDROID == gt.targetPlatform or cc.PLATFORM_OS_IPHONE == gt.targetPlatform or cc.PLATFORM_OS_IPAD == gt.targetPlatform then
        if "accountAttrs" == methodName then
            TDGAAccount:setAccount(tostring(dataTable.accountId)) 
	        TDGAAccount:setAccountName(dataTable.accountName)
            if "wx" == dataTable.accountType then
                TDGAAccount:setAccountType(TDGAAccount.kAccountType1)
            else
                TDGAAccount:setAccountType(TDGAAccount.kAccountRegistered)
            end
        
            if 1 == dataTable.accountGender then
                TDGAAccount:setGender(TDGAAccount.kGenderMale)
            else
                TDGAAccount:setGender(TDGAAccount.kGenderFemale)
            end
        else
            TalkingDataGA:onEvent(dataTable.event, dataTable.data)
        end
    end
end

function gt:getUserCurUIStyle()
    local ui = 1
    local uiStyle = cc.UserDefault:getInstance():getStringForKey("UIStyle")
    if "classic" == uiStyle then
        ui = 2
    elseif "popular" == uiStyle then
        ui = 1
    end
    return ui
end

function gt:loadMainPageSettings()
--    gt.dump(gt.hallSettings, "---------------------loadMainPageSettings------before---------------")
    if "" ~= cc.UserDefault:getInstance():getStringForKey("Language") then gt.hallSettings.Language = cc.UserDefault:getInstance():getStringForKey("Language") end
    if "" ~= cc.UserDefault:getInstance():getStringForKey("MusicBgVolume") then gt.hallSettings.MusicBgVolume = cc.UserDefault:getInstance():getStringForKey("MusicBgVolume") end
    if "" ~= cc.UserDefault:getInstance():getStringForKey("SoundEftVolume") then gt.hallSettings.SoundEftVolume = cc.UserDefault:getInstance():getStringForKey("SoundEftVolume") end
    if "" ~= cc.UserDefault:getInstance():getStringForKey("Vibrate") then gt.hallSettings.Vibrate = cc.UserDefault:getInstance():getStringForKey("Vibrate") end
    if "" ~= cc.UserDefault:getInstance():getStringForKey("Voice") then gt.hallSettings.Voice = cc.UserDefault:getInstance():getStringForKey("Voice") end
    if "" ~= cc.UserDefault:getInstance():getStringForKey("UIStyle") then gt.hallSettings.UIStyle = cc.UserDefault:getInstance():getStringForKey("UIStyle") end
--    gt.dump(gt.hallSettings, "---------------------loadMainPageSettings-------after--------------")
end

function gt:isUsingOldUI()
    return "popular" == gt.hallSettings.UIStyle
end

function gt:formatVoiceLanguagePath(sex)
    require("app/NiuNiuIntegratedResLookup")
    local RES_NIUNIU = cc.exports.RES_NIUNIU
    local isLocalOrCommon = gt:isLocalOrCommonLanguage()
    local path = ""
    --男声
    if 1 == sex then
        path = isLocalOrCommon and RES_NIUNIU.SOUND.LOCAL_MALE_PREFIX or RES_NIUNIU.SOUND.COMMON_MALE_PREFIX
    --女声
    elseif 2 == sex then
        path = isLocalOrCommon and RES_NIUNIU.SOUND.LOCAL_FEMALE_PREFIX or RES_NIUNIU.SOUND.COMMON_FEMALE_PREFIX
    end
    return path
end

--是方言，还是普通话
--true  方言
--false 普通话
function gt:isLocalOrCommonLanguage()
    local isLocalOrCommon = nil ~= gt.roomDeskSettings and 1 == gt.roomDeskSettings.voiceFlag
    return isLocalOrCommon
end

function gt:nonBtnPlaySoundEffect()
    if "on" == gt.hallSettings.SoundEftVolume and gt.roomDeskSettings and gt.roomDeskSettings.soundFlag then gt.soundEngine:playEffect(gt.clickBtnAudio, false) end
end

function gt:disableSwallowTouches(root, excepts)
    assert(root ~= nil)
    local children = root:getChildren()
    for k,v in ipairs(children) do
        local name = v:getName()
        
        if nil ~= excepts[name] then
            v:setSwallowTouches(true)
        end
--        if nil == excepts[name] then
--            v:setSwallowTouches(false)
--        else
--            v:setSwallowTouches(true)
--        end
        self:disableSwallowTouches(v, excepts)
    end
end
function gt:disableNodeZoomMode(root, excepts)
    assert(root ~= nil)
    local children = root:getChildren()
    for k,v in ipairs(children) do
        local generic = v:getDescription()
        local name = v:getName()
        if ("CheckBox" == generic or "Button" == generic) and (nil == excepts[name]) then
            v:setZoomScale(0)
        end
        self:disableNodeZoomMode(v, excepts)
    end
end

function gt:getChineseNumFromDidigNum(num)
    local trans = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
    local getTrans = function (num)
        if "number" ~= type(num) then
            return ""
        end

        if 0 == num then
            return "零"
        end

        if num <= 10 then
            return trans[num]
        elseif num < 20 then
            return "十"..trans[num%10]
        elseif num == 20 then
            return "二十"
        elseif num < 30 then
            return "二十"..trans[num%20]
        elseif num == 30 then
            return "三十"
        end
    end
    return getTrans(num)
end

function gt:loadSavedNiuNiuRoomDeskSettings()
    require("json")
    local roomDeskSettings = cc.UserDefault:getInstance():getStringForKey("roomDeskSettings", "")
	if(roomDeskSettings ~= "") then
        gt.roomDeskSettings = json.decode(roomDeskSettings)
        gt.dump(gt.roomDeskSettings, "NiuNiuRoomSettings:loadSavedConfigs")
    else
        gt.log("房间牌桌设置未设置")
	end
end

function gt:adjustSpecialResolution(node)
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
end

function gt:adjustSceneDisplay(node)
    assert(node ~= nil)
	node:setAnchorPoint(0.5, 0.5)
	node:setPosition(gt.winCenter)
    node:setContentSize(gt.winSize)
    ccui.Helper:doLayout(node)
end

function gt:countChildrenNodeNum(node)
    assert(node ~= nil)
    local children = node:getChildren()
    local count = 0
    for k,v in ipairs(children) do
        count = count + 1
    end
    return count
end

local function isIpadPlatform()
    return cc.PLATFORM_OS_IPAD == gt.targetPlatform
end
gt.isIpadPlatform = isIpadPlatform

local function isIOSPlatform()
	return (cc.PLATFORM_OS_IPHONE == gt.targetPlatform) or (cc.PLATFORM_OS_IPAD == gt.targetPlatform)
end
gt.isIOSPlatform = isIOSPlatform

local function isAndroidPlatform()
	return cc.PLATFORM_OS_ANDROID == gt.targetPlatform
end
gt.isAndroidPlatform = isAndroidPlatform

local function isIOSReview()
	if gt.isInReview == true and gt.isIOSPlatform() then
		return true
	end
	return false
end
gt.isIOSReview = isIOSReview

local function isValidPhoneFormat(phone)
	return phone == "" or #phone ~= 11 or tonumber(phone) == nil
end
gt.isValidPhoneFormat = isValidPhoneFormat

local function getDeviceId()
	if isIOSPlatform() then
		return "IOS"
	elseif isAndroidPlatform() then
		return "ANDROID"
	else
		return "OTHER"
	end
end
gt.getDeviceId = getDeviceId


local function getAppVersionStr()
    if isAndroidPlatform() then
        return "V"..(gt.resVersion ~= nil and gt.resVersion or gt.defaultAppVerAnd)
    else
        return "v"..(gt.resVersion ~= nil and gt.resVersion or gt.defaultAppVerIos)
    end
end
gt.getAppVersionStr = getAppVersionStr

-- start --
--------------------------------
-- @class function pushLayer
-- @description 用于界面有压栈层关系处理
-- @param layer 要压入的层
-- @param visible 当前层是否需要隐藏,默认是隐藏
-- @param zorder 压入层z值
-- @param rootLayer 压入层要加入到的父层
-- @return
-- end --
local function pushLayer(layer, visible, rootLayer, zorder)
	local layersStack = gt.layersStack
	local curLayer = layersStack[#layersStack]
	if curLayer and not visible then
		curLayer:setVisible(false)
	end

	-- 插入到栈顶
	table.insert(layersStack, layer)

	local zorder = zorder or 1
	if rootLayer then
		rootLayer:addChild(layer, zorder)
	else
		local runningScene = display.getRunningScene()
		if runningScene then
			runningScene:addChild(layer, zorder)
		end
	end
end
gt.pushLayer = pushLayer

-- start --
--------------------------------
-- @class function popLayer
-- @description 弹出当前层,从父节点移除,调用lua的destroy析构函数
-- @return
-- end --
local function popLayer()
	local layersStack = gt.layersStack
	if #layersStack > 0 then
		-- 从栈顶移除
		local layer = table.remove(layersStack, #layersStack)
		if layer then
			layer:removeFromParent(true)
			if layer.destroy then
				layer:destroy()
			end
		end

		-- 显示栈顶层
		local curLayer = layersStack[#layersStack]
		if curLayer then
			curLayer:setVisible(true)
		end
	end
end
gt.popLayer = popLayer

-- start --
--------------------------------
-- @class function registerEventListener
-- @description 注册事件回调
-- @param eventType 事件类型
-- @param target 实例
-- @param method 方法
-- @return
-- gt.registerEventListener(2, self, self.eventLis)
-- end --
local function registerEventListener(eventType, target, method)
	if not eventType or not target or not method then
		return
	end

	local eventsListener = gt.eventsListener
	local listeners = eventsListener[eventType]
	if not listeners then
		-- 首次添加eventType类型事件，新建消息存储列表
		listeners = {}
		eventsListener[eventType] = listeners
	else
		-- 检查重复添加
		for _, listener in ipairs(listeners) do
			if listener[1] == target and listener[2] == method then
				return
			end
		end
	end

	-- 加入到事件列表中
	local listener = {target, method}
	table.insert(listeners, listener)
end
gt.registerEventListener = registerEventListener

-- start --
--------------------------------
-- @class function dispatchEvent
-- @description 分发eventType事件
-- @param eventType 事件类型
-- @param ... 调用者传递的参数
-- @return
-- end --
local function dispatchEvent(eventType, ...)
	if not eventType then
		return
	end
	local listeners = gt.eventsListener[eventType] or {}
	for _, listener in ipairs(listeners) do
		-- 调用注册函数
		listener[2](listener[1], eventType, ...)
	end
end
gt.dispatchEvent = dispatchEvent

-- start --
--------------------------------
-- @class function removeTargetEventListenerByType
-- @description 移除target注册的事件
-- @param target self
-- @param eventType 消息类型
-- @return
-- end --
local function removeTargetEventListenerByType(target, eventType)
	if not target or not eventType then
		return
	end

	-- 移除target的注册的eventType类型事件
	local listeners = gt.eventsListener[eventType] or {}
	for i, listener in ipairs(listeners) do
		if listener[1] == target then
			table.remove(listeners, i)
		end
	end
end
gt.removeTargetEventListenerByType = removeTargetEventListenerByType

-- start --
--------------------------------
-- @class function removeTargetAllEventListener
-- @description 移除target的注册的全部事件
-- @param target self
-- @return
-- end --
local function removeTargetAllEventListener(target)
	if not target then
		return
	end

	-- 移除target注册的全部事件
	for _, listeners in pairs(gt.eventsListener) do
		for i, listener in ipairs(listeners) do
			if listener[1] == target then
				table.remove(listeners, i)
			end
		end
	end
end
gt.removeTargetAllEventListener = removeTargetAllEventListener

-- start --
--------------------------------
-- @class function removeAllEventListener
-- @description 移除全部消息注册回调
-- @return
-- end --
local function removeAllEventListener()
	gt.eventsListener = {}
end
gt.removeAllEventListener = removeAllEventListener

-- start --
--------------------------------
-- @class function
-- @description 加载csb文件,遍历查找Label和Button设置设定的语言文本
-- @param csbFileName 文件名称
-- @return 创建的节点
-- end --
local function createCSNode(csbFileName, isScale)
	local csbNode = cc.CSLoader:createNode(csbFileName)

	if isScale then
		csbNode:setScale(gt.scaleFactor)
	end

	-- 检查是否符合规定写法名称Label_xxx_key Txt_xxx_key
	local function setSpecifyLabelString(labelName, specifyLable)
		local subStrs = string.split(labelName, "_")
		local prefix = subStrs[1]
		local suffix = subStrs[#subStrs]
		if prefix == "Label" or prefix == "Txt" then
			local strKey = "LTKey_" .. suffix
			local ltString = gt.getLocationString(strKey)
			if ltString ~= strKey then
				-- 本地语言字符串存在设置文本
				specifyLable:setString(ltString)
			end
		end
	end

	-- 遍历节点
	local function travelLabelNode(rootNode)
		if not rootNode then
			return
		end

		local nodeName = rootNode:getName()
		setSpecifyLabelString(nodeName, rootNode)

		local children = rootNode:getChildren()
		if not children or #children == 0 then
			return
		end
		for _, childNode in ipairs(children) do
			travelLabelNode(childNode)
		end

		return
	end

	-- travelLabelNode(csbNode)

	return csbNode
end
gt.createCSNode = createCSNode

-- start --
--------------------------------
-- @class function createCSAnimation
-- @description 创建csb文件编辑的动画
-- @param csbFileName 文件路径名称
-- @return node, action 创建的节点和动画
-- end --
local function createCSAnimation(csbFileName, isScale)
	local csbNode = cc.CSLoader:createNode(csbFileName)
	local action = cc.CSLoader:createTimeline(csbFileName)
	csbNode:runAction(action)

	if isScale then
		csbNode:setScale(gt.scaleFactor)
	end

	return csbNode, action
end
gt.createCSAnimation = createCSAnimation

-- start --
--------------------------------
-- @class function seekNodeByName
-- @description 深度遍历查找节点
-- @param rootNode 根节点
-- @param nodeName 查找节点名称
-- @return 查找到的节点
-- end --
local function seekNodeByName(rootNode, name)
	if not rootNode or not name then
		return nil
	end

	if rootNode:getName() == name then
		return rootNode
	end

	local children = rootNode:getChildren()
	if not children or #children == 0 then
		return nil
	end
	for i, parentNode in ipairs(children) do
		local childNode = seekNodeByName(parentNode, name)
		if childNode then
			return childNode
		end
	end

	return nil
end
gt.seekNodeByName = seekNodeByName

local function showLoadingTips(tipsText)
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		local loadingTips = runningScene:getChildByName("LoadingTips")
		if loadingTips then
            loadingTips:setTipsText(tipsText)
			return
		end
	end

	require("app/views/LoadingTips"):create(tipsText)
end
gt.LOADING_TIPPING_MODE = "mode_unvisible"
gt.showLoadingTips = showLoadingTips

local function removeLoadingTips(desc)
	local runningScene = cc.Director:getInstance():getRunningScene()
	if runningScene then
		local loadingTips = runningScene:getChildByName("LoadingTips")
		if loadingTips and true ~= loadingTips:isUnvisibleLockOn() then
            loadingTips:removeFromParent()
            loadingTips = nil
		end

        if loadingTips and desc == gt.LOADING_TIPPING_MODE then
            loadingTips:removeFromParent()
            loadingTips = nil
		end

        local name = runningScene:getName()
        local names = {
            PDKPlayScene = true,
            HHDDZPlayScene = true,
            ZZMJPlayScene = true,
            KLMJPlayScene = true
        }
        if loadingTips and true == names[name] then
            loadingTips:removeFromParent()
            loadingTips = nil
		end
	end
end
gt.removeLoadingTips = removeLoadingTips

-- start --
--------------------------------
-- @class function
-- @description 获取节点的世界坐标
-- @param node 节点
-- @return 世界坐标
-- end --
local function getWorldPos(node)
	if not node:getParent() then
		return cc.p(node:getPosition())
	end

	local nodeList = {}
	while node do
		-- 遍历节点,存储所有父节点
		table.insert(nodeList, node)
		node = node:getParent()
	end
	-- 移除Scene节点/世界坐标是基于Scene节点
	table.remove(nodeList, #nodeList)

	local worldPosition = cc.p(0, 0)
	for i, node in ipairs(nodeList) do
		local nodePosition = cc.p(node:getPosition())
		local idx = i + 1
		if idx <= #nodeList then
			-- 累加父节点锚点相对位置
			local parentNode = nodeList[idx]
			local parentSize = parentNode:getContentSize()
			local parentAnchor = parentNode:getAnchorPoint()
			local anchorPosition = cc.p(parentSize.width * parentAnchor.x, parentSize.height * parentAnchor.y)
			local subPosition = cc.pSub(nodePosition, anchorPosition)
			worldPosition = cc.pAdd(worldPosition, subPosition)
		else
			-- +最后父节点位置
			worldPosition = cc.pAdd(worldPosition, nodePosition)
		end
	end

	return worldPosition
end
gt.getWorldPos = getWorldPos

-- start --
--------------------------------
-- @class function
-- @description 创建ttfLabel
-- @param text 文本内容
-- @param fontSize 字体大小
-- @param font 字体名称
-- @return ttfLabel
-- end --
local function createTTFLabel(text, fontSize, font)
	text = text or ""
	font = font or gt.fontNormal
	fontSize = fontSize or 18

	local ttfConfig = {}
	ttfConfig.fontFilePath = font
	ttfConfig.fontSize = fontSize
	local ttfLabel = cc.Label:createWithSystemFont(text, "Arial", fontSize)

	return ttfLabel
end
gt.createTTFLabel = createTTFLabel

-- start --
--------------------------------
-- @class function
-- @description 文本描边颜色outline
-- @param ttfLabel 要被设置描边的文本控件
-- @param color cc.c4b颜色
-- @param size int像素Size
-- @return
-- end --
local function setTTFLabelStroke(ttfLabel, color, size)
	if not ttfLabel then
		return
	end

	color = color or cc.c4b(27, 27, 27, 255)
	size = size or 1

	ttfLabel:enableOutline(color, size)
end
gt.setTTFLabelStroke = setTTFLabelStroke

-- start --
--------------------------------
-- @class function
-- @description 文本阴影
-- @param ttfLabel 要被设置阴影的文本控件
-- @param color cc.c4b颜色
-- @param offset Size偏移量cc.size(2, -2)
-- @return
-- end --
local function setTTFLabelShadow(ttfLabel, color, offset)
	if not ttfLabel then
		return
	end

	ttfLabel:enableShadow(color, offset, 0)
end
gt.setTTFLabelShadow = setTTFLabelShadow

-- start --
--------------------------------
-- @class function
-- @description 统一打印日志
-- @param msg 日志信息
-- @return
-- end --

local function log(msg, ...)
	if not gt.debugMode then
		return
	end
	-- local traceback = string.split(debug.traceback("", 2), "\n")
	-- print("print from:[" .. string.trim(traceback[3]) .. "]\n---------:" .. msg)
	msg = msg .. " "
	local args = {...}
	for i,v in ipairs(args) do
		msg = msg .. tostring(v) .. " "
	end
	print(os.date("%Y-%m-%d %H:%M:%S") .. "------lua log:" .. msg)
    if gt.isAndroidPlatform() then
        local dateStr = os.date("%Y-%m-%d")
        local testlogfile = "/mnt/sdcard/AYaowanKLDS/"..dateStr..".log"
        if not cc.FileUtils:getInstance():isDirectoryExist("/mnt/sdcard/AYaowanKLDS/") then
            os.execute("mkdir -p /mnt/sdcard/AYaowanKLDS/")
        end
        io.writefile(testlogfile,os.date("%Y-%m-%d %H:%M:%S") .. msg.."\n","a+")
    end
    if gt.mj_log ~= nil then
        table.insert(gt.mj_log, os.date("%Y-%m-%d %H:%M:%S") .. "------lua log:" .. msg)
    end
end
gt.log = log

-- start --
--------------------------------
-- @class function
-- @description 用当前时间反置设置随机数种子
-- @return
-- end --
local function setRandomSeed()
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
end
gt.setRandomSeed = setRandomSeed

-- start --
--------------------------------
-- @class function
-- @description 获取 [minVar, maxVar] 区间随机值
-- @param minVar 最小值
-- @param maxVar 最大值
-- @return 区间随机值
-- end --
local function getRangeRandom(minVar, maxVar)
	if minVar == maxVar then
		return minVar
	end

	return math.floor((math.random() * 1000000)) % (maxVar - minVar + 1) + minVar
end
gt.getRangeRandom = getRangeRandom

-- start --
--------------------------------
-- @class function
-- @description 获取 table内的随机值
-- @return 区间随机值
---- end --
--local function getRangeRandom(tbl)

--	return math.floor((math.random() * 1000000)) % (maxVar - minVar + 1) + minVar
--end
--gt.getRangeRandom = getRangeRandom


-- start --
--------------------------------
-- @class function
-- @description 重载cocos提供的弧度转换角度
-- @param radian 弧度
-- @return 角度
-- end --
function math.radian2angle(radian)
	return radian * 57.29577951
end

-- start --
--------------------------------
-- @class function
-- @description 重载cocos提供的角度转换弧度
-- @param angle 角度
-- @return 弧度
-- end --
function math.angle2radian(angle)
	return angle * 0.01745329252
end

function string.lastString(input, pattern)
	local idx = 1
	local saveIdx = nil
	while true do
		idx = string.find(input, pattern, idx)
		if idx == nil then
			break
		else
			saveIdx = idx
			idx = idx + 1
		end
	end

	return saveIdx
end

-- start --
--------------------------------
-- @class function
-- @description 震动节点
-- @param node 震动节点
-- @param time 持续时间
-- @param originPos 节点原始位置,为了防止多次shake后节点位置错位
-- @return
-- end --
local function shakeNode(node, time, originPos, offset)
	local duration = 0.03
	if not offset then
		offset = 6
	end
	-- 一个震动耗时4个duration左,复位,右,复位
	-- 同时左右和上下震动
	local times = math.floor(time / (duration * 4))
	local moveLeft = cc.MoveBy:create(duration, cc.p(-offset, 0))
	local moveLReset = cc.MoveBy:create(duration, cc.p(offset, 0))
	local moveRight = cc.MoveBy:create(duration, cc.p(offset, 0))
	local moveRReset = cc.MoveBy:create(duration, cc.p(-offset, 0))
	local horSeq = cc.Sequence:create(moveLeft, moveLReset, moveRight, moveRReset)
	local moveUp = cc.MoveBy:create(duration, cc.p(0, offset))
	local moveUReset = cc.MoveBy:create(duration, cc.p(0, -offset))
	local moveDown = cc.MoveBy:create(duration, cc.p(0, -offset))
	local moveDReset = cc.MoveBy:create(duration, cc.p(0, offset))
	local verSeq = cc.Sequence:create(moveUp, moveUReset, moveDown, moveDReset)
	node:runAction(cc.Sequence:create(cc.Repeat:create(cc.Spawn:create(horSeq, verSeq), times), cc.CallFunc:create(function()
		node:setPosition(originPos)
	end)))
end
gt.shakeNode = shakeNode

-- start --
--------------------------------
-- @class function
-- @description 给BUTTON注册触屏事件
-- @param btn 注册按钮
-- @param listener 注册事件回调
-- @param sfx 音效文件路径(根目录是sound 不带后缀)
-- @param sex 性别1男，2女 如果声音分性别sfx直接传音效名就行
-- end --
local function addBtnPressedListener(btn, listener, sfx, sex)
	if not btn or not listener then
		gt.log("!!!addBtnPressedListener btn=null!!!")
        return
	end

    if sfx ~= nil and string.len(sfx) > 0 then
        if(sex ~= nil) then
            if sex == 1 then
                sfx = "man/"..sfx
            elseif sex == 2 then
                sfx = "woman/"..sfx
            end
        end
    else
        sfx = gt.clickBtnAudio
    end

    ScriptHandlerMgr:getInstance():removeObjectAllHandlers(btn)
	btn:addTouchEventListener(function (sender, event)
        if TOUCH_EVENT_ENDED == event then
            listener(sender)
            if sfx ~= nil and string.len(sfx) > 0 then
			    if "on" == gt.hallSettings.SoundEftVolume then
                    gt.soundEngine:playEffect(sfx, false)
                end
            end
        elseif TOUCH_EVENT_BEGAN == event then
            --nothing
        end
	end)
end
gt.addBtnPressedListener = addBtnPressedListener

-- start --
--------------------------------
-- @class function
-- @description 创建shader
-- @param shaderName 名称
-- @return 创建的shaderState
-- end --
local function createShaderState(shaderName)
	local shaderProgram = cc.GLProgramCache:getInstance():getGLProgram(shaderName)
	if not shaderProgram then
		shaderProgram = cc.GLProgram:createWithFilenames(string.format("shader/%s.vsh", shaderName), string.format("shader/%s.fsh", shaderName))
		cc.GLProgramCache:getInstance():addGLProgram(shaderProgram, shaderName)
	end
	local shaderState = cc.GLProgramState:getOrCreateWithGLProgram(shaderProgram)

	return shaderState
end
gt.createShaderState = createShaderState

-- start --
--------------------------------
-- @class function
-- @description 弹出panel节点的动画效果
-- @param panel 要进行动画展示的节点
-- @return
-- end --
local function popupPanelAnimation(panel, cbFunc)
	assert(panel, "panel should not be nil.")
	local nowScale = panel:getScale()
	panel:setScale(0)
	local action = cc.ScaleTo:create(0.2, nowScale)
	action = cc.EaseBackOut:create(action)
	if not cbFunc then
		panel:runAction(action)
	else
		local callFunc = cc.CallFunc:create(cbFunc)
		local seqAction = cc.Sequence:create(action, callFunc)
		panel:runAction(seqAction)
	end
end
gt.popupPanelAnimation = popupPanelAnimation

-- start --
--------------------------------
-- @class function
-- @description 隐藏panel节点的动画效果，同时remove掉panel所在的父节点
-- @param panel 要进行动画隐藏效果的节点
-- @return
-- end --
local function removePanelAnimation(panel, isHide)
	assert(panel, "panel and parentMaskLayer should not be nil.")
	local action = cc.ScaleTo:create(0.2, 0)
	action = cc.EaseBackIn:create(action)
	local sequence = cc.Sequence:create(action, cc.CallFunc:create(function()
		if isHide then
			panel:setVisible(false)
		else
			panel:removeFromParent(true)
		end
	end))
	panel:runAction(sequence)
end
gt.removePanelAnimation = removePanelAnimation

-- start --
--------------------------------
-- @class function
-- @description 创建触摸屏蔽层
-- @param opacity 触摸屏的透明图
-- @return 屏蔽层
-- end --
local function createMaskLayer(opacity)
	if not opacity then
		-- 用默认透明度
		opacity = gt.MASK_LAYER_OPACITY
	end

	local maskLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, opacity), gt.winSize.width, gt.winSize.height)
	local function onTouchBegan(touch, event)
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:setSwallowTouches(true)
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	local eventDispatcher = maskLayer:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, maskLayer)

	return maskLayer
end
gt.createMaskLayer = createMaskLayer

-- start --
--------------------------------
-- @class function
-- @description 获取蒙版剪切精灵
-- @param sprFrameName 需要剪切图片的名称
-- @param isCircle 圆形或者矩形,默认是矩形
-- @return
-- end --
local function getMaskClipSprite(fileName, isCircle, frameAdapt)
    local frameSpr = cc.Sprite:create(fileName)
    local maskName = "image/Common/circle_icon_mask.png" --"rect_icon_mask.png"
	if isCircle then
		maskName = "image/Common/circle_icon_mask.png"
	end 
    local clipMaskSpr = cc.Sprite:create(maskName)
	local maskSize = clipMaskSpr:getContentSize()
	if frameAdapt then
		local frameSize = frameSpr:getContentSize()
		frameSpr:setScale(maskSize.width / frameSize.width)
	end
    frameSpr:setPosition(maskSize.width * 0.5, maskSize.height * 0.5)
	clipMaskSpr:setPosition(maskSize.width * 0.5, maskSize.height * 0.5)
	local renderTexture = cc.RenderTexture:create(maskSize.width, maskSize.height)
	clipMaskSpr:setBlendFunc(cc.blendFunc(gl.ZERO, gl.SRC_ALPHA))
	renderTexture:begin()
	frameSpr:visit()
	clipMaskSpr:visit()
	renderTexture:endToLua()
	local clipSpr = cc.Sprite:createWithTexture(renderTexture:getSprite():getTexture())
	clipSpr:setScaleY(-1)
	return clipSpr
end

gt.getMaskClipSprite = getMaskClipSprite

-- start --
--------------------------------
-- @class function
-- @description 创建扫光动态效果精灵
-- @param targetSpr 目标精灵
-- @param lightSpr 光柱精灵
-- @return 扫光动态效果精灵
-- end --
local function createTraverseLightSprite(targetSpr, lightSpr)
	targetSpr:removeFromParent()
	targetSpr:setPosition(0, 0)
	lightSpr:removeFromParent()
	lightSpr:setPosition(0, 0)
	local clippingNode = cc.ClippingNode:create()
	clippingNode:setStencil(targetSpr)
	clippingNode:setAlphaThreshold(0)

	local contentSize = targetSpr:getContentSize()
	clippingNode:addChild(targetSpr:clone())
	lightSpr:setPosition(-contentSize.width * 0.5,0)
	clippingNode:addChild(lightSpr)

	local moveAction = cc.MoveTo:create(1, cc.p(contentSize.width, 0))
	local delayTime = cc.DelayTime:create(1)
	local callFunc = cc.CallFunc:create(function(sender)
		sender:setPosition(-contentSize.width, 0)
	end)
	local sequenceAction = cc.Sequence:create(moveAction, delayTime, callFunc)
	local repeatAction = cc.RepeatForever:create(sequenceAction)
	lightSpr:runAction(repeatAction)

	return clippingNode
end
gt.createTraverseLightSprite = createTraverseLightSprite

-- start --
--------------------------------
-- @class function
-- @description 是否在屏幕上显示,遍历父节点有隐藏的情况
-- @return false:隐藏 true:显示
-- end --
local function isDisplayVisible(node)
	while node do
		if not node:isVisible() then
			return false
		end

		node = node:getParent()
	end

	return true
end
gt.isDisplayVisible = isDisplayVisible

-- start --
--------------------------------
-- @class function
-- @description 为避免货币位数过多导致显示不下，修改数字格式
-- @param num 要换算的数字，应为数字型
-- @return 1,000,000及以上的数字显示以K为单位换算后的字符串，1,000,000以下仍返回原值
-- end --
local function convertNumberForShort(num)
	assert(type(num) == "number", "the parameter should be numeric.")
	if num < 1000000 then
		return num
	else
		return math.floor(num * 0.001) .. "K"
	end
end
gt.convertNumberForShort = convertNumberForShort

-- start --
--------------------------------
-- @class function
-- @description 将时间以"HH:MM:SS"或者"MM:SS"的格式返回，不满两位填充0
-- @param deltaTime 要被转化的时间，以秒为单位；应为数字型，正负数皆可
-- @return 格式化的时间，字符串形式
-- end --
local function convertTimeSpanToString(deltaTime)
	assert(type(deltaTime) == "number", "the parameter should be numeric.")

	-- 那必须先四舍五入取整，否则会出现 -00：00：00 的情况
	deltaTime = math.round(deltaTime)

	local timeConversion = 60

	local timePrefix = ""
	if deltaTime < 0 then
		timePrefix = "-"
		deltaTime = -deltaTime
	end

	local hStr = math.floor(deltaTime / (timeConversion * timeConversion))
	deltaTime = deltaTime - timeConversion * timeConversion * hStr
	local mStr = math.floor(deltaTime / timeConversion)
	local sStr = math.floor(deltaTime - timeConversion * mStr)

	if hStr == 0 then
		return string.format("%s%02s:%02s", timePrefix, mStr, sStr)
	end

	return string.format("%s%02s:%02s:%02s", timePrefix, hStr, mStr, sStr)
end
gt.convertTimeSpanToString = convertTimeSpanToString

-- start --
--------------------------------
-- @class function
-- @description 将本地时间以字符串的格式返回
-- @param deltaTime 目标时间与当前本地时间的差值。单位秒，正数为未来，负数为过去
-- @return 格式化的时间，字符串形式，AM/PM+HH:MM:SS
-- end --
local function getLocalTimeSpanStr(deltaTime)
	if not deltaTime then deltaTime = 0 end

	local targetTime = os.time() + deltaTime
	local timeTbl = os.date("*t", targetTime)

	if timeTbl.hour > 12 then
		return string.format("PM %02d:%02d:%02d", timeTbl.hour - 12, timeTbl.min, timeTbl.sec)
	else
		return string.format("AM %02d:%02d:%02d", timeTbl.hour, timeTbl.min, timeTbl.sec)
	end
end
gt.getLocalTimeSpanStr = getLocalTimeSpanStr

local function dump_value_(v)
	if type(v) == "string" then
		v = "\"" .. v .. "\""
	end
	return tostring(v)
end

function dump(value, desciption, nesting)
	if not gt.debugMode then
		return
	end

	if type(nesting) ~= "number" then nesting = 6 end

	local lookupTable = {}
	local result = {}

	local traceback = string.split(debug.traceback("", 2), "\n")
	gt.log("dump from: " .. string.trim(traceback[3]))

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"
		local spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result +1 ] = string.format("%s%s = {", indent, dump_value_(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = dump_value_(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	dump_(value, desciption, "- ", 1)

	for i, line in ipairs(result) do
		gt.log(line)
	end
end
gt.dump = dump

local function countStrLen(str)
    if 0 == #str then
        return 0, false
    end

    local retStr = ""
    local num = 0
    local lenInByte = #str
    local x = 1
    local isFullZhCn = true
    for i=1,lenInByte do
		i = x
	    local curByte = string.byte(str, x)
	    local byteCount = 1
	    if curByte>0 and curByte<=127 then
	        byteCount = 1
            isFullZhCn = false
	    elseif curByte>127 and curByte<240 then
	        byteCount = 3
	    elseif curByte>=240 and curByte<=247 then
	        byteCount = 4
	    end
        local curStr = string.sub(str, i, i+byteCount-1)
	    retStr = retStr .. curStr
	    x = x + byteCount
        num = num + 1
        if x > lenInByte then
	    	return num, isFullZhCn
	    end
    end
    return num, isFullZhCn
end
gt.countStrLen = countStrLen

local function containCNAndAlphabet(str)
    local retStr = ""
    local num = 0
    local lenInByte = #str
    local x = 1
    local hasCN = false
    for i=1,lenInByte do
		i = x
	    local curByte = string.byte(str, x)
	    local byteCount = 1
	    if curByte>0 and curByte<=127 then
	        byteCount = 1
            if curByte >= 48 and curByte <= 57 then
                hasCN = false
            else
                hasCN = true
                return hasCN
            end
	    elseif curByte>127 and curByte<240 then
	        byteCount = 3
            hasCN = true
            return hasCN
	    elseif curByte>=240 and curByte<=247 then
	        byteCount = 4
            hasCN = true
            return hasCN
	    end
        local curStr = string.sub(str, i, i+byteCount-1)
        retStr = retStr .. curStr
	    x = x + byteCount
        num = num + 1
    end
    return hasCN
end
gt.containCNAndAlphabet = containCNAndAlphabet

local function checkName( str, limit )
	local retStr = ""

    if nil == str then
        return retStr
    end

	local num = 0
	local lenInByte = #str
	local x = 1
	limit = limit or 8
	for i=1,lenInByte do
		i = x
	    local curByte = string.byte(str, x)
	    local byteCount = 1;
	    if curByte>0 and curByte<=127 then
	        byteCount = 1
	    elseif curByte>127 and curByte<240 then
	        byteCount = 3
	    elseif curByte>=240 and curByte<=247 then
	        byteCount = 4
	    end
	    local curStr = string.sub(str, i, i+byteCount-1)
	    retStr = retStr .. curStr
	    x = x + byteCount
	    if x > lenInByte then
	    	return retStr
	    end
	    num = num + 1
	    if num >= limit then
	    	return retStr..".."
	    end
    end

    return retStr
end
gt.checkName = checkName

local function checkName2( str, numChars )
	local function chSize(char)
        if not char then
            return 0
        elseif char > 0 and char <= 127 then
            return 1
        elseif char >= 192 and char <= 223 then
            return 2
        elseif char >= 224 and char <= 239 then
            return 3
        elseif char >= 240 and char <= 247 then
            return 4
        end
    end
    numChars = numChars or 8
    local startIndex = 1
    local currentIndex = 1
    while numChars > 0 and currentIndex <= #str do
        local char = string.byte(str, currentIndex)
        currentIndex = currentIndex + chSize(char)
        numChars = numChars - 1
    end
    return str:sub(startIndex, currentIndex - 1)
end
gt.checkName2 = checkName2


-- start --
--------------------------------
-- @class function
-- @description 文本描边颜色outline
-- @param ttfLabel 要被设置描边的文本控件
-- @param color cc.c4b颜色
-- @param size int像素Size
-- @return
-- end --
local function setTTFLabelStroke(ttfLabel, color, size)
	if not ttfLabel then
		return
	end

	color = color or cc.c4b(27, 27, 27, 255)
	size = size or 1

	ttfLabel:enableOutline(color, size)
end
gt.setTTFLabelStroke = setTTFLabelStroke


-- start --
--------------------------------
-- @class function floatText
-- @description 浮动文本
-- @param content 内容
-- @return
-- end --
gt.golbalZOrder = 10000
local function floatText(content)
	if not content or content == "" then
		return
	end

	local offsetY = 20
	local rootNode = cc.Node:create()
	rootNode:setPosition(cc.p(gt.winCenter.x, gt.winCenter.y - offsetY))

	local bg = cc.Scale9Sprite:create("res/images/otherImages/float_text_bg.png")
	local capInsets = cc.size(200, 5)
	local textWidth = bg:getContentSize().width - capInsets.width * 2
	bg:setScale9Enabled(true)
	bg:setCapInsets(cc.rect(capInsets.width, capInsets.height, bg:getContentSize().width - capInsets.width, bg:getContentSize().height - capInsets.height))
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	bg:setGlobalZOrder(gt.golbalZOrder)
	gt.golbalZOrder = gt.golbalZOrder + 1
	rootNode:addChild(bg)

	local ttfConfig = {}
	ttfConfig.fontFilePath = gt.fontNormal
	ttfConfig.fontSize = 38
	local ttfLabel = cc.Label:createWithTTF(ttfConfig, content)
	ttfLabel:setGlobalZOrder(gt.golbalZOrder)
	gt.golbalZOrder = gt.golbalZOrder + 1
	ttfLabel:setTextColor(cc.YELLOW)
	ttfLabel:setAnchorPoint(cc.p(0.5, 0.5))
	rootNode:addChild(ttfLabel)

	if ttfLabel:getContentSize().width > textWidth then
		bg:setContentSize(cc.size(bg:getContentSize().width + (ttfLabel:getContentSize().width - textWidth), bg:getContentSize().height))
	end
	
	local action = cc.Sequence:create(
		cc.MoveBy:create(0.8, cc.p(0, 120)),
		cc.CallFunc:create(function()
			rootNode:removeFromParent(true)
		end)
	)
	cc.Director:getInstance():getRunningScene():addChild(rootNode)
	rootNode:runAction(action)

end
gt.floatText = floatText

local bit = require("app/libs/bit")

local function ByteCRC(sum, data)
    local sum = bit:_xor(sum, data)
    for i = 0, 3 do     -- lua for loop includes upper bound, so 7, not 8
        if (bit:_and(sum, 1) == 0) then
            sum = sum / 2
        else
            sum = bit:_xor((sum / 2), 0x6F89)--0x70B1
        end
    end
    return sum
end

local function CRC(data, length)
    local sum = 32558--65535
    for i = 1, length do
        local d = string.byte(data, i)    -- get i-th element, like data[i] in C
        sum = ByteCRC(sum, d)
    end
    return sum
end
gt.CRC = CRC

local function CRC2ND(data, length)
    local sum = 32558
    for i = 1, length do
        local d = string.byte(data, i)    -- get i-th element, like data[i] in C
		sum = bit:_xor(sum, d)
		if (bit:_and(sum, 1) == 0) then
			sum = sum / 2
		else
			sum = bit:_xor((sum / 2), 0x6F89)
		end
    end
    return sum
end
gt.CRC2ND = CRC2ND

local function ByteCRC32(sum, data)
    local sum = bit:_xor(sum, data)
    for i = 0, 3 do     -- lua for loop includes upper bound, so 7, not 8
        if (bit:_and(sum, 1) == 0) then
            sum = sum / 2
        else
            sum = bit:_xor((sum / 2), 0x96FC83)
        end
    end
    return sum
end

local function CRC32(data, length)
    local sum = 1073741824
    for i = 1, length do
        local d = string.byte(data, i)    -- get i-th element, like data[i] in C
        sum = ByteCRC32(sum, d)
    end
    return sum
end
gt.CRC32 = CRC32


--加载精灵帧前先检查plist中的frame是否存在,如果不存在则先加载到缓存.
local function checkAndLoadTextureFrame(img, frameName, plistName)
	if nil == cc.SpriteFrameCache:getInstance():getSpriteFrame(frameName) then 
		cc.SpriteFrameCache:getInstance():addSpriteFrames(plistName)
	end 
	img:loadTexture(frameName, ccui.TextureResType.plistType)
end 
gt.checkAndLoadTextureFrame = checkAndLoadTextureFrame 

--加载单张 pvr565格式的图片 
local function loadTexturePvr565(img, pvrName)
	local format = cc.Texture2D:getDefaultAlphaPixelFormat()
	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RG_B565)
	img:loadTexture(pvrName)
	cc.Texture2D:setDefaultAlphaPixelFormat(format) 
end 
gt.loadTexturePvr565 = loadTexturePvr565

--手动lua垃圾回收
local function collectLuaMemory()
	local preMem = collectgarbage("count")
	-- 调用lua垃圾回收器
	for i = 1, 3 do
		collectgarbage("collect")
	end
	local curMem = collectgarbage("count")
	gt.log(string.format("Collect lua memory:[%d], current memory:[%d]", (curMem - preMem), curMem)) 
end 
gt.collectLuaMemory = collectLuaMemory 


local function cloneTable(object)
    local lookup_table = {}
    local function copyObj( object )
        if type( object ) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs( object ) do
            new_table[copyObj( key )] = copyObj( value )
        end
        return setmetatable( new_table, getmetatable( object ) )
    end
    return copyObj( object )
end
gt.cloneTable = cloneTable