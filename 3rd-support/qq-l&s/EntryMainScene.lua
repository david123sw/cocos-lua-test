--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
gt.resetResLookup()
local cjson = require("cjson")
require("app/UtilityTools")
require("app/DefineConfig")
require("app/localizations/LocationUtil")
require("app/IntegratedResLookup")

local gt = cc.exports.gt
local RES_REF = cc.exports.RES_REF

local EntryMainScene = class("EntryMainScene", function ()
    return cc.Scene:create()
end)

--国庆节显示标记
local openNationalDayFlag = true
local scheduler = cc.Director:getInstance():getScheduler()  
local schedulerID = nil 
EntryMainScene.CONSTANTS = {
    ZOrder = {
	    HISTORY_RECORD			= 5,
	    CREATE_ROOM				= 6,
	    JOIN_ROOM				= 7,
	    MY_ROOM				= 8,
	    PLAYER_INFO_TIPS		= 9,
	    SETTING				= 10,
	    PAY_RESULT			= 11,
	    SERVICE				= 12,
	    SHARE				= 13,
	    REALNAME				= 14,
	    PROXY_CODE			= 15,
        CREATE_ARENA        = 16,
        RULE                = 17,
        GUILD               = 18,
        SHOP                = 19,
        ACTIVITY            = 20,
        INVITE_SHARE        = 21,
        UPDATE_NOTICE       = 22,
        SERVER_NOTICE       = 23
    }
}

function EntryMainScene:ctor()
    self.disObjs = self.disObjs or {}
    self.dymAttrs = self.dymAttrs or {}
    self.dymAttrs.noneGuildCreated = false
    self.dymAttrs.mainSceneGuildID = nil
    gt:addPlist(RES_REF.PLIST.COMMON)
    gt:addPlist(RES_REF.PLIST.SHOP)
    gt:addPlist(RES_REF.PLIST.MAIN)
    gt:addPlist(RES_REF.PLIST.MAIN_NEW)
    gt:addPlist(RES_REF.PLIST.GUILD)

	local csbNode = cc.CSLoader:createNode(RES_REF.CSB.ENTRY_MAIN_SCENE)
    gt:adjustSceneDisplay(csbNode)
    gt:setNodeAllTextsFont(csbNode)
	self:addChild(csbNode)
    self.disObjs.csbNode = csbNode

    self:initDisplay()
    self:registerScriptHandler(handler(self, self.onNodeEvent))
end

function EntryMainScene:changeClassicResForNationalDay()
    if true == openNationalDayFlag then
        self.disObjs.btnInvite:loadTextureNormal(RES_REF.IMG.ND_VERIFICATION_CODE)
	    self.disObjs.btnInvite:ignoreContentAdaptWithSize(true)
	    self.disObjs.btnAccountAuthorized:loadTextureNormal(RES_REF.IMG.ND_ID_VERIFICATION)
	    self.disObjs.btnAccountAuthorized:ignoreContentAdaptWithSize(true)
	    self.disObjs.btnShop:loadTextureNormal(RES_REF.IMG.ND_SHOP)
	    self.disObjs.btnShop:ignoreContentAdaptWithSize(true)
        self.disObjs.btnShop:setPositionY(50)
	    self.disObjs.btnActivity:loadTextureNormal(RES_REF.IMG.ND_ACTIVITY)
	    self.disObjs.btnActivity:ignoreContentAdaptWithSize(true)
	    self.disObjs.btnShare:loadTextureNormal(RES_REF.IMG.ND_SHARE)
	    self.disObjs.btnShare:ignoreContentAdaptWithSize(true)
        self.disObjs.btnShare:setPositionY(48)
	    self.disObjs.btnMatch:loadTextureNormal(RES_REF.IMG.ND_MATCH)
	    self.disObjs.btnMatch:ignoreContentAdaptWithSize(true)
        self.disObjs.btnMatch:setPositionY(49)
	    self.disObjs.btnRecord:loadTextureNormal(RES_REF.IMG.ND_RECORD)
	    self.disObjs.btnRecord:ignoreContentAdaptWithSize(true)
        self.disObjs.btnRecord:setPositionY(42.5)
	    self.disObjs.btnMenu:loadTextureNormal(RES_REF.IMG.ND_MENU)
	    self.disObjs.btnMenu:ignoreContentAdaptWithSize(true)
        self.disObjs.btnMenu:setPositionY(49)

        local fireworks = self.disObjs.btnShopNew:getChildByName("fireworks")
        if nil == fireworks then
            fireworks = cc.Sprite:create(RES_REF.IMG.ND_SHOP_BKG_NEW)
            fireworks:setPosition(cc.p(239, 108))
            fireworks:setAnchorPoint(cc.p(0.5, 0.5))
            fireworks:setName("fireworks")
            self.disObjs.btnShopNew:addChild(fireworks)
        end

        local redFlag = self.disObjs.imgPortrait:getChildByName("redFlag")
        if nil == redFlag then
            redFlag = cc.Sprite:create(RES_REF.IMG.ND_HEAD_RED_FLAG)
            redFlag:setPosition(cc.p(-10, 0))
            redFlag:setAnchorPoint(cc.p(0, 0))
            redFlag:setName("redFlag")
            self.disObjs.imgPortrait:addChild(redFlag)
        end

        local threeBtns = {self.disObjs.btnCreateRoom, self.disObjs.btnJoinRoom, self.disObjs.btnGuild}
        for i=1, #threeBtns do
            require("app/DragonBoneCreator"):create({
            skeDataPath="images/guoqing/ballon/balloon_1_ske.json",
            texDataPath="images/guoqing/ballon/balloon_1_tex.json",
            armatureName="armatureName",
            animationName="newAnimation",
            armaturePos=cc.p(151, 353),
            armatureSpeed=0.2,
            targetNode=threeBtns[i]})
        end
    end
end

function EntryMainScene:changePopularResForNationalDay()
    if true == openNationalDayFlag then
	    self.disObjs.btnAccountAuthorizedNew:loadTextureNormal(RES_REF.IMG.ND_ID_VERIFICATION_NEW)
	    self.disObjs.btnAccountAuthorizedNew:ignoreContentAdaptWithSize(true)
	    self.disObjs.btnInviteNew:loadTextureNormal(RES_REF.IMG.ND_VERIFICATION_CODE_NEW)
	    self.disObjs.btnInviteNew:ignoreContentAdaptWithSize(true)
	    self.disObjs.btnServiceNew:loadTextureNormal(RES_REF.IMG.ND_SERVICE_NEW)
	    self.disObjs.btnServiceNew:ignoreContentAdaptWithSize(true)

        local fireworks = self.disObjs.btnShopNew:getChildByName("fireworks")
        if nil == fireworks then
            fireworks = cc.Sprite:create(RES_REF.IMG.ND_SHOP_BKG_NEW)
            fireworks:setPosition(cc.p(239, 108))
            fireworks:setAnchorPoint(cc.p(0.5, 0.5))
            fireworks:setName("fireworks")
            self.disObjs.btnShopNew:addChild(fireworks)
        end

        local redFlag = self.disObjs.imgPortrait:getChildByName("redFlag")
        if nil == redFlag then
            redFlag = cc.Sprite:create(RES_REF.IMG.ND_HEAD_RED_FLAG)
            redFlag:setPosition(cc.p(-10, 0))
            redFlag:setAnchorPoint(cc.p(0, 0))
            redFlag:setName("redFlag")
            self.disObjs.imgPortrait:addChild(redFlag)
        end

        require("app/DragonBoneCreator"):create({
        skeDataPath="images/guoqing/ballon/balloon_1_ske.json",
        texDataPath="images/guoqing/ballon/balloon_1_tex.json",
        armatureName="armatureName",
        animationName="newAnimation",
        armaturePos=cc.p(215, 145),
        armatureSpeed=0.2,
        targetNode=self.disObjs.btnShopNew})
    end
end

