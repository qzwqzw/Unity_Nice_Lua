--[[
-- added by wsh @ 2018-02-26
-- UIBattleMain视图层
--]]

local UIBattleMainView = BaseClass("UIBattleMainView", UIBaseView)
local base = UIBaseView
local switch_btn_path = "switch"
local CharacterAnimation = require "GameLogic.Battle.CharacterAnimation"

-- 各个组件路径
local back_btn_path = "BackBtn"

local function OnCreate(self)
	base.OnCreate(self)

	-- 启动角色控制
	self.charaAnim = CharacterAnimation.New()

	-- 控制角色
	self.chara = nil
	-- 退出按钮
	self.back_btn = self:AddComponent(UIButton, back_btn_path, self.Binder, "back_btn")

	-- local camera_go = CS.UnityEngine.Camera.main;
	-- local GestureControl = camera_go:GetComponent("GestureControl");

	-- Logger.dump( getmetatable(GestureControl), "CCCCCCCCCCCCCCCCCCCCCCCC");
	
	self.switch_btn = self:AddComponent(UIButton, switch_btn_path)
	self.switch_btn:SetOnClick(function()

		local BattleScene = App.SceneManager:GetCurrScene();
		local role = BattleScene.GetPlayer()

		CS.ETCInput.SetAxisDirecTransform("Horizontal", role.transform);
		local ETCJoystick = CS.ETCInput.GetControlJoystick("Joystick");
		local ETCButton = CS.ETCInput.GetControlButton("JumpBtn");

		print("sssssssssssssssssssss", role.transform.gameObject)

		-- GestureControl.target =  (role.transform.gameObject);
		ETCButton.axis.directTransform = role.transform;
		ETCJoystick.cameraLookAt = role.transform;
		-- ETCJoystick.cameraMode = 1;
		-- ETCJoystick.directTransform = role.transform;
		self.charaAnim:Start(role)

		Logger.dump(getmetatable(ETCButton), "11111111")
		App.UIManager:Broadcast(UIMessageNames.BATTLESCENE_ON_GET_PLAY);

	end)

	self:AddUIListener( UIMessageNames.BATTLESCENE_ON_GET_PLAY, self.CallFun)

	-- 调用父类Bind所有属性
	base.BindAll(self)

end

local function CallFun()

end

local function OnEnable(self)
	base.OnEnable(self)
end

local function LateUpdate(self)
	if IsNull(self.chara) then
		self.chara = CS.UnityEngine.GameObject.FindGameObjectWithTag("Player")
	end

	if IsNull(self.chara) then
		return
	end
	
	local axisXValue = CS.ETCInput.GetAxis("Horizontal")
	local axisYValue = CS.ETCInput.GetAxis("Vertical")
	if Time.frameCount % 30 == 0 then
		print("ETCInput : "..axisXValue..", "..axisYValue)
	end
	
	-- 说明：这里根据获取的摇杆输入向量控制角色移动
	-- 示例代码略
end

local function OnDestroy(self)
	base.OnDestroy(self)
end

UIBattleMainView.OnCreate = OnCreate
UIBattleMainView.OnEnable = OnEnable
UIBattleMainView.LateUpdate = LateUpdate
UIBattleMainView.OnDestroy = OnDestroy
UIBattleMainView.CallFun = CallFun;

return UIBattleMainView