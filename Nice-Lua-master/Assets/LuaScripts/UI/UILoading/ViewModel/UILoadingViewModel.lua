--[[
-- added by wsh @ 2017-12-01
-- UILogin��ͼ��
-- ע�⣺
-- 1����Ա�������Ԥ����__init������������ߴ���ɶ���
-- 2��OnEnable����ÿ���ڴ��ڴ�ʱ���ã�ֱ��ˢ��
-- 3����������ο�����淶
--]]


local UILoadingViewModel = BaseClass("UILoadingViewModel",UIBaseViewModel)
local base = UIBaseViewModel

local function OnCreate(self)
    self.loading_text = BindableProperty.New()
    self.loading_slider = BindableProperty.New(0)



    -- ��ʱ��
    -- ����һ��Ҫ�Իص������������ã�������ʱ���ܱ�GC������ʱ��ʧЧ
    -- ����ʹ�ó�Ա�������������������ǺͶ������һ���
    local circulator = table.circulator({"loading", "loading.", "loading..", "loading..."})
    self.timer_action = function(self)
        self.loading_text.Value = circulator()
    end
    self.timer = TimerManager:GetInstance():GetTimer(1, self.timer_action , self)
    self.timer:Start()
end

local function UpdateData(self)


end

local function OnDestroy(self)
    self.timer:Stop()
    self.loading_text = nil
    self.loading_slider = nil
    self.timer_action = nil
    self.timer = nil
    base.OnDestroy(self)
end

UILoadingViewModel.OnCreate = OnCreate
UILoadingViewModel.UpdateData = UpdateData
UILoadingViewModel.OnDestroy = OnDestroy


return UILoadingViewModel