
local gt = cc.exports.gt

local bit = require("app/libs/bit")

require("app/protocols/MessageInit")
require("socket")

local function CRC(data, length)
    local sum = 65535
    for i = 1, length do
        local d = string.byte(data, i)    -- get i-th element, like data[i] in C
		sum = bit:_xor(sum, d)
		if (bit:_and(sum, 1) == 0) then
			sum = sum / 2
		else
			sum = bit:_xor((sum / 2), 0x70B1)
		end
    end
    return sum
end

gt.CRC = CRC


local SocketClient = class("SocketClient")

function SocketClient:ctor()
	-- 加载消息打包库
	local msgPackLib = require("app/libs/MessagePack")
	msgPackLib.set_number("integer")
	msgPackLib.set_string("string")
	msgPackLib.set_array("without_hole")
	self.msgPackLib = msgPackLib

	self:initSocketBuffer()

	-- 注册消息逻辑处理函数回调
	self.rcvMsgListeners = {}

	-- 是否已经弹出网络错误提示
	self.isPopupNetErrorTips = false

	-- 登录到服务器标识
	self.isLogined = false

	-- 发送心跳时间
	self.heartbeatCD = gt.heartTime
	-- 心跳回复时间间隔
	-- 上一次时间间隔
	self.lastReplayInterval = 0.05
	-- 当前时间间隔
	self.curReplayInterval = 0

	-- 登录状态,有三次自动重连的机会
	self.loginReconnectNum = 0
	self.scheduleHandler = gt.scheduler:scheduleScriptFunc(handler(self, self.update), 0, false)
	gt.registerEventListener(gt.EventType.NETWORK_ERROR, self, self.networkErrorEvt)

end

function SocketClient:initSocketBuffer()
	-- 发送消息缓冲
	self.sendMsgCache = {}
	self.sendingBuffer = ""
	self.remainSendSize = 0
	
	-- 接收消息
	self.recvingBuffer = ""
	self.remainRecvSize = 8 --剩余多少数据没有接受完毕,8:头部字节数
	self.recvState = "Head"
end


-- start --
--------------------------------
-- @class function
-- @description 和指定的ip/port服务器建立socket链接
-- @param serverIp 服务器ip地址
-- @param serverPort 服务器端口号
-- @param isBlock 是否阻塞
-- @return socket链接创建是否成功
-- end --
function SocketClient:connect(serverIp, serverPort, isBlock)
	if not serverIp or not serverPort then
		return false
	end
	self.serverIp = serverIp
	self.serverPort = serverPort
	self.isBlock = isBlock

	-- tcp 协议 socket
	local tcpConnection, errorInfo = self:getTcp(serverIp)
 	if not tcpConnection then
		gt.log(string.format("Connect failed when creating socket | %s", errorInfo))
		gt.dispatchEvent(gt.EventType.NETWORK_ERROR, errorInfo)
		return false
	end
	self.tcpConnection = tcpConnection
	tcpConnection:setoption("tcp-nodelay", true)
	-- 和服务器建立tcp链接
	tcpConnection:settimeout(isBlock and 5 or 0)
	print("=======ip，port",self.serverIp, self.serverPort)
	local connectCode, errorInfo = tcpConnection:connect(serverIp, serverPort)
	if connectCode == 1 then
		self.isConnectSucc = true
		gt.log("Socket connect success!")
	else
		gt.log(string.format("Socket %s Connect failed | %s", (isBlock and "Blocked" or ""), errorInfo))
		gt.dispatchEvent(gt.EventType.NETWORK_ERROR, errorInfo)
		return false
	end

	return true
end

function SocketClient:getTcp(host)
	local isipv6_only = false
	local addrinfo, err = socket.dns.getaddrinfo(host);
	if addrinfo then
		for i,v in ipairs(addrinfo) do
			if v.family == "inet6" then
				isipv6_only = true;
				break
			end
		end
	end
	print("isipv6_only", isipv6_only)
	if isipv6_only then
		return socket.tcp6()
	else
		return socket.tcp()
	end
end


function SocketClient:connectResume()
	local ret = self:connect(self.serverIp, self.serverPort, self.isBlock)
	if not ret then
		self:onSocketError("Connect failed", 2)
	end
	return ret
end