function EntryMainScene:initDisplay()
    self.disObjs.layoutBottom = self.disObjs.csbNode:getChildByName("layoutBottom")
    self.disObjs.layoutBottom:setTouchEnabled(true)
    self.disObjs.layoutBottom:addTouchEventListener(function(target, event)
        if TOUCH_EVENT_ENDED == event then
           gt.log("底部背景")
           gt:playClickingEffects(target)
        end
    end)

    self.disObjs.layoutTop = self.disObjs.csbNode:getChildByName("layoutTop")
    self.disObjs.layoutTop:setVisible(false)
    self.disObjs.layoutTop:setTouchEnabled(true)
    self.disObjs.layoutTop:setSwallowTouches(true)
    self.disObjs.layoutTop:addTouchEventListener(function(target, event)
        if TOUCH_EVENT_ENDED == event then
           gt.log("顶部背景")
           self.disObjs.layoutTop:setVisible(false)
           if nil ~= self.disObjs.imgSubMenus and self.disObjs.imgSubMenus:isVisible() then
             self.disObjs.imgSubMenus:setVisible(false)              
           end
        end
    end)

    -- 点击头像显示信息
	local imgPortraitBkg = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgPortraitBkg")
    imgPortraitBkg:setTouchEnabled(true)
    imgPortraitBkg:addTouchEventListener(function (target, event)
        if TOUCH_EVENT_ENDED == event then
            gt:nonBtnPlaySoundEffect()
            local playerInfo = require("app/views/PlayerInfo"):create(gt.playerData)
		    self:addChild(playerInfo, EntryMainScene.CONSTANTS.ZOrder.PLAYER_INFO_TIPS)
        end
    end)

    local btnPortraitCard = ccui.Helper:seekWidgetByName(imgPortraitBkg, "btnCards")
    gt.addBtnPressedListener(btnPortraitCard, function (target, event)
        gt.log("click btnPortraitCard")
        local shop
        if gt.playerData.proxyCode == 0 then
           shop = require("app/views/Shop"):create(false)
        else
           shop = require("app/views/Shop"):create(true)
        end
		self:addChild(shop, EntryMainScene.CONSTANTS.ZOrder.SHOP)
    end)
    self.disObjs.btnCards = btnPortraitCard

    self.disObjs.imgPortrait = ccui.Helper:seekWidgetByName(imgPortraitBkg, "imgPortrait")
    self.disObjs.imgPortrait:ignoreContentAdaptWithSize(true)
    local playerHeadMgr = require("app/PlayerHeadManager"):create()
	playerHeadMgr:attach(self.disObjs.imgPortrait, gt.playerData.uid, gt.playerData.headURL)
	self:addChild(playerHeadMgr)

    self.disObjs.txtNickname = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "txtNickname")
    self.disObjs.txtNickname:setString(gt.checkName(gt.playerData.nickname, 7))
    local realArea = self.disObjs.txtNickname:getVirtualRendererSize()
    self.disObjs.txtAccountID = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "txtAccountID")
    self.disObjs.txtAccountID:setString("ID: "..gt.playerData.uid)
    self.disObjs.txtCards = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "txtCards")
    self.disObjs.txtCards:setString(gt.playerData.roomCardsCount[1])

    self.disObjs.imgBeauty = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgBeauty")
    self.disObjs.imgBeauty:setVisible(not gt.isOpenDBSupport)

    self.disObjs.layoutNode = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "layoutNode")

    self.disObjs.btnCreateRoom = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnCreateRoom")
    self.disObjs.btnCreateRoom:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnCreateRoom, function (target, event)
        gt.log("click createRoom")
        local createRoomScene = require("app/views/CreateRoomScene"):create()
		self:addChild(createRoomScene, EntryMainScene.CONSTANTS.ZOrder.CREATE_ROOM)
    end)

    self.disObjs.btnJoinRoom = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnJoinRoom")
    self.disObjs.btnJoinRoom:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnJoinRoom, function (target, event)
        gt.log("click joinRoom")
        local joinRoom = require("app/views/JoinRoom"):create()
		self:addChild(joinRoom, EntryMainScene.CONSTANTS.ZOrder.JOIN_ROOM)
    end)

    self.disObjs.btnGuild = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnGuild")
    self.disObjs.btnGuild:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnGuild, function (target, event)
        gt.log("click guild")
        gt.showLoadingTips(gt.getLocationString("LTKey_0076"))
        local msgToSend = {}
	    msgToSend.cmd = gt.CLUB_LIST
	    gt.socketClient:sendMessage(msgToSend)
    end)

    self.disObjs.btnShop = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnShop")
    self.disObjs.btnShop:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnShop, function (target, event)
        gt.log("click shop")
        local shop
        if gt.playerData.proxyCode == 0 then
           shop = require("app/views/Shop"):create(false)
        else
           shop = require("app/views/Shop"):create(true)
        end
		self:addChild(shop, EntryMainScene.CONSTANTS.ZOrder.SHOP)
    end)

    self.disObjs.btnActivity = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnActivity")
    self.disObjs.btnActivity:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnActivity, function (target, event)
        gt.log("click activity")
        local boardcast = require("app/views/Activity"):create()
		self:addChild(boardcast, EntryMainScene.CONSTANTS.ZOrder.ACTIVITY)
    end)

    self.disObjs.btnShare = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnShare")
    self.disObjs.btnShare:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnShare, function (target, event)
        gt.log("click share")
        local description = string.format("【%s】邀请你来玩最正宗的桂林字牌，赶紧来玩吧！", gt.playerData.nickname)
		local title = "吆玩桂林字牌"
		local share = require("app/views/Share"):create(description, title, gt.shareWeb)
		self:addChild(share, EntryMainScene.CONSTANTS.ZOrder.SHARE)
    end)

    self.disObjs.btnMatch = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnMatch")
    self.disObjs.btnMatch:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnMatch, function (target, event)
        gt.log("click match")
        require("app/views/CommonTips"):create(gt.getLocationString("LTKey_0063"))

--        local description = string.format("【%s】邀请你来玩最正宗的桂林字牌，赶紧来玩吧！", gt.playerData.nickname)
--        local title = "吆玩桂林字牌"
--        local url = gt.shareWeb
--        local previewImgUrl = "http://"..gt.LoginServer.ip.."/yaowangl/hotupdate/default_icons/Icon-120.png"
        --    extension.qqShareMsg({title=title, description=description, url=url, previewImgUrl=previewImgUrl}, function(resp)
        --        gt.dump(resp, "qqShareMsg")
        --    end)

        -- extension.qqShareMsg({text="just for test"}, function(resp)
        --     gt.dump(resp, "qqShareMsg")
        -- end)

--        local writePath = cc.FileUtils:getInstance():getWritablePath()
--        extension.qqShareMsg({title=title, description=description, image="res/images/btn_chi.png", absoluteImage=writePath.."res/images/img_ready.png"}, function(resp)
--            gt.dump(resp, "qqShareMsg")
--        end)

--        extension.getQQLogin(function (respJson)
--            if gt.isAndroidPlatform() then
--                gt.dump(respJson, "getQQLogin callback")
--                local qqRet = respJson
--                if 1 == qqRet.status then
--                    gt.log("qqRet status is 1")
--                    local userInfo = string.split(qqRet.code, "|")
--                    gt.log("userInfoStr pair count:"..table.nums(userInfo))
--                    local transUserInfo = {}
--                    for i=1, #userInfo-1, 2 do
--                        transUserInfo[userInfo[i]] = userInfo[i+1]
--                    end
--                    gt.dump(transUserInfo, "-----------????????????????--------------")
--                elseif 0 == qqRet.status then
--                    gt.log("qqRet status is 0, error")
--                end
--            elseif gt.isIOSPlatform() then
--                 local qqRet = respJson
--                 if "0" ~= qqRet.detailRetCode and "0" ~= qqRet.retCode then
--                     gt.log("detailRetCode:"..detailRetCode)
--                     gt.removeLoadingTips()
--                     require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0090"), nil, nil, true)
--                     return
--                 else
--                     local parsedMsg = cjson.decode(qqRet.message)
--                     local user_id = ""
--                     local union_id = ""
--                     local openid = "qq_"..qqRet.openId
--                     local access_token = parsedMsg.accessToken
--                     local refresh_token = ""
--                     local icon = parsedMsg.figureurl_2
--                     local nick = parsedMsg.nickname
--                     local sex = parsedMsg.gender == "男" and 1 or 2
--                     local location = parsedMsg.city

--                     self:getRealLoginPrepare(access_token, refresh_token, openid, sex, nick, icon, union_id)
--                 end
--            end
--        end)

--        android
--        extension.qqShareMsg({text="just for test qq share"}, function(resp)
--            gt.dump(resp, "qqShareMsg")
--        end)

--          extension.qqShareMsg({title=title, description=description, url=url, previewImgUrl=previewImgUrl}, function(resp)
--              gt.dump(resp, "qqShareMsg")
--          end)

--        local writePath = cc.FileUtils:getInstance():getWritablePath()
--        extension.qqShareMsg({absoluteImage=writePath.."res/image/scr.png"}, function(resp)
--            gt.dump(resp, "qqShareMsg")
--        end)
    end)

    self.disObjs.btnExperience = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnExperience")
    self.disObjs.btnExperience:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnExperience, function (target, event)
        gt.log("进入体验场")
        local msg = {cmd=277, game_type=600}
        gt.socketClient:sendMessage(msg)
        self.disObjs.btnExperience:setTouchEnabled(false)
    end)

    self.disObjs.btnRecord = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnRecord")
    self.disObjs.btnRecord:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnRecord, function (target, event)
        gt.log("click record")
        local historyRecord = require("app/views/CombatGains"):create(gt.playerData.uid)
        historyRecord:setName("CombatGains")
		self:addChild(historyRecord, EntryMainScene.CONSTANTS.ZOrder.HISTORY_RECORD)
    end)

    self.disObjs.btnAccountAuthorized = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnAccountAuthorized")
    self.disObjs.btnAccountAuthorized:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnAccountAuthorized, function (target, event)
        gt.log("click account authorized")
        local accountAuthorizedScene = require("app/views/AccountAuthorizedScene"):create({owner=self})
		self:addChild(accountAuthorizedScene, EntryMainScene.CONSTANTS.ZOrder.REALNAME)
    end)

    self.disObjs.btnInvite = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnInvite")
    self.disObjs.btnInvite:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnInvite, function (target, event)
        gt.log("click invite")
        local invite_code
	    if gt.playerData.proxyCode == 0 then
	        --未绑定VIP激活码
	        invite_code = require("app/views/Invite"):create(false)
	        self:addChild(invite_code, EntryMainScene.CONSTANTS.ZOrder.PROXY_CODE)
	    else
	        --已绑定VIP激活码
	        invite_code = require("app/views/Invite"):create(true)
	        self:addChild(invite_code, EntryMainScene.CONSTANTS.ZOrder.PROXY_CODE)
	    end
    end)

    self.disObjs.btnBindPhone = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnBindPhone")
    self.disObjs.btnBindPhone:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnBindPhone, function (target, event)
