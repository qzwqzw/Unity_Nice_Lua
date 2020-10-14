-- automatically generated by the FlatBuffers compiler, do not modify

-- namespace: fb

local flatbuffers = require('flatbuffers')

local heroconfigTR = {} -- the module
local heroconfigTR_mt = {} -- the class metatable

function heroconfigTR.New()
    local o = {}
    setmetatable(o, {__index = heroconfigTR_mt})
    return o
end
function heroconfigTR.GetRootAsheroconfigTR(buf, offset)
    local n = flatbuffers.N.UOffsetT:Unpack(buf, offset)
    local o = heroconfigTR.New()
    o:Init(buf, n + offset)
    return o
end
function heroconfigTR_mt:Init(buf, pos)
    self.view = flatbuffers.view.New(buf, pos)
end
function heroconfigTR_mt:_id()
    local o = self.view:Offset(4)
    if o ~= 0 then
        return self.view:Get(flatbuffers.N.Int32, o + self.view.pos)
    end
    return 0
end
function heroconfigTR_mt:_baseatk()
    local o = self.view:Offset(6)
    if o ~= 0 then
        return self.view:Get(flatbuffers.N.Float32, o + self.view.pos)
    end
    return 0.0
end
function heroconfigTR_mt:_sp()
    local o = self.view:Offset(8)
    if o ~= 0 then
        return self.view:Get(flatbuffers.N.Float32, o + self.view.pos)
    end
    return 0.0
end
function heroconfigTR_mt:_hp()
    local o = self.view:Offset(10)
    if o ~= 0 then
        return self.view:Get(flatbuffers.N.Float32, o + self.view.pos)
    end
    return 0.0
end
function heroconfigTR_mt:_attackdistance()
    local o = self.view:Offset(12)
    if o ~= 0 then
        return self.view:Get(flatbuffers.N.Float32, o + self.view.pos)
    end
    return 0.0
end
function heroconfigTR_mt:_attackinterval()
    local o = self.view:Offset(14)
    if o ~= 0 then
        return self.view:Get(flatbuffers.N.Float32, o + self.view.pos)
    end
    return 0.0
end
function heroconfigTR.Start(builder) builder:StartObject(6) end
function heroconfigTR.Add_id(builder, Id) builder:PrependInt32Slot(0, Id, 0) end
function heroconfigTR.Add_baseatk(builder, Baseatk) builder:PrependFloat32Slot(1, Baseatk, 0.0) end
function heroconfigTR.Add_sp(builder, Sp) builder:PrependFloat32Slot(2, Sp, 0.0) end
function heroconfigTR.Add_hp(builder, Hp) builder:PrependFloat32Slot(3, Hp, 0.0) end
function heroconfigTR.Add_attackdistance(builder, Attackdistance) builder:PrependFloat32Slot(4, Attackdistance, 0.0) end
function heroconfigTR.Add_attackinterval(builder, Attackinterval) builder:PrependFloat32Slot(5, Attackinterval, 0.0) end
function heroconfigTR.End(builder) return builder:EndObject() end

return heroconfigTR -- return the module