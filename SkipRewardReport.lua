local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local get_Component_method = sdk.find_type_definition("via.gui.PlayObject"):get_method("get_Component");

local GUIPartsReward_type_def = sdk.find_type_definition("app.cGUIPartsReward");
local GUIPartsReward_get__JudgeAnimationEnd_method = GUIPartsReward_type_def:get_method("get__JudgeAnimationEnd");
local GUIPartsReward_get__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("get__WaitAnimationTime");
local GUIPartsReward_set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local get__WaitControlTime_method = GUIPartsReward_type_def:get_method("get__WaitControlTime");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");

local GUIPartsRewardItems_type_def = sdk.find_type_definition("app.cGUIPartsRewardItems");
local GUIPartsRewardItems_get__JudgeAnimationEnd_method = GUIPartsRewardItems_type_def:get_method("get__JudgeAnimationEnd");
local GUIPartsRewardItems_get__WaitAnimationTime_method = GUIPartsRewardItems_type_def:get_method("get__WaitAnimationTime");
local GUIPartsRewardItems_set__WaitAnimationTime_method = GUIPartsRewardItems_type_def:get_method("set__WaitAnimationTime(System.Single)");
local set__ControlEnable_method = GUIPartsRewardItems_type_def:get_method("set__ControlEnable(System.Boolean)");

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");
local NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUISystemModuleNotifyWindowApp_type_def = NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");

local GUINotifyWindowInfo_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfo_type_def:get_method("get_NotifyWindowId");
local endWindow_method = GUINotifyWindowInfo_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfo_type_def:get_method("executeWindowEndFunc");

local GUI070000_DLG02 = get_NotifyWindowId_method:get_return_type():get_field("GUI070000_DLG02"):get_data(nil);

local function applyPlaySpeed(GUI, speed)
    if Constants.get_PlaySpeed_method:call(GUI) ~= speed then
        Constants.set_PlaySpeed_method:call(GUI, speed);
    end
end

local function Pre_updateItem(args)
    local storage = thread.get_hook_storage();
    storage.this = sdk.to_managed_object(args[2]);
    storage.gui = sdk.to_managed_object(args[3]);
end

sdk.hook(GUIPartsReward_type_def:get_method("updateItem(via.gui.SelectItem, System.Boolean)"), Pre_updateItem, function()
    local storage = thread.get_hook_storage();
    if GUIPartsReward_get__JudgeAnimationEnd_method:call(storage.this) == false then
        if GUIPartsReward_get__WaitAnimationTime_method:call(storage.this) > 0.05 then
            GUIPartsReward_set__WaitAnimationTime_method:call(storage.this, 0.05);
        end
        if get__WaitControlTime_method:call(storage.this) > 0.05 then
            set__WaitControlTime_method:call(storage.this, 0.05);
        end
        applyPlaySpeed(get_Component_method:call(storage.gui), 10.0);
    else
        applyPlaySpeed(get_Component_method:call(storage.gui), 1.0);
    end
end);

sdk.hook(GUIPartsRewardItems_type_def:get_method("updateItem(via.gui.SelectItem)"), Pre_updateItem, function()
    local storage = thread.get_hook_storage();
    if GUIPartsRewardItems_get__JudgeAnimationEnd_method:call(storage.this) == false then
        if GUIPartsRewardItems_get__WaitAnimationTime_method:call(storage.this) > 0.05 then
            GUIPartsRewardItems_set__WaitAnimationTime_method:call(storage.this, 0.05);
        end
        set__ControlEnable_method:call(storage.this, true);
        applyPlaySpeed(get_Component_method:call(storage.gui), 10.0);
    else
        applyPlaySpeed(get_Component_method:call(storage.gui), 1.0);
    end
end);

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), Constants.getObject, function()
    local NotifyWindowApp = NotifyWindowApp_field:get_data(thread.get_hook_storage()["this"]);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil and get_NotifyWindowId_method:call(CurInfoApp) == GUI070000_DLG02 then
        endWindow_method:call(CurInfoApp, 0);
        executeWindowEndFunc_method:call(CurInfoApp);
        closeGUI_method:call(NotifyWindowApp);
    end
end);