--        gt.log("click bind phone")
--        local accountPhoneScene = require("app/views/AccountPhoneScene"):create({mode="bind"})
--        self:addChild(accountPhoneScene, EntryMainScene.CONSTANTS.ZOrder.PROXY_CODE)
    end)
    if true == gt.playerData.bind_mobile then
        self.disObjs.btnBindPhone:setVisible(false)
    else
        self.disObjs.btnBindPhone:setVisible(true)
    end
    --绑定手机合并到认证里
    self.disObjs.btnBindPhone:setVisible(false)

    self.disObjs.btnMenu = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnMenu")
    self.disObjs.btnMenu:setSwallowTouches(false)
    gt.addBtnPressedListener(self.disObjs.btnMenu, function (target, event)
        gt.log("click menus")
        if nil == self.disObjs.csbNode:getChildByName("imgSubMenus") then
            self.disObjs.imgSubMenus:setPosition(self.disObjs.imgSubMenusWorldPos)
            self.disObjs.csbNode:addChild(self.disObjs.imgSubMenus)

            local imgSubMenusItems = self.disObjs.imgSubMenus:getChildren()
            for i=1, #imgSubMenusItems do
                gt.addBtnPressedListener(imgSubMenusItems[i], function (target, event)
                    local name = target:getName()
                    if "btnMenuSetting" == name then
                        local setting = require("app/views/Setting"):create()
		                self:addChild(setting, EntryMainScene.CONSTANTS.ZOrder.SETTING)
                    elseif "btnMenuService" == name then
                        local service = require("app/views/Service"):create()
		                self:addChild(service, EntryMainScene.CONSTANTS.ZOrder.SHARE)
                    elseif "btnMenuRule" == name then
                        local rule = require("app/views/Rule"):create()
		                self:addChild(rule, EntryMainScene.CONSTANTS.ZOrder.RULE)
                    end
                    self.disObjs.imgSubMenus:setVisible(false)
                    self.disObjs.layoutTop:setVisible(false)
                end)
            end
        else
            self.disObjs.imgSubMenus:setVisible(not self.disObjs.imgSubMenus:isVisible())
        end
        self.disObjs.layoutTop:setVisible(true)
    end)

    self.disObjs.imgBottomMenus = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgBottomMenus")
    local imgSubMenus = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgSubMenus")
    self.disObjs.imgSubMenus = imgSubMenus:clone()
    self.disObjs.imgSubMenus:retain()
    self.disObjs.imgSubMenusWorldPos = self.disObjs.imgBottomMenus:convertToWorldSpace(cc.p(self.disObjs.imgSubMenus:getPosition()))
    imgSubMenus:removeFromParent()

    self.disObjs.imgBkg = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgBkg")
    self.disObjs.imgTitle = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgTitle")
    self.disObjs.imgTitle:ignoreContentAdaptWithSize(true)
    self.disObjs.imgLogo = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgLogo")

    --跑马灯
	local marqueeNode = self.disObjs.layoutBottom:getChildByName("nodeMarquee")
	local marqueeMsg = require("app/MarqueeMsg"):create()
    marqueeMsg:setName("MarqueeMsg")
	marqueeNode:addChild(marqueeMsg)
	self.marqueeMsg = marqueeMsg
	self.marqueeMsg:showMsg("欢迎来到吆玩桂林字牌。本游戏仅供娱乐，禁止参与赌博！")
    --                   热烈庆祝中华人民共和国成立69周年，祝广大玩家节日快乐！
	if gt.marqueeMsgTemp then
		self.marqueeMsg:showMsg(gt.marqueeMsgTemp)
		gt.marqueeMsgTemp = nil
	end
    self.disObjs.marqueeNodeBkg = marqueeNode:getChildByName("MarqueeMsg"):getChildByName("Img_Bg")

    local versionLabel = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "txtVer")
    versionLabel:setString(gt.getAppVersionStr())

    --女角色
    if gt.isOpenDBSupport then
        require("app/DragonBoneCreator"):create({
        skeDataPath="effects/welcomeGirl/welcome_girl_ske.json",
        texDataPath="effects/welcomeGirl/welcome_girl_tex.json",
        armatureName="armatureName",
        animationName="newAnimation",
        targetNode=self.disObjs.layoutNode})
    end

    --新界面UI
    self.disObjs.imgGuildInfoNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgGuildInfoNew")
    self.disObjs.imgGuildInfoNew:setVisible(false)

    self.disObjs.layoutRoomMenuNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "layoutRoomMenuNew")
    self.disObjs.layoutRoomMenuNew:setSwallowTouches(false)
    self.disObjs.layoutRoomMenuNew:setVisible(false)
    self.disObjs.imgBottomMenusNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "imgBottomMenusNew")
    self.disObjs.imgBottomMenusNew:setVisible(false)

    self.disObjs.layoutLightNode = ccui.Helper:seekWidgetByName(self.disObjs.layoutRoomMenuNew, "layoutLightNode")
        require("app/DragonBoneCreator"):create({
        skeDataPath="effects/main2Light/eff_main2_light_ske.json",
        texDataPath="effects/main2Light/eff_main2_light_tex.json",
        armatureName="armatureName",
        animationName="newAnimation",
        armatureSpeed=0.50,
        armatureScale=1,
        targetNode=self.disObjs.layoutLightNode})

    self.disObjs.imgSwitcherGuild = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgSwitcherGuild")
    self.disObjs.imgSwitcherGuildDesc = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgSwitcherGuildDesc")
    self.disObjs.imgSwitcherGuildDesc:setTouchEnabled(true)
    self.disObjs.imgSwitcherGuildDesc:setSwallowTouches(false)
    self.disObjs.imgSwitcherGuildDesc:addTouchEventListener(function (target, event)
        if TOUCH_EVENT_ENDED == event then
            gt.log("牌友圈快照")
            self.disObjs.imgSwitcherGuild:setVisible(true)
            self.disObjs.imgSwitcherMatch:setVisible(false)
        end
    end)

    self.disObjs.imgSwitcherGuild:setTouchEnabled(true)
    self.disObjs.imgSwitcherGuild:addTouchEventListener(function (target, event)
        if TOUCH_EVENT_ENDED == event then
            local listCount = #self.disObjs.lvItemsNew:getItems()
            if true == self.dymAttrs.noneGuildCreated then
                local preEnterGuild = require("app/views/PreEnterGuild"):create({parent=self, zOrder=EntryMainScene.CONSTANTS.ZOrder.GUILD})
		        self:addChild(preEnterGuild, EntryMainScene.CONSTANTS.ZOrder.GUILD)
            else
                require("app/views/CommonTips"):create("快去创建房间与好友一起玩吧")
            end
        end
    end)

    self.disObjs.imgSwitcherMatch = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgSwitcherMatch")
    self.disObjs.imgSwitcherMatchDesc = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgSwitcherMatchDesc")
    self.disObjs.imgSwitcherMatchDesc:setTouchEnabled(true)
    self.disObjs.imgSwitcherMatchDesc:addTouchEventListener(function (target, event)
        if TOUCH_EVENT_ENDED == event then
            gt.log("竞技场快照")
            require("app/views/CommonTips"):create(gt.getLocationString("LTKey_0063"))
        end
    end)
    self.disObjs.imgNoInfoTip = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgNoInfoTip")
    self.disObjs.imgLittleGirl = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgLittleGirl")
    self.disObjs.imgLvTitleBkg = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "imgLvTitleBkg")
    self.disObjs.imgLvTitleBkg:setVisible(false)
    self.disObjs.lvItemsNew = ccui.Helper:seekWidgetByName(self.disObjs.imgGuildInfoNew, "lvItems")
    self.disObjs.lvItemsNew:setScrollBarEnabled(false)
    self.disObjs.lvItemsNew:setSwallowTouches(false)
    self.disObjs.lvItemsNewItem = self.disObjs.lvItemsNew:getItem(0)
    self.disObjs.lvItemsNewItem:retain()
    self.disObjs.lvItemsNew:removeAllChildren()

    --统一默认不显示
    self.disObjs.imgNoInfoTip:setVisible(false)
    self.disObjs.imgLittleGirl:setVisible(false)

    self.disObjs.btnGoldRoomNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutRoomMenuNew, "btnGoldRoomNew")
    gt.addBtnPressedListener(self.disObjs.btnGoldRoomNew, function (target, event)
        gt.log("click goldRoom")
        require("app/views/CommonTips"):create(gt.getLocationString("LTKey_0063"))
    end)

    self.disObjs.btnCreateRoomNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutRoomMenuNew, "btnCreateRoomNew")
    gt.addBtnPressedListener(self.disObjs.btnCreateRoomNew, function (target, event)
        gt.log("click createRoom")
        local createRoomScene = require("app/views/CreateRoomScene"):create()
		self:addChild(createRoomScene, EntryMainScene.CONSTANTS.ZOrder.CREATE_ROOM)
    end)

    self.disObjs.btnGuildNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutRoomMenuNew, "btnGuildNew")
    gt.addBtnPressedListener(self.disObjs.btnGuildNew, function (target, event)
        gt.log("click guild")
        gt.showLoadingTips(gt.getLocationString("LTKey_0076"))
        local msgToSend = {}
	    msgToSend.cmd = gt.CLUB_LIST
	    gt.socketClient:sendMessage(msgToSend)
    end)

    self.disObjs.btnJoinRoomNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutRoomMenuNew, "btnJoinRoomNew")
    gt.addBtnPressedListener(self.disObjs.btnJoinRoomNew, function (target, event)
        gt.log("click joinRoom")
        local joinRoom = require("app/views/JoinRoom"):create()
		self:addChild(joinRoom, EntryMainScene.CONSTANTS.ZOrder.JOIN_ROOM)
    end)

    self.disObjs.btnShopNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnShopNew")
    gt.addBtnPressedListener(self.disObjs.btnShopNew, function (target, event)
        gt.log("click shop")
        local shop
        if gt.playerData.proxyCode == 0 then
           shop = require("app/views/Shop"):create(false)
        else
           shop = require("app/views/Shop"):create(true)
        end
		self:addChild(shop, EntryMainScene.CONSTANTS.ZOrder.SHOP)
    end)

    self.disObjs.btnActivityNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnActivityNew")
    gt.addBtnPressedListener(self.disObjs.btnActivityNew, function (target, event)
        gt.log("click activity")
        local boardcast = require("app/views/Activity"):create()
		self:addChild(boardcast, EntryMainScene.CONSTANTS.ZOrder.ACTIVITY)
    end)

    self.disObjs.btnShareNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnShareNew")
    gt.addBtnPressedListener(self.disObjs.btnShareNew, function (target, event)
        gt.log("click share")
        local description = string.format("【%s】邀请你来玩最正宗的桂林字牌，赶紧来玩吧！", gt.playerData.nickname)
		local title = "吆玩桂林字牌"
		local share = require("app/views/Share"):create(description, title, gt.shareWeb)
		self:addChild(share, EntryMainScene.CONSTANTS.ZOrder.SHARE)
    end)

    self.disObjs.btnRuleNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnRuleNew")
    gt.addBtnPressedListener(self.disObjs.btnRuleNew, function (target, event)
        local rule = require("app/views/Rule"):create()
	    self:addChild(rule, EntryMainScene.CONSTANTS.ZOrder.RULE)
    end)

    self.disObjs.btnRecordNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnRecordNew")
    gt.addBtnPressedListener(self.disObjs.btnRecordNew, function (target, event)
        gt.log("click record")
        local historyRecord = require("app/views/CombatGains"):create(gt.playerData.uid)
        historyRecord:setName("CombatGains")
		self:addChild(historyRecord, EntryMainScene.CONSTANTS.ZOrder.HISTORY_RECORD)
    end)

    self.disObjs.btnExperienceNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnExperienceNew")
    gt.addBtnPressedListener(self.disObjs.btnExperienceNew, function (target, event)
        gt.log("进入体验场")
        local msg = {cmd=277, game_type=600}
        gt.socketClient:sendMessage(msg)
        self.disObjs.btnExperienceNew:setTouchEnabled(false)
    end)
    self.disObjs.btnMenuNew = ccui.Helper:seekWidgetByName(self.disObjs.imgBottomMenusNew, "btnMenuNew")
    gt.addBtnPressedListener(self.disObjs.btnMenuNew, function (target, event)
        gt.log("click menuNew")
        local setting = require("app/views/Setting"):create()
		self:addChild(setting, EntryMainScene.CONSTANTS.ZOrder.SETTING)
    end)
    self.disObjs.btnServiceNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnServiceNew")
    self.disObjs.btnServiceNew:setVisible(false)
    gt.addBtnPressedListener(self.disObjs.btnServiceNew, function (target, event)
        gt.log("click service")
        local service = require("app/views/Service"):create()
		self:addChild(service, EntryMainScene.CONSTANTS.ZOrder.SHARE)
    end)
    self.disObjs.btnAccountAuthorizedNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnAccountAuthorizedNew")
    self.disObjs.btnAccountAuthorizedNew:setVisible(false)
    gt.addBtnPressedListener(self.disObjs.btnAccountAuthorizedNew, function (target, event)
        gt.log("click account authorized")
        local accountAuthorizedScene = require("app/views/AccountAuthorizedScene"):create({owner=self})
	    self:addChild(accountAuthorizedScene, EntryMainScene.CONSTANTS.ZOrder.REALNAME)
    end)

    self.disObjs.btnInviteNew = ccui.Helper:seekWidgetByName(self.disObjs.layoutBottom, "btnInviteNew")
    self.disObjs.btnInviteNew:setVisible(false)
    gt.addBtnPressedListener(self.disObjs.btnInviteNew, function (target, event)
        gt.log("click invite")
        local invite_code
	    if gt.playerData.proxyCode == 0 then
	        --未绑定VIP激活码
	        invite_code = require("app/views/Invite"):create(false)
	        self:addChild(invite_code, EntryMainScene.CONSTANTS.ZOrder.PROXY_CODE)
	    else
	        --已绑定VIP激活码
	        invite_code = require("app/views/Invite"):create(true)
	        self:addChild(invite_code, EntryMainScene.CONSTANTS.ZOrder.PROXY_CODE)
	    end
    end)

    -- 注册消息回调
    gt.socketClient:registerMsgListener(gt.JOIN_ROOM, self, self.onRcvJoinRoom)
    gt.socketClient:registerMsgListener(gt.ENTER_GAME, self, self.onRcvEnterGame)
	gt.socketClient:registerMsgListener(gt.ROOM_CARD, self, self.onRcvRoomCard)
	gt.socketClient:registerMsgListener(gt.NOTICE, self, self.onRcvMarquee)
	gt.socketClient:registerMsgListener(gt.LOGIN_USERID, self, self.onRcvLoginUserId)
	gt.socketClient:registerMsgListener(gt.PAY_RESULT, self, self.onRcvPayResult)
    --牌友圈
    gt.socketClient:registerMsgListener(gt.CLUB_LIST, self, self.onGuildListRespond)
    gt.socketClient:registerMsgListener(gt.CLUB_CREATE, self, self.onGuildCreateRespond)
    gt.socketClient:registerMsgListener(gt.CLUB_JOIN, self, self.onGuildJoinRespond)
    gt.socketClient:registerMsgListener(gt.CLUB_INFO_NEW, self, self.onGuildInfoNewRespond)
    gt.socketClient:registerMsgListener(gt.CLUB_REFRESH_ROOM_CURRENT, self, self.onGuildCreatedRoomRefreshRespond)
    gt.socketClient:registerMsgListener(gt.CLUB_SYS_MESSAGE, self, self.onGuildSysMessageRespond)
    --账号状态
    gt.socketClient:registerMsgListener(gt.LOGOUT, self, self.onAccountLogoutStatus)

    gt.registerEventListener(gt.EventType.AUTHORIZE_CIVIC_ID, self, self.onAuthorizedCivicID)
    gt.registerEventListener(gt.EventType.AUTHORIZE_COOL_DOWN_START, self, self.onAuthorizedCooldownStart)
    gt.registerEventListener(gt.EventType.PLAY_SCENE_RESET, self, self.onBackMainScene)
    gt.registerEventListener(gt.EventType.PROXY_RECRUIT_COPY, self, self.invokeProxyRecruitCopy)
    gt.registerEventListener(gt.EventType.GUILD_EXIT_FROM_ROOM, self, self.onExitFromGuildRoom)
    gt.registerEventListener(gt.EventType.BACK_FROM_GAME, self, self.onBackMainSceneReceived)
    gt.registerEventListener(gt.EventType.BIND_PHONE_UPDATED, self, self.onBindPhoneUpdated)
    gt.registerEventListener(gt.EventType.BACK_FROM_REPLAY, self, self.onExitFromReplay)
    gt.registerEventListener(gt.EventType.MAIN_SCENE_STYLE_UPDATED, self, self.onMainSceneStyleUpdated)
    gt.registerEventListener(gt.EventType.MAIN_SCENE_GUILD_ROOMS_UPDATED, self, self.onMainSceneGuildRoomsUpdated)

    gt.dispatchEvent(gt.EventType.MAIN_SCENE_STYLE_UPDATED, {style=gt.hallSettings.UIStyle})
