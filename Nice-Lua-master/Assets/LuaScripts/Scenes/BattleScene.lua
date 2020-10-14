--[[
-- added by wsh @ 2017-11-19
-- 战斗场景
-- TODO：这里只是做一个战斗场景展示Demo，大部分代码以后需要挪除
--]]

local BattleScene = BaseClass("BattleScene", BaseScene)
local base = BaseScene

local CharacterAnimation = require "GameLogic.Battle.CharacterAnimation"

local Players = {};
-- 临时：角色资源路径
local chara_res_path = "Models/1001/Character.prefab"

-- 创建：准备预加载资源
local function OnCreate(self)
	base.OnCreate(self)
	-- TODO
	-- 预加载资源
	self:AddPreloadResource(chara_res_path, typeof(CS.UnityEngine.GameObject), 1)
	self:AddPreloadResource(UIConfig[UIWindowNames.UIBattleMain].PrefabPath, typeof(CS.UnityEngine.GameObject), 1)
	
	-- 临时：角色动画控制脚本
	self.charaAnim = nil

end

local function GetPlayer()
	return Players[math.random(1,#Players)];
end

-- 准备工作
local function OnComplete(self)
	base.OnComplete(self)
	
	Players = {};
	local chara_root = CS.UnityEngine.GameObject.Find("CharacterRoot")
	-- 创建角色
	local chara = GameObjectPool:GetInstance():GetGameObjectAsync(chara_res_path, function(Role)
		if IsNull(Role) then
			error("Load chara res err!")
			do return end
		end
		
		if IsNull(chara_root) then
			error("chara_root null!")
			do return end
		end
		
		table.insert(Players, Role);
		Role.transform:SetParent(chara_root.transform)
		Role.transform.localPosition = Vector3.New(-7.86, 50, 5.85)

		UIManager:GetInstance():OpenWindow(UIWindowNames.UIBattleMain)

	end)

	for i=1,10 do
		self:createRole(function (Role)
			table.insert(Players, Role);
			Role.transform:SetParent(chara_root.transform)
			Role.transform.localPosition = Vector3.New(math.random(0,15), 3, math.random(0,15))
		end)
	end

end

function BattleScene:createRole(call)
	GameObjectPool:GetInstance():GetGameObjectAsync(chara_res_path, function(Role)
		call(Role);
	end)
end

-- 离开场景
local function OnLeave(self)
	self.charaAnim = nil
	UIManager:GetInstance():CloseWindow(UIWindowNames.UIBattleMain)
	base.OnLeave(self)
end

BattleScene.OnCreate = OnCreate
BattleScene.OnComplete = OnComplete
BattleScene.OnLeave = OnLeave
BattleScene.GetPlayer = GetPlayer

return BattleScene;