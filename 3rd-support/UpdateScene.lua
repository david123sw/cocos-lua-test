local gt = cc.exports.gt

require("app/Extension")

local project_manifest_prefix = ""
local projectmanifest_filename = "project.manifest"
local ver_filename  = "version.manifest"
local writePath = cc.FileUtils:getInstance():getWritablePath()
local downList      = {}

local InitText = {}
InitText[1] = "正在检查更新,请稍候……"
InitText[2] = "更新中,请稍候……"
InitText[3] = "正在启动游戏，请稍候……"
InitText[4] = "触摸屏幕开始"
InitText[5] = "读取manifest[%s]文件错误"
InitText[6] = "已是最新版无需更新"
InitText[7] = "创建目录失败"
InitText[8] = "下载文件错误"
InitText[9] = "正在更新文件"
InitText[10] = "更新配置文件格式错误"
InitText[11] = "更新完成"
InitText[12] = "正在检查文件"
InitText[13] = "正在写入文件"
InitText[14] = "校验文件失败"

local md5 = require("app.libs.pure_lua_md5")

local function hex(s)
    s=string.gsub(s,"(.)",function (x) return string.format("%02X",string.byte(x)) end)
    -- gt.log("====数值",s)
    return s, string.len(s)
end

-- 读取文件
local function readFile( path )
    local file = io.open( path, "rb" )
    if file then
        local content = file:read( "*all" )
        io.close(file)
        return content
    end

    return nil
end

local function checkDirOK( path )
    local cpath = cc.FileUtils:getInstance():isFileExist(path)
    if cpath then
        return true
    end

    return cc.FileUtils:getInstance():createDirectory( path )
end

-- 比较获取需要下载的文件名字
local function compManifest( oList, newList )
    local oldList = {}
    for k,v in pairs(oList) do
        oldList[k] = v["md5"]
    end

    local list = {}
    for k,v in pairs(newList) do
        local name = k
        if v["md5"] ~= oldList[k] then
            local saveTab = {}
            saveTab.name    = name
            saveTab.path    = v["path"]
            saveTab.md5code = v["md5"]
            table.insert( list, saveTab )
        end
    end

    return list
end

local function checkFile( fileName, cryptoCode )
    if not io.exists(fileName) then -- 测试fileName文件是否存在
        return false -- 如果文件不存在,那么返回false
    end

    local data = readFile(fileName)
    if data == nil then
        return false
    end

    if cryptoCode == nil then
        return true
    end

    local ms = md5.sumhexa(data)
    if ms == cryptoCode then
        -- gt.log("md5 一致", fileName)
        return true
    else
        -- gt.log("md5 不一致", fileName, cryptoCode, ms)
        return false
    end

    return true
end

local function checkCacheDirOK( root_dir, path )
    path = string.gsub( string.trim(path), "\\", "/" )
    local info = io.pathinfo(path)
    if not checkDirOK(root_dir..info.dirname) then
        return false
    end

    return true
end

local function removeFile( path )
    io.writefile(path, "")
    if device.platform == "windows" then
        os.remove(string.gsub(path, '/', '\\'))
    else
        cc.FileUtils:getInstance():removeFile( path )
    end
end

local function renameFile(path, newPath)
    removeFile(newPath)
    os.rename(path, newPath)
    -- gt.log("renameFile---------------> " .. path .. "  ==> " .. newPath)
end


-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
-- UpdateScene类
-------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------
local UpdateScene = class("UpdateScene", function()
    return cc.Scene:create()
end)

function UpdateScene:ctor()
    gt.log("----------------------------------begin---------------------------------hot--------------------------------------update:writePath:"..writePath)


    self:registerScriptHandler(handler(self, self.onNodeEvent))

    local csbNode = cc.CSLoader:createNode("csd/UpdateScene.csb")
	csbNode:setAnchorPoint(0.5, 0.5)
    csbNode:setPosition(gt.winCenter)
    self:addChild(csbNode)
    gt:adjustSceneDisplay(csbNode)
    

    gt.seekNodeByName(csbNode,"Node_Logo"):setVisible(false)
    -- 是否更新成功,更新失败会有tip提示
    self.updateSuccess = false
    -- 接收到的数据
    self.dataRecv   = nil
    -- 下载url
    self.updateURL  = nil

    -- 显示更新状态
    local progressLabel = gt.seekNodeByName(csbNode, "Label_Progress")
    progressLabel:setString("检查资源更新...")
    self.progressLabel = progressLabel
    local fadeOut = cc.FadeOut:create(1)
    local fadeIn = cc.FadeIn:create(1)
    local seqAction = cc.Sequence:create(fadeOut, fadeIn)
    progressLabel:runAction(cc.RepeatForever:create(seqAction))

    -- 更新进度条
    self.updateSlider = gt.seekNodeByName(csbNode, "Slider_Update")
    if self.updateSlider then
        self.updateSlider:setVisible( true )
        self.updateSlider:setPercent(0)
    end

