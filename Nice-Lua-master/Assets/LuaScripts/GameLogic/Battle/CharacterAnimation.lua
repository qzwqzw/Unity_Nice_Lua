--[[
-- added by wsh @ 2018-02-26
-- 临时Demo：战斗场景角色动画控制脚本
--]]
local CharacterAnimation = BaseClass("CharacterAnimation", Updatable)
local Config = require "Global.Config"
local Touch = require "Common.Tools.UnityEngine.Touch"
local function Start(self, chara_go)
    -- 角色gameObject
    self.chara_go = chara_go
    -- 角色控制器
    self.chara_ctrl = chara_go:GetComponentInChildren(typeof(CS.UnityEngine.CharacterController))
    -- 动画控制器
    self.anim_ctrl = chara_go:GetComponentInChildren(typeof(CS.UnityEngine.Animation))

    self.touchPad = CS.ETCInput.GetControlTouchPad("TouchPad")
    
    self.touch = Touch.New(1)

    assert(not IsNull(self.chara_ctrl), "chara_ctrl null")
    assert(not IsNull(self.anim_ctrl), "anim_ctrl null")
end

local function LateUpdate(self)
    if IsNull(self.chara_ctrl) or IsNull(self.anim_ctrl) then
        return
    end

    if self.chara_ctrl.isGrounded and CS.ETCInput.GetAxis("Vertical") ~= 0 then
        self.anim_ctrl:CrossFade("soldierRun")
    end

    if self.chara_ctrl.isGrounded and CS.ETCInput.GetAxis("Vertical") == 0 and CS.ETCInput.GetAxis("Horizontal") == 0 then
        self.anim_ctrl:CrossFade("soldierIdleRelaxed")
    end

    if not self.chara_ctrl.isGrounded then
        self.anim_ctrl:CrossFade("soldierFalling")
    end

    if self.chara_ctrl.isGrounded and CS.ETCInput.GetAxis("Vertical") == 0 and CS.ETCInput.GetAxis("Horizontal") > 0 then
        self.anim_ctrl:CrossFade("soldierSpinRight")
    end

    if self.chara_ctrl.isGrounded and CS.ETCInput.GetAxis("Vertical") == 0 and CS.ETCInput.GetAxis("Horizontal") < 0 then
        self.anim_ctrl:CrossFade("soldierSpinLeft")
    end

    Logger.dump( CS.UnityEngine.Input , "CS.UnityEngine.Touch" )

    -- if (CS.UnityEngine.Input.touchCount > 0) then
    --     print("xxxxxxxxxxxxxxxxx")
    --     local touch = CS.UnityEngine.Input.GetTouch(0)

    --     -- Move the cube if the screen has the finger moving.
    --     if (touch.phase == TouchPhase.Moved) then
    --         local pos = touch.deltaPosition

    --         --  transform.position = position;
    --         print("11111111111111111111111",touch)
    --     end

    --     if (CS.UnityEngine.Input.touchCount == 2) then
    --         local touch = CS.UnityEngine.Input.GetTouch(1)

    --         if (touch.phase == TouchPhase.Began) then
    --         end

    --         if (touch.phase == TouchPhase.Ended) then
    --         end
    --     end
    -- end
    if(CS.UnityEngine.Input.GetMouseButton(0) or (CS.UnityEngine.Input.touchCount>0 and CS.UnityEngine.Input.GetTouch(0).phase == TouchPhase.Moved) ) then
        local moveX =  CS.UnityEngine.Input.GetAxis("Mouse X")
        local moveY =  CS.UnityEngine.Input.GetAxis("Mouse Y")
        print("Mouse XXXXXXXXXXXXX", moveX, moveY)
    end

end

CharacterAnimation.Start = Start
CharacterAnimation.LateUpdate = LateUpdate

return CharacterAnimation
