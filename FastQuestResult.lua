local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUIPartsReward_type_def = sdk.find_type_definition("app.cGUIPartsReward");
local get__Mode_method = GUIPartsReward_type_def:get_method("get__Mode");
local GUIPartsReward_get__JudgeAnimationEnd_method = GUIPartsReward_type_def:get_method("get__JudgeAnimationEnd");
local GUIPartsReward_get__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("get__WaitAnimationTime");
local GUIPartsReward_set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local get__WaitControlTime_method = GUIPartsReward_type_def:get_method("get__WaitControlTime");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");

local ItemGridParts_type_def = ItemGridParts_field:get_type();
local get_Count_method = ItemGridParts_type_def:get_method("get_Count");
local get_Item_method = ItemGridParts_type_def:get_method("get_Item(System.Int32)");

local GUIItemGridPartsFluent_type_def = get_Item_method:get_return_type();
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem");
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_method("get__PanelNewMark");

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_method("get_ActualVisible");

local JUDGE = get__Mode_method:get_return_type():get_field("JUDGE"):get_data(nil);

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");
local NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUISystemModuleNotifyWindowApp_type_def = NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");
local isExistCurrentInfo_method = GUISystemModuleNotifyWindowApp_type_def:get_method("isExistCurrentInfo");

local GUINotifyWindowInfo_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfo_type_def:get_method("get_NotifyWindowId");
local endWindow_method = GUINotifyWindowInfo_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfo_type_def:get_method("executeWindowEndFunc");

local GUI070000_DLG02 = get_NotifyWindowId_method:get_return_type():get_field("GUI070000_DLG02"):get_data(nil);

local RESULT_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil);

sdk.hook(GUIPartsReward_type_def:get_method("setupRewardList"), Constants.getObject, function()
    local GUIPartsReward = thread.get_hook_storage()["this"];
    local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward);
    local partsCount = get_Count_method:call(ItemGridParts);
    if partsCount > 0 then
        local hasNewItem = false;
        for i = 0, partsCount - 1 do
            local GUIItemGridPartsFluent = get_Item_method:call(ItemGridParts, i);
            if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) == true and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) == true then
                hasNewItem = true;
                break;
            end
        end
        if hasNewItem == false then
            receiveAll_method:call(GUIPartsReward);
        end
    end
end);

sdk.hook(GUIPartsReward_type_def:get_method("onVisibleUpdate"), Constants.getObject, function()
    local GUIPartsReward = thread.get_hook_storage()["this"];
    if get__Mode_method:call(GUIPartsReward) == JUDGE and GUIPartsReward_get__JudgeAnimationEnd_method:call(GUIPartsReward) == false then
        if GUIPartsReward_get__WaitAnimationTime_method:call(GUIPartsReward) > 0.01 then
            GUIPartsReward_set__WaitAnimationTime_method:call(GUIPartsReward, 0.01);
        end
        if get__WaitControlTime_method:call(GUIPartsReward) > 0.01 then
            set__WaitControlTime_method:call(GUIPartsReward, 0.01);
        end
    end
end);

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), Constants.getObject, function()
    local NotifyWindowApp = NotifyWindowApp_field:get_data(thread.get_hook_storage()["this"]);
    if isExistCurrentInfo_method:call(NotifyWindowApp) == true then
        local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
        if get_NotifyWindowId_method:call(CurInfoApp) == GUI070000_DLG02 then
            endWindow_method:call(CurInfoApp, 0);
            executeWindowEndFunc_method:call(CurInfoApp);
            closeGUI_method:call(NotifyWindowApp);
        end
    end
end);

local isResultSkip = nil;
sdk.hook(Constants.GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local GUIAppOnTimerKey = sdk.to_managed_object(args[2]);
    if Constants.getOnTimerKey_Type(GUIAppOnTimerKey) == RESULT_SKIP then
        thread.get_hook_storage()["this"] = GUIAppOnTimerKey;
        isResultSkip = true;
    end
end, function()
    if isResultSkip == true then
        thread.get_hook_storage()["this"]:set_field("_Success", true);
        isResultSkip = nil;
    end
end);