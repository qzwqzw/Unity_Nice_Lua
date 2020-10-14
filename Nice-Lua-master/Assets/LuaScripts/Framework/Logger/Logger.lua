--[[
-- added by wsh @ 2017-11-30
-- Logger系统：Lua中所有错误日志输出均使用本脚本接口，以便上报服务器
--]]

local Logger = BaseClass("Logger")

local function Log(msg)
	if Config.Debug then
		print(debug.traceback(msg, 2))
	else
		CS.Logger.Log(debug.traceback(msg, 2))
	end
end

local function LogError(msg)
	if Config.Debug then
		error(msg, 2)
	else
		CS.Logger.LogError(debug.traceback(msg, 2))
	end
end

local function getIndentSpace(indent)
	local str = ""
	for i =1, indent do
		  str = str .. " "
	end
	return str
end


local function newLine(indent)
	local str = "\n"
	str = str .. getIndentSpace(indent)
	return str
end


local function createKeyVal(key, value, bline, deep, indent)
	local str = "";
	if (bline[deep]) then
	str = str .. newLine(indent)
	end
	if type(key) == "string" then
		  str = str.. key .. " = "
	end
	if type(value) == "table" then
		  str = str .. getTableStr(value, bline, deep+1, indent)
	elseif type(value) == "string" then
		  str = str .. '"' .. tostring(value) .. '"'


	else
		  str = str ..tostring(value)
	end
	str = str .. ","
	return str
end


function getTableStr(t, bline, deep, indent)


	local str
	if bline[deep] then
		  str = newLine(indent) .. "{"
		  indent = indent + 4
	else
		  str = "{"
	end


	for key, val in pairs(t) do
		  str = str .. createKeyVal(key, val, bline, deep, indent)
	end
	if bline[deep] then
		  indent = indent-4
		  str = str .. newLine(indent) .. "}"
	else
		  str = str .. "}"
	end
	return str
end


local function dump(t , ...)
	local str = getTableStr(t, {true, true, true}, 1, 0)
	print(SafeUnpack(SafePack(...)) , str)
end

-- 重定向event错误处理函数
event_err_handle = function(msg)
	LogError(msg)
end

Logger.Log = Log
Logger.LogError = LogError
Logger.dump = dump

return Logger