end

function EntryMainScene:onGuildSysMessageRespond(msgTbl)
    gt.dump(msgTbl, "-----onGuildSysMessageRespond-----")

    gt.removeLoadingTips()
    if "refuse_join" == msgTbl.type then
--        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), string.format("牌友圈[ID:%d]拒绝了你的申请", msgTbl.club_id), nil, nil, true)
    elseif "agree_join" == msgTbl.type then
--        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), string.format("牌友圈[ID:%d]接受了你的申请", msgTbl.club_id), nil, nil, true)
        if gt.hallSettings.UIStyle == "popular" then
            local msgToSend = {}
	        msgToSend.cmd = gt.CLUB_LIST
            msgToSend.snapshot = true
	        gt.socketClient:sendMessage(msgToSend)
        end
    end
end

function EntryMainScene:onGuildCreatedRoomRefreshRespond(msgTbl)
    gt.dump(msgTbl, "-----onGuildCreatedRoomRefreshRespond-----")

    local items = self.disObjs.lvItemsNew:getItems()
    if true == msgTbl.delete then
        for i=1, #items do
            if items[i].details.club_id == msgTbl.club_id and items[i].details.room_id == msgTbl.room_id then
                self.disObjs.lvItemsNew:removeItem(i-1)
                break
            end
        end

        if 0 == #self.disObjs.lvItemsNew:getItems() then
            self.disObjs.imgNoInfoTip:setVisible(true)
            self.disObjs.imgLittleGirl:setVisible(true)
            self.disObjs.imgLvTitleBkg:setVisible(false)
        end
    else
        local isUpdateNew = false
        for i=1, #items do
            if items[i].details.club_id == msgTbl.club_id and items[i].details.room_id == msgTbl.room_id then
                local currentPlayersNum = table.nums(msgTbl.players)
                --全部准备开始后移除
                --currentPlayersNum == msgTbl.player_count and 0 == msgTbl.state
                if false then
                    self.disObjs.lvItemsNew:removeItem(i-1)
                else
                    items[i]:getChildByName("txtGameRound"):setString(items[i].details.config.round_count.."局")
                    items[i]:getChildByName("txtGameCapacity"):setString(currentPlayersNum.."/"..msgTbl.player_count)
                end

                isUpdateNew = true
                break
            end
        end

        if false == isUpdateNew then
            local data = msgTbl
            local copy = self.disObjs.lvItemsNewItem:clone()
            copy.details = data
            local txtGameName = copy:getChildByName("txtGameName")
            txtGameName:ignoreContentAdaptWithSize(true)
            local txtGameRoom = copy:getChildByName("txtGameRoom")
            txtGameRoom:ignoreContentAdaptWithSize(true)
            local txtGameRound = copy:getChildByName("txtGameRound")
            txtGameRound:ignoreContentAdaptWithSize(true)
            local txtGameCapacity = copy:getChildByName("txtGameCapacity")
            txtGameCapacity:ignoreContentAdaptWithSize(true)
            local btnRoomInvite = copy:getChildByName("btnRoomInvite")
            txtGameName:setString(gt.GameTypeDesc[data.game_type])
            txtGameRoom:setString(data.room_id)
            txtGameRound:setString(data.config.round_count.."局")
            txtGameCapacity:setString(#data.players.."/"..data.player_count)
            gt.addBtnPressedListener(btnRoomInvite, function(target, event)
                local roomInfo = {}
                roomInfo.config = data.config
                roomInfo.roomid = data.room_id
                roomInfo.curPlayerNum = data.cur_player_count
                roomInfo.club = "club"
                gt.shareZipaiRoomInfo(roomInfo)
            end)
            copy:setTouchEnabled(true)
            copy:addTouchEventListener(function (target, event)
                if TOUCH_EVENT_ENDED == event then
                    gt.showLoadingTips()
                    local msgToSend = {}
		            msgToSend.cmd = gt.JOIN_ROOM
		            msgToSend.room_id = data.room_id
		            msgToSend.app_id = gt.app_id
		            msgToSend.user_id = gt.playerData.uid
		            msgToSend.ver = gt.version
		            msgToSend.dev_id = gt.getDeviceId()
		            gt.socketClient:sendMessage(msgToSend)
                    gt.recordedGuildID = club_id
                end
            end)
            self.disObjs.lvItemsNew:pushBackCustomItem(copy)
            self.disObjs.imgNoInfoTip:setVisible(false)
            self.disObjs.imgLittleGirl:setVisible(false)
            self.disObjs.imgLvTitleBkg:setVisible(true)
        end
    end
end

function EntryMainScene:onGuildInfoNewRespond(msgTbl)
    gt.dump(msgTbl, "-----onGuildInfoNewRespond-----")
    gt.removeLoadingTips()

    if 0 ~= msgTbl.errno then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), string.format("请求牌友圈房间信息失败:[%s]", msgTbl.error), nil, nil, true)
    else
        self.disObjs.lvItemsNew:removeAllChildren()
        local rooms = msgTbl.list
        self.disObjs.imgNoInfoTip:setVisible(#rooms == 0)
        self.disObjs.imgLittleGirl:setVisible(#rooms == 0)
        self.disObjs.imgLvTitleBkg:setVisible(#rooms > 0)
        gt.noneGuildRoomsCreated = #rooms == 0
        for i=1, #rooms do
            local data = rooms[i]
            local copy = self.disObjs.lvItemsNewItem:clone()
            local details = data
            details.club_id = msgTbl.club_id
            copy.details = details
            local txtGameName = copy:getChildByName("txtGameName")
            txtGameName:ignoreContentAdaptWithSize(true)
            local txtGameRoom = copy:getChildByName("txtGameRoom")
            txtGameRoom:ignoreContentAdaptWithSize(true)
            local txtGameRound = copy:getChildByName("txtGameRound")
            txtGameRound:ignoreContentAdaptWithSize(true)
            local txtGameCapacity = copy:getChildByName("txtGameCapacity")
            txtGameCapacity:ignoreContentAdaptWithSize(true)
            local btnRoomInvite = copy:getChildByName("btnRoomInvite")
            txtGameName:setString(gt.GameTypeDesc[data.game_type])
            txtGameRoom:setString(data.room_id)
            txtGameRound:setString(data.config.round_count.."局")
            txtGameCapacity:setString(data.cur_player_count.."/"..data.player_count)
            gt.addBtnPressedListener(btnRoomInvite, function(target, event)
                local roomInfo = {}
                roomInfo.config = data.config
                roomInfo.roomid = data.room_id
                roomInfo.curPlayerNum = data.cur_player_count
                roomInfo.club = "club"
                gt.shareZipaiRoomInfo(roomInfo)
            end)
            copy:setTouchEnabled(true)
            copy:addTouchEventListener(function (target, event)
                if TOUCH_EVENT_ENDED == event then
                    gt.showLoadingTips()
                    local msgToSend = {}
		            msgToSend.cmd = gt.JOIN_ROOM
		            msgToSend.room_id = data.room_id
		            msgToSend.app_id = gt.app_id
		            msgToSend.user_id = gt.playerData.uid
		            msgToSend.ver = gt.version
		            msgToSend.dev_id = gt.getDeviceId()
		            gt.socketClient:sendMessage(msgToSend)
                    gt.recordedGuildID = club_id
                end
            end)
            self.disObjs.lvItemsNew:pushBackCustomItem(copy)
        end
    end
end

function EntryMainScene:newShopEffects(flag)
    if self.disObjs.btnShopNew then
        local dots = self.disObjs.btnShopNew:getChildren()
        for i=1, 4 do
            local dots = self.disObjs.btnShopNew:getChildByName("imgP"..i)
            if flag then
                dots:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1), cc.FadeOut:create(1))))
            else
                dots:stopAllActions()
            end
        end
    end