-- start --
--------------------------------
-- @class function
-- @description 关闭socket链接
-- end --
function SocketClient:close()
	if self.tcpConnection then
		self.tcpConnection:close()
	end
	self.tcpConnection = nil
	self.isConnectSucc = false
	self.sendMsgCache = {}

	self.isPopupNetErrorTips = false
	self.curReplayInterval = 0
	self.heartbeatCD = gt.heartTime
	self.lastReplayInterval = 0.1
end

-- start --
--------------------------------
-- @class function
-- @description 发送消息放入到缓冲,非真正的发送
-- @param msgTbl 消息体
-- end --
function SocketClient:sendMessage(msgTbl)
	gt.dump(msgTbl)

	-- 打包成messagepack格式
	local msgPackData = self.msgPackLib.pack(msgTbl)
	local msgLength = string.len(msgPackData)
	local len = self:luaToCByShort(msgLength)

	local curTime = os.time()
	local time = self:luaToCByInt(curTime)
	local cmd = self:luaToCByShort(msgTbl.cmd)
	local checksum = self:getCheckSum(time .. cmd, msgLength, msgPackData)
	local msgToSend = len .. checksum .. time .. msgPackData

	-- 放入到消息缓冲
	table.insert(self.sendMsgCache, msgToSend)
end

--  适配新新服务器协议
function SocketClient:receiveMsgPack()
    if nil ~= self.tcpConnection then
        local recvContent, errorInfo = self.tcpConnection:receive()
        print('conn receive:', recvContent or "nil", errorInfo or "nil")
        if errorInfo ~= "closed" then
            if recvContent then
                print('recv:'..recvContent)
            end
        end
    end
end

--  @msgTable   消息结构
function SocketClient:sendMsgPack(msgTable)
   gt.dump(msgTable)

   local msgPackData = self.msgPackLib.pack(msgTable)
   local msgLength = string.len(msgPackData)
   local len = self:luaToCByShortEx(msgLength)
   local cmd = self:luaToCByShortEx(msgTable[1])
   local accountLen = self:luaToCByShortEx(msgTable[2])
   local account = msgTable[3]
   local sessionLen = self:luaToCByShortEx(msgTable[4])
   local session = msgTable[5]
   local msgToSend = len .. cmd .. accountLen .. account .. sessionLen .. session
   table.insert(self.sendMsgCache, msgToSend)
end

function SocketClient:sendMsgPackEx(msgTable)
   local msgPackData = self.msgPackLib.pack(msgTable)
   local msgLength = string.len(msgPackData)
   local len = self:luaToCByShortEx(msgLength)
   local cmd = self:luaToCByShortEx(msgTable[1])
   local accountLen = self:luaToCByShortEx(msgTable[2])
   local account = msgTable[3]
   local sessionLen = self:luaToCByShortEx(msgTable[4])
   local session = msgTable[5]
   local msgToSend = len .. cmd .. accountLen .. account .. sessionLen .. session
   self.tcpConnection:send(msgToSend)
end

function SocketClient:getCheckSum(time, msgLength, msgPackData)
	local crc = ""
	local len = string.len(time) + msgLength
	if len < 128 then
		crc = CRC(time .. msgPackData, len)
	else
		crc = CRC(time .. msgPackData, 128)
	end
	return self:luaToCByShort(crc)
end

function SocketClient:luaToCByShort(value)
	return string.char(math.floor(value / 256)) .. string.char(value % 256) 
end

function SocketClient:luaToCByInt(value)
	local lowByte1 = string.char(math.floor(value / (256 * 256 * 256)))
	local lowByte2 = string.char(math.floor(value / (256 * 256)) % 256)
	local lowByte3 = string.char(math.floor(value / 256) % 256)
	local lowByte4 = string.char(value % 256)
	return lowByte4 .. lowByte3 .. lowByte2 .. lowByte1
end

-- start --
--------------------------------
-- @class function
-- @description 发送消息
-- @param msgTbl 消息表结构体
-- end --
function SocketClient:send()
	if not self.isConnectSucc or not self.tcpConnection then
		-- 链接未建立
		return false
	end

	if #self.sendMsgCache <= 0 then
		return true
	end

	-- 先发送队列头消息
	local msgToSend = self.sendMsgCache[1]
	self.tcpConnection:settimeout(0)
	local sendLength, errorInfo = self.tcpConnection:send(msgToSend)
	if sendLength then
		table.remove(self.sendMsgCache, 1)
		gt.log("Send success sendLength: " .. sendLength)
	else
		self:onSocketError("Send failed errorInfo:" .. errorInfo)
		return false
	end

	return true
