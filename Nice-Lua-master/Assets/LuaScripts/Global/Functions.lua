function AddCallback(keeper, msg_name, callback)
	assert(callback ~= nil)
	keeper[msg_name] = callback
end

function GetCallback(keeper, msg_name)
	return keeper[msg_name]
end

function RemoveCallback(keeper, msg_name, callback)
	assert(callback ~= nil)
	keeper[msg_name] = nil
end