end

function EntryMainScene:onAccountLogoutStatus(msgTbl)
    gt.dump(msgTbl, "--------------------onAccountLogoutStatus---------------")
    local function exitHall()
        gt.recordedGuildID = nil
        gt.noneGuildRoomsCreated = nil
        gt.isCurGuildOwner = nil
        cc.UserDefault:getInstance():setStringForKey("last_auto_login_info", cjson.encode({login_mode="none", open_id=""}))
        cc.UserDefault:getInstance():setStringForKey("vcode", "")
        require("app/DragonBoneCreator"):disposeAllDBs()
		gt.socketClient:close()
		local loginScene = require("app/views/LoginScene"):create()
		cc.Director:getInstance():replaceScene(loginScene)
	end

    if msgTbl.errno == 0 then
    elseif msgTbl.errno == 1 then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), msgTbl.error, function ()
            exitHall()
        end, function ()
            exitHall()
        end, true)
        gt.socketClient:close()
    end
end

function EntryMainScene:onBackMainScene()
    if nil == self.scheduleHandler then self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.joinRoomFromUrl), 1.25, false) end
end

function EntryMainScene:onBindPhoneUpdated(event, params)
    self.disObjs.btnBindPhone:setVisible(false)
end

function EntryMainScene:onMainSceneGuildRoomsUpdated(event, data)
    gt.log("-------onMainSceneGuildRoomsUpdated---------")
--    gt.dump(data)
    if nil ~= data and nil ~= data.rooms then
        if self.dymAttrs.mainSceneGuildID == data.guildID then
            self.disObjs.imgNoInfoTip:setVisible(table.nums(data.rooms) == 0)
            self.disObjs.imgLittleGirl:setVisible(table.nums(data.rooms) == 0)
        end
    end
end

function EntryMainScene:onMainSceneStyleUpdated(event, data)
    if data ~= nil then
        gt.dump(data, "主界面样式已更新")
        self.disObjs.imgSwitcherMatch:setVisible(false)
        if "classic" == data.style then
            self.disObjs.imgBkg:loadTexture(RES_REF.IMG.MAIN_SCENE_CLASSIC_BKG, gt.defaultImageLoadedType)
            self.disObjs.imgTitle:loadTexture(RES_REF.IMG.MAIN_SCENE_CLASSIC_TOP_TITLE, gt.defaultImageLoadedType)
            self.disObjs.btnCards:loadTextureNormal(RES_REF.IMG.MAIN_SCENE_CLASSIC_ADD_CARD, gt.defaultImageLoadedType)
            self.disObjs.imgBottomMenusNew:setVisible(false)
            self.disObjs.layoutRoomMenuNew:setVisible(false)
            self.disObjs.imgGuildInfoNew:setVisible(false)
            self.disObjs.btnServiceNew:setVisible(false)
            self.disObjs.btnAccountAuthorizedNew:setVisible(false)
            self.disObjs.btnInviteNew:setVisible(false)

            self.disObjs.imgLogo:setVisible(true)
            self.disObjs.imgLogo:setPositionX(self.disObjs.imgTitle:getContentSize().width * 0.5)
            self.disObjs.imgBottomMenus:setVisible(true)
            self.disObjs.btnCreateRoom:setVisible(true)
            self.disObjs.btnJoinRoom:setVisible(true)
            self.disObjs.btnGuild:setVisible(true)
            if nil ~= self.disObjs.layoutNode:getChildByName(require("app/DragonBoneCreator").DEFUALT_ARMATURE_NAME) then
                self.disObjs.layoutNode:getChildByName(require("app/DragonBoneCreator").DEFUALT_ARMATURE_NAME):setVisible(true)
            end
            self.disObjs.btnExperience:setVisible(true)
            self.disObjs.btnAccountAuthorized:setVisible(true)
            self.disObjs.btnInvite:setVisible(true)

            self.disObjs.marqueeNodeBkg:loadTexture(RES_REF.IMG.MAIN_SCENE_CLASSIC_NOTICE_BKG, gt.defaultImageLoadedType)
            self.disObjs.marqueeNodeBkg:setContentSize(cc.size(665, 44))
            self:newShopEffects(false)

            --国庆特辑