--    local logoNode = gt.seekNodeByName(csbNode,"Img_Logo")
--    logoNode:setVisible(true)
--    logoNode:setTouchEnabled(true)
--    logoNode:addTouchEventListener(function (target, event)
--        self.num = self.num == nil and 0 or self.num + 5
--        self.updateSlider:setPercent(self.num)
--    end)
end

function UpdateScene:startUpdate()
    -- 逻辑更新定时器
	if not self.scheduleHandler then
		self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.updateFunc), 0, false)
	end

    -- 临时存储project.manifest的文件名字
    self.projectManifestFileUPD  = writePath .. project_manifest_prefix..projectmanifest_filename .. "upd"
    -- 请求版本号
    self:requestVer()

    gt.log("---self.projectManifestFileUPD--:"..self.projectManifestFileUPD)
end

function UpdateScene:onNodeEvent(eventName)
    if "enter" == eventName then
        self:startUpdate()
    end
end

function UpdateScene:initProjectManifest()
    self.fileList = nil
    -- 从初始目录读文件列表
    local cpath = cc.FileUtils:getInstance():isFileExist(project_manifest_prefix..projectmanifest_filename)
    if cpath then
        -- print("本地目录找到了project.manifest文件了")
        if self.fileList == nil then -- 如果没有读取到目录文件的内容
            local fileData = cc.FileUtils:getInstance():getStringFromFile(project_manifest_prefix..projectmanifest_filename)
            require("json")
            self.fileList = json.decode(fileData)
        end
    end

    -- 未找到project.manifest文件,则重新下载一遍所有的资源
    if not self.fileList then
		self.fileList = {}
        self.fileList.version               = gt.version
        self.fileList.remoteVersionUrl      = gt.defaultVersionUrl
        self.fileList.remoteManifestUrl     = gt.defaultManifestUrl
		self.fileList.appVerAnd				= gt.defaultAppVerAnd
		self.fileList.appVerIos				= gt.defaultAppVerIos
		self.fileList.appUrlAnd				= gt.defaultAppUrlAnd
		self.fileList.appUrlIos				= gt.defaultAppUrlIos
        self.fileList.assets                = {}
    end

    -- 记录一下版本号
    gt.resVersion = self.fileList.version
end