end

-- start --
--------------------------------
-- @class function
-- @description 接收消息并且分发到注册的消息回调
-- end --
function SocketClient:receive()
	if not self.isConnectSucc or not self.tcpConnection then
		-- 链接未建立
		return false
	end
	
	local messageQueue = {}
	self:receiveMessage(messageQueue)
	
	if #messageQueue <= 0 then
		return
	end

	gt.log("Recv meesage package:" .. #messageQueue)
	
	for i,v in ipairs(messageQueue) do
		self:dispatchMessage(v)
	end
end

function SocketClient:receiveMessage(messageQueue)
	if self.remainRecvSize <= 0 then
		return true
	end

	local recvContent,errorInfo,otherContent = self.tcpConnection:receive(self.remainRecvSize)
	if errorInfo ~= nil then
		if errorInfo == "timeout" then --由于timeout为0并且为异步socket，不能认为socket出错
			if otherContent ~= nil and #otherContent > 0 then
				self.recvingBuffer = self.recvingBuffer .. otherContent
				self.remainRecvSize = self.remainRecvSize - #otherContent

				gt.log("recv timeout, but had other content. size:" .. #otherContent)
			end
			
			return true
		else
			if errorInfo ~= "closed" then
				self:onSocketError("Recv failed errorInfo:" .. errorInfo)
			end
			return false
		end
	end
	
	local contentSize = #recvContent
	self.recvingBuffer = self.recvingBuffer .. recvContent
	self.remainRecvSize = self.remainRecvSize - contentSize

	gt.log("success recv size:" .. contentSize ..  "   remainRecvSize is:" .. self.remainRecvSize)
	
	if self.remainRecvSize > 0 then	--等待下次接收
		return true
	end
	
	if self.recvState == "Head" then
		self.remainRecvSize = string.byte(self.recvingBuffer, 1) * 256 + string.byte(self.recvingBuffer, 2)
		self.recvingBuffer = ""
		self.recvState = "Body"
		gt.log("Need recv body size:" .. self.remainRecvSize)
	elseif self.recvState == "Body" then
		local messageData = self.msgPackLib.unpack(self.recvingBuffer)	
		table.insert(messageQueue, messageData)

		self.remainRecvSize = 8  --下个包头
		self.recvingBuffer = ""
		self.recvState = "Head"
	end

	--继续接数据包
	--如果有大量网络包发送给客户端可能会有掉帧现象，但目前不需要考虑，解决方案可以1.设定总接收时间2.收完body包就不在继续接收了
	return self:receiveMessage(messageQueue)
end

-- start --
--------------------------------
-- @class function
-- @description 注册msgId消息回调
-- @param msgId 消息号
-- @param msgTarget
-- @param msgFunc 回调函数
-- end --
function SocketClient:registerMsgListener(msgId, msgTarget, msgFunc)
	self.rcvMsgListeners[msgId] = {msgTarget, msgFunc}
end

-- start --
--------------------------------
-- @class function
-- @description 注销msgId消息回调
-- @param msgId 消息号
-- end --
function SocketClient:unregisterMsgListener(msgId)
	self.rcvMsgListeners[msgId] = nil
end

-- start --
--------------------------------
-- @class function
-- @description 分发消息
-- @param msgTbl 消息表结构
-- end --
function SocketClient:dispatchMessage(msgTbl)
	local rcvMsgListener = self.rcvMsgListeners[msgTbl.cmd]
	if msgTbl.cmd ~= gt.HEARTBEAT then
		gt.dump(msgTbl)
	end
	if rcvMsgListener then
		rcvMsgListener[2](rcvMsgListener[1], msgTbl)
	else
		gt.log("Could not handle Message " .. tostring(msgTbl.cmd))
		return false
	end

	return true
end

function SocketClient:setIsLogined(isLogined)
	self.isLogined = isLogined

	self.loginReconnectNum = 10

	-- 心跳消息回复
	self:registerMsgListener(gt.HEARTBEAT, self, self.onRcvHeartbeat)
end

-- start --
--------------------------------
-- @class function
-- @description 网络连接错误
-- end --
function SocketClient:onSocketError(errorInfo, waitTime)
	gt.log(errorInfo)
	self.isConnectSucc = false

	--发生错误，这个点可以考虑重连了，不用等待heartbeat
	waitTime = waitTime or 1
	self.curReplayInterval = gt.heartReplayTimeout - waitTime  -- 1秒后重连
	self.isCheckNet = true
	self.heartbeatCD = -1 --直接进入等待回复状态
end

-- start --
--------------------------------
-- @class function
-- @description 向服务器发送心跳
-- @param isCheckNet 检测和服务器的网络连接
-- end --
function SocketClient:sendHeartbeat(isCheckNet)
	local msgTbl = {}
	msgTbl.cmd = gt.HEARTBEAT
	self:sendMessage(msgTbl)

	self.curReplayInterval = 0

	self.isCheckNet = isCheckNet
	if isCheckNet then
		-- 防止重复发送心跳,直接进入等待回复状态
		self.heartbeatCD = -1
	end
end

-- start --
--------------------------------
-- @class function
-- @description 服务器回复心跳
-- @param msgTbl
-- end --
function SocketClient:onRcvHeartbeat(msgTbl)
	local filter = 0.2
	self.heartbeatCD = gt.heartTime
	self.lastReplayInterval = self.lastReplayInterval * filter + self.curReplayInterval * (1 - filter)
end

-- start --
--------------------------------
-- @class function
-- @description 获取上一次心跳回复时间间隔用来判断网络信号强弱
-- @return 上一次心跳回复时间间隔
-- end --
function SocketClient:getLastReplayInterval()
	return self.lastReplayInterval
end

function SocketClient:update(delta)
	self:send()
	self:receive()

	if self.isLogined and self.tcpConnection then
		if self.heartbeatCD >= 0 then
			self.heartbeatCD = self.heartbeatCD - delta
			if self.heartbeatCD < 0 then
				-- 发送心跳
				self:sendHeartbeat(true)
			end
		else
			-- 心跳回复时间间隔
			self.curReplayInterval = self.curReplayInterval + delta

			if self.isCheckNet and self.curReplayInterval >= gt.heartReplayTimeout then	-- 心跳超时
				gt.log("Heartbeat timeout")
				self.isCheckNet = false
				-- 心跳时间稍微长一些,等待重新登录消息返回
				self.heartbeatCD = gt.heartTime
				-- 监测网络状况下,心跳回复超时发送重新登录消息
				self:reloginServer()
			end
		end
	end
end


function SocketClient:reloginServer()
	gt.showLoadingTips(gt.getLocationString("LTKey_0001"))

	-- 链接关闭重连
	self:close()
	local ret = self:connectResume()

	if ret then
		local runningScene = display.getRunningScene()
		if runningScene and runningScene.reLogin then
			runningScene:reLogin()
		else
			gt.removeLoadingTips()
		end
	end
end

function SocketClient:networkErrorEvt(eventType, errorInfo)
	gt.log("networkErrorEvt errorInfo:" .. errorInfo)

	if self.isPopupNetErrorTips then
		return
	end

	if self.isLogined then
		return
	end

	if self.loginReconnectNum < 3 then
		self.loginReconnectNum = self.loginReconnectNum + 1
		self:connectResume()
		return
	end

	local tipInfoKey = "LTKey_0047"
	if errorInfo == "connection refused" then
		-- 连接被拒提示服务器维护中
		tipInfoKey = "LTKey_0002"
	end

	self.isPopupNetErrorTips = true

	require("app/views/NoticeTips"):create(gt.getLocationString("LTKey_0007"), gt.getLocationString(tipInfoKey),
		function()
			self.isPopupNetErrorTips = false
			gt.removeLoadingTips()

			if errorInfo == "timeout" then
				-- 检测网络连接
				self:sendHeartbeat(true)
			end
		end, nil, true)
end

function SocketClient:clearMessage()
	if not self.isConnectSucc or not self.tcpConnection then
		-- 链接未建立
		return false
	end
	
	local messageQueue = {}
	self:receiveMessage(messageQueue)
end

return SocketClient