--            self:changeClassicResForNationalDay()
        elseif "popular" == data.style then
            self.disObjs.imgBkg:loadTexture(RES_REF.IMG.MAIN_SCENE_POPULAR_BKG, gt.defaultImageLoadedType)
            self.disObjs.imgTitle:loadTexture(RES_REF.IMG.MAIN_SCENE_POPULaR_TOP_TITLE, gt.defaultImageLoadedType)
            self.disObjs.btnCards:loadTextureNormal(RES_REF.IMG.MAIN_SCENE_POPULAR_ADD_CARD, gt.defaultImageLoadedType)
            self.disObjs.imgLogo:setVisible(false)
            self.disObjs.imgBottomMenus:setVisible(false)
            self.disObjs.btnCreateRoom:setVisible(false)
            self.disObjs.btnJoinRoom:setVisible(false)
            self.disObjs.btnGuild:setVisible(false)
            if nil ~= self.disObjs.layoutNode:getChildByName(require("app/DragonBoneCreator").DEFUALT_ARMATURE_NAME) then
                self.disObjs.layoutNode:getChildByName(require("app/DragonBoneCreator").DEFUALT_ARMATURE_NAME):setVisible(false)
            end
            self.disObjs.btnExperience:setVisible(false)
            self.disObjs.btnAccountAuthorized:setVisible(false)
            self.disObjs.btnInvite:setVisible(false)

            self.disObjs.imgBottomMenusNew:setVisible(true)
            self.disObjs.layoutRoomMenuNew:setVisible(true)
            self.disObjs.imgGuildInfoNew:setVisible(true)
            self.disObjs.btnServiceNew:setVisible(true)
            self.disObjs.btnAccountAuthorizedNew:setVisible(true)
            self.disObjs.btnInviteNew:setVisible(true)

            self.disObjs.marqueeNodeBkg:loadTexture(RES_REF.IMG.MAIN_SCENE_POPULAR_NOTICE_BKG, gt.defaultImageLoadedType)
            self.disObjs.marqueeNodeBkg:setContentSize(cc.size(665, 35))
            self:newShopEffects(true)

            --国庆特辑
--            self:changePopularResForNationalDay()
            local msgToSend = {}
	        msgToSend.cmd = gt.CLUB_LIST
            msgToSend.snapshot = true
	        gt.socketClient:sendMessage(msgToSend)
        end
    end
end

function EntryMainScene:onExitFromReplay(event, data)
    if data ~= nil then
        local prevGuild = self:getChildByName("CombatGains")
        if not tolua.isnull(prevGuild) then
            prevGuild:removeFromParent()
        end
        local historyRecord = require("app/views/CombatGains"):create(gt.playerData.uid, data, data.guildID)
        historyRecord:setName("CombatGains")
		self:addChild(historyRecord, EntryMainScene.CONSTANTS.ZOrder.HISTORY_RECORD)
    end
end

function EntryMainScene:onBackMainSceneReceived(code, code2)
    if code2 == gt.BackMainSceneCode.BE_KICKED then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "您已被房间管理员请离房间", nil, nil, true, self)
    elseif code2 == gt.BackMainSceneCode.BE_KICKED_FANGZHU then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "您已被房主请离房间", nil, nil, true, self)
    elseif code2 == gt.BackMainSceneCode.BE_KICKED_CLUB then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "您已被牌友圈管理员请离房间", nil, nil, true, self)
    elseif code2 == gt.BackMainSceneCode.DISMISS_ROOM then
        require("app/views/CommonTips"):create("房间已解散",self)
    elseif code2 == gt.BackMainSceneCode.DISMISS_LEADER then
        require("app/views/CommonTips"):create("房间管理员已解散房间",self)
    elseif code2 == gt.BackMainSceneCode.DISMISS_FANGZHU then
        require("app/views/CommonTips"):create("房主已解散房间",self)
    elseif code2 == gt.BackMainSceneCode.DISMISS_VOTE then
        require("app/views/CommonTips"):create("房间已解散", self)
    elseif code2 == gt.BackMainSceneCode.BE_KICKED_CARDS_LESS then
        require("app/views/CommonTips"):create("房卡不足，无法继续游戏", self)
    end

    if gt.hallSettings.MusicBgVolume == "on" then
		gt.soundEngine:playMusic(RES_REF.SOUND.BGM_1, true)
	end
end

function EntryMainScene:onRcvLoginUserId(msgTbl)
    gt.dump(msgTbl, "--------------------onRcvLoginUserId---------------")
	gt.removeLoadingTips()
	if msgTbl.code == 0 then
		local playerData = gt.playerData
		playerData.roomCardsCount = {msgTbl.card, msgTbl.card, msgTbl.card}
        self.disObjs.txtCards:setString(playerData.roomCardsCount[1])
	else
		-- 1:会话已过期，请重新登录
		-- 2:账号校验失败，请重新登录
		local function exitHall()
			self:removeFromParent()

			-- 关闭socket连接时,赢停止当前定时器
			if gt.socketClient.scheduleHandler then
				gt.scheduler:unscheduleScriptEntry(gt.socketClient.scheduleHandler)
			end

			-- 关闭事件回调
			gt.removeTargetAllEventListener(gt.socketClient)

			gt.socketClient:close()

			local loginScene = require("app/views/LoginScene"):create()
			cc.Director:getInstance():replaceScene(loginScene)
		end
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0059"), exitHall, nil, true)
	end
end

function EntryMainScene:onExitFromGuildRoom(event, params)
    gt.dump(params, "------------------onExitFromGuildRoom----------------------")
    if nil ~= params then
        gt.socketClient:unregisterMsgListener(gt.CLUB_LIST)
        gt.socketClient:unregisterMsgListener(gt.CLUB_CREATE)
        gt.socketClient:unregisterMsgListener(gt.CLUB_JOIN)
        gt.socketClient:unregisterMsgListener(gt.CLUB_INFO_NEW)
        gt.socketClient:unregisterMsgListener(gt.CLUB_REFRESH_ROOM_CURRENT)
        gt.socketClient:unregisterMsgListener(gt.CLUB_SYS_MESSAGE)
        local prevGuild = self:getChildByName("guildMainScene")
        if not tolua.isnull(prevGuild) then
            prevGuild:removeFromParent()
        end

        gt.recordedGuildID = params.id or nil
        local guild = require("app/views/GuildMainScene"):create({openJoinDlg=false, guildID=gt.recordedGuildID})
        guild:setName("guildMainScene")
        self:addChild(guild, EntryMainScene.CONSTANTS.ZOrder.GUILD)
    else                
        gt.socketClient:registerMsgListener(gt.CLUB_LIST, self, self.onGuildListRespond)
        gt.socketClient:registerMsgListener(gt.CLUB_CREATE, self, self.onGuildCreateRespond)
        gt.socketClient:registerMsgListener(gt.CLUB_JOIN, self, self.onGuildJoinRespond)
        gt.socketClient:registerMsgListener(gt.CLUB_INFO_NEW, self, self.onGuildInfoNewRespond)
        gt.socketClient:registerMsgListener(gt.CLUB_REFRESH_ROOM_CURRENT, self, self.onGuildCreatedRoomRefreshRespond)
        gt.socketClient:registerMsgListener(gt.CLUB_SYS_MESSAGE, self, self.onGuildSysMessageRespond)
        local msgToSend = {}
	    msgToSend.cmd = gt.CLUB_LIST
        msgToSend.snapshot = true
	    gt.socketClient:sendMessage(msgToSend)
    end
end

function EntryMainScene:onGuildJoinRespond(msgTbl)
    gt.dump(msgTbl, "-----onGuildJoinRespond-----")

    gt.removeLoadingTips()
    if 0 ~= msgTbl.errno then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), string.format("加入牌友圈失败:[%s]", msgTbl.error), nil, nil, true)
        gt.dispatchEvent(gt.EventType.GUILD_JOIN_ID_INVALID)
    else
        require("app/views/CommonTips"):create(gt.getLocationString("LTKey_0077"))
        local guildPreCreateScene = self:getChildByName("guildPreCreateScene")
        if nil ~= guildPreCreateScene then
            guildPreCreateScene:removeFromParent()
        end
    end
end

function EntryMainScene:onGuildCreateRespond(msgTbl)
    gt.dump(msgTbl, "-----onGuildCreateRespond-----")

    gt.removeLoadingTips()
    if 0 ~= msgTbl.errno then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), string.format("创建牌友圈失败:[%s]", msgTbl.error), nil, nil, true)
    else
        --创建牌友圈成功需客户端主动刷新列表
        require("app/views/CommonTips"):create("牌友圈创建成功!")
        local guildPreCreateScene = self:getChildByName("guildPreCreateScene")
        if nil ~= guildPreCreateScene then
            guildPreCreateScene:removeFromParent()
        end
        gt.socketClient:unregisterMsgListener(gt.CLUB_LIST)
        gt.socketClient:unregisterMsgListener(gt.CLUB_CREATE)
        gt.socketClient:unregisterMsgListener(gt.CLUB_JOIN)
        gt.socketClient:unregisterMsgListener(gt.CLUB_INFO_NEW)
        gt.socketClient:unregisterMsgListener(gt.CLUB_REFRESH_ROOM_CURRENT)
        gt.socketClient:unregisterMsgListener(gt.CLUB_SYS_MESSAGE)
        local guild = require("app/views/GuildMainScene"):create({openJoinDlg=false, guildID=gt.recordedGuildID})
        guild:setName("guildMainScene")
        self:addChild(guild, EntryMainScene.CONSTANTS.ZOrder.GUILD)
    end
