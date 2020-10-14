--[[
-- added by wsh @ 2017-01-09
-- 大厅网络连接器
--]]

local HallConnector = BaseClass("HallConnector")
local SendMsgDefine = require "Net.Config.SendMsgDefine"
local NetUtil = require "Net.Util.NetUtil"

local ConnStatus = {
	Init = 0,          --初始化
	Connecting = 1,    --连接中
	Closed = 2,        --连接关闭
	Done = 3,          --连接成功
	Disconnected = 4   --客户端断开连接，跳到登录页面时
}

local ESocketErr = {
	NORMAL = 0, 	 --正常关闭，在连接前也会关一下
	ERROR_1 = -1,
	ERROR_2 = -2,
	ERROR_3 = -3,	--对方已经关闭链接了
	ERROR_4 = -4,	--发生了未知错误
	ERROR_5 = -5	--主动断开连接
}

local function __init(self)
	self.hostIP = ""
	self.hostPort = 0
	self.hallSocket = nil
	self.globalSeq = 1
	self.connStatus = ConnStatus.Init
	self.retryTimes = 0  --重连次数
	self.heartBeatInterval = 15 --心跳间隔
	self.maxRetryTimes = 3  --最大重连次数
    self.sendMsgCache = {}  --消息发送列表
	self.sendMsgTimeout = 10 --消息超时时间

end

local function StartHeartBeat(self)
	--开启心跳包发送器
	self.timer_action = function(self)
		if self.connStatus == ConnStatus.Done then
			print("send heart beat")
			self:SendMessage(MsgIDDefine.COMMON_HEART_BEAT, {uid=1}, false)
		end
	end
	self.timer = TimerManager:GetInstance():GetTimer(self.heartBeatInterval, self.timer_action , self, false)
	-- 启动定时器
	self.timer:Start()
end

local function SendMessage(self, msg_id, msg_obj, callback, need_resend)
	--处理消息重发
	need_resend = need_resend == nil and true or need_resend

	if need_resend and self.sendMsgCache[self.globalSeq] == nil then
		local send_msg = SendMsgDefine.New(self.globalSeq, msg_id, msg_obj)
		self.sendMsgCache[self.globalSeq] = {
			request_seq =0,
			request_time = os.time(),
			send_msg = send_msg,
			callback = callback }

		local msg_bytes = NetUtil.SerializeMessage(send_msg)
		Logger.Log("SendMessage: "..tostring(send_msg))
		self.hallSocket:SendMessage(msg_bytes)
		self.globalSeq = self.globalSeq + 1
	end

end

local function OnReceivePackage(self, receive_bytes)
	local  receiveMessage = NetUtil.DeserializeMessage(receive_bytes)
	local seq = receiveMessage.Seq
	if self.sendMsgCache[seq] ~= nil then
		Logger.Log("ReveMessage: "..tostring(seq))

		local msgCache = self.sendMsgCache[seq]
		local callbackFun = msgCache.callback
		if( callbackFun ~= nil) then
			callbackFun(receiveMessage.MsgProto)
		end
		self.sendMsgCache[seq] = nil
	end
	--NetManager:GetInstance():Broadcast(tonumber(receiveMessage.MsgId), receiveMessage.MsgProto)
end

local function _on_close(self, socket, code, msg)

	--处理重连
	if code ~= ESocketErr.ERROR_5 and self.connStatus ~= ConnStatus.Disconnected then
		self.connStatus = ConnStatus.Closed
		self.retryTimes = self.retryTimes+1

		if self.retryTimes >self.maxRetryTimes then
			UIManager:GetInstance():OpenOneButtonTip("网络错误", "无法连接服务器", "确定", function ()
				SceneManager:GetInstance():SwitchScene(SceneConfig.LoginScene)
			end)
		else
			self.timer_action = function(self)
				self:ReConnect()
			end
			self.timer = TimerManager:GetInstance():GetTimer(self.retryTimes * 5, self.timer_action , self, true)
			-- 启动定时器
			self.timer:Start()

		end
	end

end

local function Connect(self, host_ip, host_port,callback)
	if not self.hallSocket then
		self.hallSocket = CS.Networks.HjTcpNetwork()
		self.hallSocket.ReceivePkgHandle = Bind(self, OnReceivePackage)
	end
	self.hostIP = host_ip
	self.hostPort = host_port

	self.hallSocket.OnConnect = function(socket, code, msg)
		self.connStatus = ConnStatus.Done
		if(callback ~= nil) then
			callback(socket, code, msg)
		end
	end
	self.hallSocket.OnClosed = Bind(self, _on_close)
	self.hallSocket:SetHostPort(host_ip, host_port)
	self.hallSocket:Connect()
	self.connStatus = ConnStatus.Connecting
	Logger.Log("Connect to "..host_ip..", port : "..host_port)
	return self.hallSocket
end

local function ReConnect(self)
	self:Connect(self.hostIP, self.hostPort, function (socket, code, msg)
		--重连成功
		Logger.Log("Reconnect success  "..self.hostIP..", port : "..self.hostPort)
		self.connStatus = ConnStatus.Done
		self.reconnTimes = 0
	end)
end



local function Update(self)
	if self.hallSocket then
		self.hallSocket:UpdateNetwork()
	end

	--消息重发
	local remove_list = {}
	for k,v in pairs(self.sendMsgCache) do

		if os.time() - v.request_time > self.sendMsgTimeout then
			--重发超过5次丢弃消息
			if(v.request_seq >5) then
				Logger.Log("resend timeout: "..k .. " , reequest_seq: "..v.request_seq)
				table.insert(remove_list, k)
			else
				Logger.Log("resend msg  seq: "..k .. " , reequest_seq: "..v.request_seq)
				v.request_time = os.time()
				v.request_seq = v.request_seq + 1

				local msg_bytes = NetUtil.SerializeMessage(v.send_msg)
				Logger.Log("resend msg: "..tostring(v.send_msg))
				self.hallSocket:SendMessage(msg_bytes)
			end
		end
	end
	if #remove_list > 0 then
		table.walk(remove_list, function (k, v)
			self.sendMsgCache[v] = nil
		end)
		remove_list = {}
	end
end

--断开网络
local function Close(self)
	self.connStatus = ConnStatus.Disconnected
	self.reconnTimes = 0

	if self.hallSocket then
		self.hallSocket:Close()
	end
end

local function Dispose(self)
	if self.hallSocket then
		self.hallSocket:Dispose()
	end
	self.hallSocket = nil
end

HallConnector.__init = __init
HallConnector.Connect = Connect
HallConnector.ReConnect = ReConnect
HallConnector.SendMessage = SendMessage
HallConnector.Update = Update
HallConnector.Close = Close
HallConnector.Dispose = Dispose

return HallConnector