function UpdateScene:updateFunc(delta)
    if self.dataRecv then -- 如果已经收到了数据
        if self.requesting == ver_filename then -- 如果是请求版本号的服务器返回消息
            -- 存储version.manifest文件
            io.writefile( writePath..ver_filename..".upd", self.dataRecv ) 
            require("json")
            self.dataRecv = json.decode(self.dataRecv)
			-- 先判断是否需要强更
			local appVersion = extension.getAppVersion()
			local newVersion = ""
			local appUrl = ""
			gt.isInReview = false
			if gt.isIOSPlatform() then
				newVersion = self.dataRecv.appVerIos
				appUrl = self.dataRecv.appUrlIos

				if appVersion == self.dataRecv.reviewVer then
					gt.isInReview = true
				end
			elseif gt.isAndroidPlatform() then
				newVersion = self.dataRecv.appVerAnd
				appUrl = self.dataRecv.appUrlAnd
			end

            gt.log("-----self.dataRecv---")
            dump(self.dataRecv)
            gt.log("-----appVersion---:"..appVersion)
            gt.log("-----newVersion---:"..newVersion)

			local nAppVersion = string.gsub(tostring(appVersion),"%.","0")
			nAppVersion = tonumber(nAppVersion) or 0
			local nNewVersion = string.gsub(tostring(newVersion),"%.","0")
			nNewVersion = tonumber(nNewVersion) or 0

            gt.log("-----nAppVersion---:"..nAppVersion)
            gt.log("-----nNewVersion---:"..nNewVersion)

			if nAppVersion < nNewVersion then
				local appUpdateLayer = require("app/views/UpdateVersion"):create(appUrl)
  	 			self:addChild(appUpdateLayer, 100)
				
				if self.scheduleHandler then
					gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
					self.scheduleHandler = nil
				end
				self.dataRecv = nil
				return
			end

            if self.dataRecv.version ~= self.fileList.version then -- 如果服务器 客户端 版本不同, 那么请求project.manifest
                gt.log("需要请求版本")
                self.fileList.remoteManifestUrl = self.dataRecv.remoteManifestUrl
                self.dataRecv = nil
                self:requestProjectManifest()
            else
                gt.log("==无需更新版本")
                self.dataRecv = nil
                self.updateSuccess = true
                self:endProcess( InitText[6] ) -- 如果版本相同 InitText[6] = "已是最新版无需更新"
            end
            self.dataRecv = nil
            return
        end
        if self.requesting == projectmanifest_filename then
            local ret = io.writefile( writePath..self.newListFile, self.dataRecv ) -- 将收到的需要更新的文件存放到self.newListFile文件中
            self.dataRecv = nil

            local newList = cc.FileUtils:getInstance():getStringFromFile(writePath..self.newListFile)
            if newList == nil then
                self:endProcess( string.format(InitText[5], writePath..self.newListFile))
                return
            end

            require("json")
            newList = json.decode(newList)
            self.lastProMani = newList -- 记录一下从服务器下载的project.manifest内容
            -- 记录从服务器下载的url地址(更新地址)
            self.updateURL = newList.packageUrl
            if newList.version == self.fileList.version then
                self.dataRecv = nil
                self.updateSuccess = true
                self:endProcess( InitText[6] ) -- 如果版本相同 InitText[6] = "已是最新版无需更新"
                return
            end
            -- 通过比较获得需要更新的文件
            self.needUpdateList = compManifest( self.fileList.assets, newList.assets )
            -- -- 打印一下需要更新的文件的名字
            -- for i,v in ipairs(self.needUpdateList) do
            --     gt.log( v.name, v.md5code )
            -- end

            -- 向服务器请求文件了,消息类型变成了"files"
            self.numFileCheck   = 0
            self.requesting     = "files"
            self:reqNextFile()
            return
        end

        if self.requesting == "files" then
            local fn = writePath..self.curStageFile.name..".upd"
            --检查并创建多级目录(存储下载文件的目录)
            if not checkCacheDirOK( writePath, self.curStageFile.name ) then
                self:endProcess( InitText[7] ) -- InitText[7] = "创建目录失败"
                return
            end
            local ret = io.writefile(fn, self.dataRecv) -- 保存文件
            self.dataRecv = nil
            if checkFile( fn, self.curStageFile.md5code ) then -- 下载正确,那么继续下载下一个文件
                table.insert(downList, fn) -- 下载正确的话,就存到downList表中.
                self:reqNextFile()
            else
                --错误
                removeFile(fn)
                self:endProcess( InitText[14]..self.curStageFile.name ) -- InitText[11] = "校验文件失败"
            end
            return
        end
    end
end

-- 请求版本号
function UpdateScene:requestVer()
    local remoteVersionUrl = nil
    local cpath = cc.FileUtils:getInstance():isFileExist(ver_filename)

    gt.log("-----requestVer-----:"..tostring(cpath))

    if cpath then
        local fileData = cc.FileUtils:getInstance():getStringFromFile(ver_filename)
        require("json")
        local filelist = json.decode(fileData)
        if filelist then
            remoteVersionUrl = filelist.remoteVersionUrl
        end
    end

    if remoteVersionUrl == nil then
        remoteVersionUrl = gt.defaultVersionUrl
    end

   
    self.requesting     = ver_filename
    self.dataRecv       = nil
    self:getFileFromServerByFirst(remoteVersionUrl)
end

-- 如果请求的版本和本地的版本不同的话,需要请求目录
function UpdateScene:requestProjectManifest()
    self.requesting     = projectmanifest_filename
    self.newListFile    = projectmanifest_filename..".upd"
    self.dataRecv       = nil
    self:requestFromServer( self.fileList.remoteManifestUrl )
end

function UpdateScene:getFileFromServer( needurl, cbFunc )
    if self.xhr == nil then
        self.xhr = cc.XMLHttpRequest:new()
        self.xhr:retain()
        self.xhr.timeout = 30 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local refreshTokenURL = needurl
    self.xhr:open("GET", refreshTokenURL)
    self.xhr:registerScriptHandler( handler(self,self.onResp) )
    self.xhr:send()