end

function EntryMainScene:onGuildListRespond(msgTbl)
    gt.dump(msgTbl, "-----onGuildListRespond-----")
    
    gt.removeLoadingTips()
    if 0 ~= msgTbl.errno then
        require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), string.format("获取牌友圈列表失败:[%s]", msgTbl.error), nil, nil, true)
    else
        if true == msgTbl.snapshot then
            --牌友圈房间简介显示
            local count = table.nums(msgTbl.list)
            local roomFound = false
            if 0 < count then
                for i=1, count do
                    if msgTbl.list[i].count > 0 then
                        local firstGuildInfo = msgTbl.list[i]
                        local msgToSend = {}
                        msgToSend.cmd = gt.CLUB_INFO_NEW
                        msgToSend.club_id = firstGuildInfo.id
	                    gt.socketClient:sendMessage(msgToSend)
                        self.dymAttrs.noneGuildCreated = false
                        self.dymAttrs.mainSceneGuildID = firstGuildInfo.id
                        break
                    end
                end

                if not roomFound then
                    self.disObjs.lvItemsNew:removeAllChildren()
                end
            else
                self.dymAttrs.noneGuildCreated = true
                self.disObjs.imgNoInfoTip:setVisible(true)
                self.disObjs.imgLittleGirl:setVisible(true)
                self.disObjs.lvItemsNew:removeAllChildren()
            end
        else
            if 0 < table.nums(msgTbl.list) then
                self.dymAttrs.noneGuildCreated = false
                gt.socketClient:unregisterMsgListener(gt.CLUB_LIST)
                gt.socketClient:unregisterMsgListener(gt.CLUB_CREATE)
                gt.socketClient:unregisterMsgListener(gt.CLUB_JOIN)
                gt.socketClient:unregisterMsgListener(gt.CLUB_INFO_NEW)

                local guild = require("app/views/GuildMainScene"):create({openJoinDlg=false, guildID=gt.recordedGuildID, guildListBeforeOpen=msgTbl.list})
                guild:setName("guildMainScene")
                self:addChild(guild, EntryMainScene.CONSTANTS.ZOrder.GUILD)
            else
                self.dymAttrs.noneGuildCreated = true
                local preEnterGuild = require("app/views/PreEnterGuild"):create({parent=self, zOrder=EntryMainScene.CONSTANTS.ZOrder.GUILD})
		        self:addChild(preEnterGuild, EntryMainScene.CONSTANTS.ZOrder.GUILD)

                self.disObjs.imgLvTitleBkg:setVisible(false)
                self.disObjs.imgNoInfoTip:setVisible(true)
                self.disObjs.imgLittleGirl:setVisible(true)
            end 
        end
    end
end

function EntryMainScene:onRcvMarquee(msgTbl)
	gt.marqueeMsgTemp = msgTbl.msg
	self.marqueeMsg:showMsg(msgTbl.msg)
end

function EntryMainScene:onRcvRoomCard(msgTbl)
	local playerData = gt.playerData
	playerData.roomCardsCount = {msgTbl.card, msgTbl.card, msgTbl.card}

    self.disObjs.txtCards:setString(playerData.roomCardsCount[1])
end

function EntryMainScene:reLogin()
	gt.log("========重连登录")
	if gt.playerData.uid then
        local msgToSend = {}
		msgToSend.cmd = gt.LOGIN_USERID
		msgToSend.open_id = gt.playerData.openid
        msgToSend.ver = gt.alphaVertion
        msgToSend.app_id = gt.app_id
		gt.socketClient:sendMessage(msgToSend)
	end

    self.disObjs.btnExperience:setTouchEnabled(true)
end

function EntryMainScene:onRcvEnterGame(msgTbl)
	gt.removeLoadingTips()
    gt.dump(msgTbl, "---------------onRcvEnterGame------------------")
	
	gt.GameServer.ip	= msgTbl.host
	gt.GameServer.port	= msgTbl.port
    gt.token            = msgTbl.token

	gt.socketClient:close()
	if gt.socketClient:connect(gt.GameServer.ip, gt.GameServer.port, true) then
		gt.socketClient:unregisterMsgListener(gt.ENTER_GAME)
		gt.socketClient:unregisterMsgListener(gt.ROOM_CARD)
		gt.socketClient:unregisterMsgListener(gt.NOTICE)
		gt.socketClient:unregisterMsgListener(gt.LOGIN)
		gt.socketClient:unregisterMsgListener(gt.LOGIN_USERID)
		gt.socketClient:unregisterMsgListener(gt.JOIN_ROOM)
		gt.socketClient:unregisterMsgListener(gt.ALL_ACTIVITY_INFO)
		gt.removeTargetAllEventListener(self)
        if msgTbl.game_type == gt.GameType.GAME_GLZP then
            --require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), "创建房间成功，等待添加房间UI", nil, nil, true)
            require("app/DragonBoneCreator"):disposeAllDBs()
            local gameScene =  require("app/views/GuilinZipaiScene"):create(msgTbl)
            cc.Director:getInstance():replaceScene(gameScene)
        else

        end
	end
end

function EntryMainScene:onRcvJoinRoom(msgTbl)
	if msgTbl.code ~= 0 then
		-- 进入房间失败
		gt.removeLoadingTips()
		-- 1：未登录 2：服务器维护中 3：房卡不足 4：人数已满 5：房间不存在 6：中途不能加入
		local errorMsg = ""
		if msgTbl.code == 1 then
			errorMsg = gt.getLocationString("LTKey_0058")
		elseif msgTbl.code == 2 then
			errorMsg = gt.getLocationString("LTKey_0054")
		elseif msgTbl.code == 3 then
			errorMsg = msgTbl.error ~= nil and msgTbl.error or gt.getLocationString("LTKey_0062")
		elseif msgTbl.code == 4 then
			errorMsg = gt.getLocationString("LTKey_0018")
		elseif msgTbl.code == 5 then
			errorMsg = gt.getLocationString("LTKey_0015")
		elseif msgTbl.code == 6 then
			errorMsg = gt.getLocationString("LTKey_0057")
		end
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), errorMsg, nil, nil, true)

        gt.dispatchEvent(gt.EventType.JOGIN_ROOM_NO_INVALID, msgTbl)
	end
end


function EntryMainScene:onRcvWatchReplay(msgTbl)
	if msgTbl.code ~= 0 then
		-- 进入房间失败
		gt.removeLoadingTips()
		-- 错误代码说明
		local errorMsg = "战绩数据不存在！"
        if msgTbl.code == 3 then 
            errorMsg = "该分享码不存在!请重新输入"
        end
	    require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), errorMsg, nil, nil, true)
    else
        require("app/DragonBoneCreator"):disposeAllDBs()
        local replayScene = require("app/views/GuilinZipaiReplay"):create(msgTbl, nil, msgTbl.seat)
        cc.Director:getInstance():replaceScene(replayScene)
	end
end

function EntryMainScene:onRcvPayResult(msgTbl)
	if msgTbl.code == 0 then
		local count = msgTbl.count
        local source = msgTbl.source
        if 3 == source then
            gt.log("客服代为充值")
        else
        	local rechargeSucess = require("app/views/ChargedNotice"):create(2, count, msgTbl.payMoney, msgTbl.chargeUser)
		    self:addChild(rechargeSucess, EntryMainScene.CONSTANTS.ZOrder.PAY_RESULT)
        end
	else
		require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString("LTKey_0060"), nil, nil, true)
	end
end

function EntryMainScene:invokeProxyRecruitCopy()
    gt.log("--------invokeProxyRecruitCopy---------")
    if self.scheduleHandler then
		gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		self.scheduleHandler = nil
	end
end

function EntryMainScene:onAuthorizedCivicID(params)
    gt.log("onAuthorizedCivicID:")
    gt.playerData.real_name = true
end

function EntryMainScene:onAuthorizedCooldownStart(eventType, startSecond, sceneName)
    self.realNameStartSecond = startSecond
    if nil ~= self.realNameScheduleHandler or (nil ~= self.authorizedCooldownStartFromScene and sceneName ~= self.authorizedCooldownStartFromScene) then
        gt.scheduler:unscheduleScriptEntry(self.realNameScheduleHandler)
    end
    self.authorizedCooldownStartFromScene = sceneName
    self.realNameScheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.onRealNameAuthorizedUpdate), 1, false)
end

function EntryMainScene:onRealNameAuthorizedUpdate(delta)
    self.realNameStartSecond = self.realNameStartSecond - 1
    if -1 == self.realNameStartSecond then
        gt.scheduler:unscheduleScriptEntry(self.realNameScheduleHandler)
    end
    gt.dispatchEvent(gt.EventType.AUTHORIZE_COOL_DOWN_RUNNING, self.realNameStartSecond, self.authorizedCooldownStartFromScene)

    if "realName" == self.authorizedCooldownStartFromScene then
        cc.UserDefault:getInstance():setStringForKey("RealNameCoolDown", tostring(self.realNameStartSecond))
    elseif "phoneAuthorized" == self.authorizedCooldownStartFromScene then
        cc.UserDefault:getInstance():setStringForKey("PhoneAuthorizedCoolDown", tostring(self.realNameStartSecond))
    end
end

function EntryMainScene:joinRoomFromUrl()
--    gt.log("-------------------joinRoomFromUrl-------------------checking")
    local urlRoomId = extension.getURLRoomID()
    if "" ~= urlRoomId and nil ~= urlRoomId then
        local roomIDStr = string.match(urlRoomId,"roomid=(%d+)")
        local replayCodeStr = string.match(urlRoomId,"replayCode=(%d+)")
        local guildIDStr = string.match(urlRoomId,"guildID=(%d+)")
        -- 从url进入房间
        local roomID = 0
        local replayCode = 0
        local guildID = 0
        if roomIDStr then
            roomID = tonumber(roomIDStr)
        end
	    if replayCodeStr then
            replayCode = tonumber(replayCodeStr)
        end
        if guildIDStr then
            guildID = tonumber(guildIDStr)
        end

        gt.log("-------------自动进入房间---:"..roomID)

	    if roomID and roomID > 0 then
		    local msgToSend = {}
		    msgToSend.cmd = gt.JOIN_ROOM
		    msgToSend.room_id = roomID
		    msgToSend.app_id = gt.app_id
		    msgToSend.user_id = gt.playerData.uid
		    msgToSend.ver = gt.version
		    msgToSend.dev_id = gt.getDeviceId()
		
		    gt.socketClient:sendMessage(msgToSend)
		    gt.socketClient:registerMsgListener(gt.JOIN_ROOM, self, self.onRcvJoinRoom)
		    gt.showLoadingTips(gt.getLocationString("LTKey_0006"))
		    return true
        elseif replayCode and replayCode > 0 then
            local msgToSend = {}
		    msgToSend.cmd = gt.ROOM_REPLAY
		    msgToSend.code = replayCode
		    gt.socketClient:sendMessage(msgToSend)
            gt.socketClient:registerMsgListener(gt.ROOM_REPLAY, self, self.onRcvWatchReplay)
        elseif guildID and guildID > 0 then
            --牌友圈状态保留
            if true == gt.guildMainSceneOpend then
                local guild = self:getChildByName("guildMainScene")
                if nil ~= guild then
                    local guildPreCreateScene = require("app/views/GuildPreCreateScene"):create({showType="join", guildID=guildID})
                    guildPreCreateScene:setName("guildPreCreateScene")
	                guild:addChild(guildPreCreateScene)
                end
            else
                local guildPreCreateScene = require("app/views/GuildPreCreateScene"):create({showType="join", guildID=guildID})
                guildPreCreateScene:setName("guildPreCreateScene")
	            self:addChild(guildPreCreateScene)
            end
            return false
        else
            return false
	    end
    else
       return false  
    end
end

function EntryMainScene:hasServerMaintainceNotice(owner, isIgnore)
    if gt.hasServerMaintainceNoticeDisplayed then
        return
    end

    gt.showLoadingTips("")

    if owner.xhr == nil then
        owner.xhr = cc.XMLHttpRequest:new()
        owner.xhr.timeout = 30 -- 设置超时时间
    end
    owner.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local url = gt.SERVER_MAINTAIN_NOTICE
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
--                gt.log("---sz#owner.serverNoticeBody__:"..#owner.serverNoticeBody)
--                gt.log("---sz#owner.serverNoticeTitle_:"..#owner.serverNoticeTitle)
                if #owner.serverNoticeBody > 0 then
                    local agreementPanel = require("app/views/ServerNotice"):create(owner.serverNoticeTitle, owner.serverNoticeBody)
                    owner:addChild(agreementPanel, EntryMainScene.CONSTANTS.ZOrder.SERVER_NOTICE)
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

function EntryMainScene:hasVersionUpdateLogs(owner)
    if gt.hasVersionUpdateLogDisplayed then
        return
    end

    gt.showLoadingTips("")

    if owner.xhrForUpdateLog == nil then
        owner.xhrForUpdateLog = cc.XMLHttpRequest:new()
        owner.xhrForUpdateLog.timeout = 30 -- 设置超时时间
    end
    owner.xhrForUpdateLog.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    gt.VERSION_UPDATE_LOG_QA = gt.VERSION_UPDATE_LOG_QA or "http://47.98.47.131:81/updateinfo_get"
    gt.VERSION_UPDATE_LOG_RE = gt.VERSION_UPDATE_LOG_RE or "http://47.98.167.36/updateinfo_get"
    local url = gt.VERSION_UPDATE_LOG_QA
    if gt.LoginServer.ip == "47.98.47.131" then
        url = gt.VERSION_UPDATE_LOG_QA
    else
        url = gt.VERSION_UPDATE_LOG_RE
    end

    owner.xhrForUpdateLog:open("GET", url)
    owner.xhrForUpdateLog:registerScriptHandler(function ()
        if owner.xhrForUpdateLog.readyState == 4 and (owner.xhrForUpdateLog.status >= 200 and owner.xhrForUpdateLog.status < 207) then

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
        local prepare, num = string.gsub(owner.xhrForUpdateLog.response, "\\", "\\\\")
        local xhrParsedResp = json.decode(prepare)
        gt.dump(xhrParsedResp, "------------------xxxxxxxxxxxxxxxxxxxxx")
        local showVersionUpdateLogs = false
        local versionUpdateSN = cc.UserDefault:getInstance():getStringForKey("versionUpdateSN")
        gt.log("--------versionUpdateSN-----:"..versionUpdateSN)
        if "" == versionUpdateSN then
            if 0 < #xhrParsedResp.sn and 0 < #xhrParsedResp.body then
                showVersionUpdateLogs = true
            end
        else
            if tonumber(xhrParsedResp.sn) > tonumber(versionUpdateSN) then
                showVersionUpdateLogs = true
            end

            if 0 == #xhrParsedResp.body then
                showVersionUpdateLogs = false
            end
        end

        if showVersionUpdateLogs then
            local versionUpdateLog = require("app/views/VersionReleaseLog"):create(unicode_to_utf8(xhrParsedResp.sn), unicode_to_utf8(xhrParsedResp.body))
            owner:addChild(versionUpdateLog, EntryMainScene.CONSTANTS.ZOrder.UPDATE_NOTICE)
            gt.hasVersionUpdateLogDisplayed = true
            cc.UserDefault:getInstance():setStringForKey("versionUpdateSN", xhrParsedResp.sn)
        end

        elseif owner.xhrForUpdateLog.readyState == 1 and owner.xhrForUpdateLog.status == 0 then
            -- 网络问题,异常断开
            gt.removeLoadingTips()
        end
        owner.xhrForUpdateLog:unregisterScriptHandler()
    end)
    owner.xhrForUpdateLog:send()
end

function EntryMainScene:onNodeEvent(eventName)
	if "enter" == eventName then
        gt.log("-----------EntryMainScene--------onNodeEvent--------enter-------")
        extension.stopVoicePlay()
        gt.soundEngine:clearVoicePlayQueue()

		if not self:joinRoomFromUrl() then	-- 先检测，发现没有房间ID再启动定时器监视
            self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.joinRoomFromUrl), 1.25, false)
		end

        if gt.DISMISS_ROOM == self.invokeMsg then
            require("app/views/CommonTips"):create("解散房间成功")
        end

        if self.showMoveText  then
	      require("app/views/CommonTips"):create(self.showMoveText)
	    end

        self:hasVersionUpdateLogs(self)
        self:hasServerMaintainceNotice(self)
	elseif "exit" == eventName then
        gt.log("-----------EntryMainScene--------onNodeEvent--------exit-------")
		if self.scheduleHandler then
			gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
			self.scheduleHandler = nil
		end

		if schedulerID then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerID)  
		end

        gt.removeTargetEventListenerByType(self, gt.EventType.AUTHORIZE_CIVIC_ID)
        gt.removeTargetEventListenerByType(self, gt.EventType.AUTHORIZE_COOL_DOWN_START)
        gt.removeTargetEventListenerByType(self, gt.EventType.PLAY_SCENE_RESET)
        gt.removeTargetEventListenerByType(self, gt.EventType.PROXY_RECRUIT_COPY)
        gt.removeTargetEventListenerByType(self, gt.EventType.GUILD_EXIT_FROM_ROOM)
        gt.removeTargetEventListenerByType(self, gt.EventType.BACK_FROM_GAME)
        gt.removeTargetEventListenerByType(self, gt.EventType.BIND_PHONE_UPDATED)
        gt.removeTargetEventListenerByType(self, gt.EventType.BACK_FROM_REPLAY)
        gt.removeTargetEventListenerByType(self, gt.EventType.MAIN_SCENE_STYLE_UPDATED)
        gt.removeTargetEventListenerByType(self, gt.EventType.MAIN_SCENE_GUILD_ROOMS_UPDATED)

        gt.socketClient:unregisterMsgListener(gt.CLUB_LIST)
        gt.socketClient:unregisterMsgListener(gt.CLUB_CREATE)
        gt.socketClient:unregisterMsgListener(gt.CLUB_JOIN)
        gt.socketClient:unregisterMsgListener(gt.CLUB_INFO_NEW)
        gt.socketClient:unregisterMsgListener(gt.CLUB_REFRESH_ROOM_CURRENT)
        gt.socketClient:unregisterMsgListener(gt.CLUB_SYS_MESSAGE)

        if nil ~= realNameScheduleHandler then
            gt.scheduler:unscheduleScriptEntry(self.realNameScheduleHandler)
            cc.UserDefault:getInstance():setStringForKey("RealNameCoolDown", tostring(self.realNameStartSecond))
        end

        self.disObjs.imgSubMenus:release()
        self.disObjs.lvItemsNewItem:release()
	end
end

return EntryMainScene
--endregion