end

function UpdateScene:getFileFromServerByFirst( needurl, cbFunc )
    if self.xhr == nil then
        self.xhr = cc.XMLHttpRequest:new()
        self.xhr:retain()
        self.xhr.timeout = 30 -- 设置超时时间
    end
    self.xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    local refreshTokenURL = needurl
    self.xhr:open("GET", refreshTokenURL)
    self.xhr:registerScriptHandler( handler(self,self.onRespFirst) )
    self.xhr:send()
end

function UpdateScene:onRespFirst()
    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
        self:initProjectManifest()
		self.dataRecv = self.xhr.response -- 获取到数据
    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
        -- 网络问题,异常断开
        self:endProcess( InitText[8] )
    end
    self.xhr:unregisterScriptHandler()
end

function UpdateScene:onResp()
    if self.xhr.readyState == 4 and (self.xhr.status >= 200 and self.xhr.status < 207) then
        self.dataRecv = self.xhr.response -- 获取到数据
    elseif self.xhr.readyState == 1 and self.xhr.status == 0 then
        -- 网络问题,异常断开
        self:endProcess( InitText[8]..self.curStageFile.path )--name path
    end
    self.xhr:unregisterScriptHandler()
end

-- 向服务器发送请求消息
function UpdateScene:requestFromServer( needurl, waittime )
    self:getFileFromServer( needurl )
end

function UpdateScene:reqNextFile()
    self.numFileCheck = self.numFileCheck + 1
    self.curStageFile = self.needUpdateList[self.numFileCheck]

    if self.curStageFile then
        local filename = io.pathinfo(self.curStageFile.name).filename
        local fn = writePath..self.curStageFile.name

        -- 进度条
        if self.updateSlider then
            local percent = (self.numFileCheck-1)/(#self.needUpdateList) * 100
            self.progressLabel:setString( "正在更新游戏资源".." "..math.floor(percent).."%")
            self.updateSlider:setPercent( percent )
        end

        -- 向服务器发送消息请求self.curStageFile.name文件
        self:requestFromServer( self.updateURL .. "/" .. self.curStageFile.path )--name path
        return
    end

    --下载完成
    self:updateFiles()
end

-- 下载完毕之后,需要修改后缀名等操作
function UpdateScene:updateFiles()
    -- 修改资源中.upd名字
    for i,v in ipairs(downList) do
        --去掉.upd
        local fn = string.sub(v, 1, -5)
        -- 重新命名
        renameFile(v, fn)
    end

    local data = readFile( writePath..ver_filename..".upd" ) -- 从服务器得到的更新目录文件version.manifest.upd
    local ret  = io.writefile( writePath..ver_filename, data )

    local data = readFile( writePath..project_manifest_prefix..projectmanifest_filename..".upd" ) -- 从服务器得到的更新目录文件project.manifest.upd
    local ret  = io.writefile( writePath..project_manifest_prefix..projectmanifest_filename, data ) -- project.manifest文件中去

    -- 删除version.manifest.upd文件
    removeFile( writePath..ver_filename..".upd" )
    -- 删除project.manifest.upd文件
    removeFile( writePath..project_manifest_prefix..projectmanifest_filename..".upd" )

    -- 更新成功
    self.updateSuccess = true
    gt.resVersion = self.lastProMani.version
    self:endProcess( InitText[11] )
end

function UpdateScene:endProcess( endInfo )
    if endInfo then
        gt.log("更新结束,原因: "..endInfo)
    end

    if self.updateSuccess == false then
        require("app/views/NoticeTipsForUpdate"):create("",
            "更新失败,请检查您的网络连接\n"..endInfo,
            handler(self, self.startUpdate), nil, true)
        return
    end

   self:endCB()
end

function UpdateScene:endCB()
    if self.scheduleHandler then
        gt.scheduler:unscheduleScriptEntry(self.scheduleHandler)
		self.scheduleHandler = nil
    end

    gt.log("resVersion:" .. gt.resVersion)
	if gt.isIOSReview() then
		local resSearchPaths = {"src/", "res/"}
		cc.FileUtils:getInstance():setSearchPaths(resSearchPaths)
	end

    local loginScene = require("app/views/LoginScene"):create()
    cc.Director:getInstance():replaceScene(loginScene)
end

return UpdateScene