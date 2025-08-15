local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local UI070000 = sdk.find_type_definition("app.GUIID.ID"):get_field("UI070000"):get_data(nil);

local GUIPartsReward_type_def = sdk.find_type_definition("app.cGUIPartsReward");
local get__Mode_method = GUIPartsReward_type_def:get_method("get__Mode");
local get__IsViewMode_method = GUIPartsReward_type_def:get_method("get__IsViewMode");
local GUIPartsReward_get__JudgeAnimationEnd_method = GUIPartsReward_type_def:get_method("get__JudgeAnimationEnd");
local GUIPartsReward_get__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("get__WaitAnimationTime");
local GUIPartsReward_set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local get__WaitControlTime_method = GUIPartsReward_type_def:get_method("get__WaitControlTime");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local get__isRandomAmuletMode_method = GUIPartsReward_type_def:get_method("get__isRandomAmuletMode");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local get_Owner_method = GUIPartsReward_type_def:get_method("get_Owner");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");

local REWARD = get__Mode_method:get_return_type():get_field("REWARD"):get_data(nil);

local GUIBaseApp_type_def = get_Owner_method:get_return_type();
local get_IDInt_method = GUIBaseApp_type_def:get_method("get_IDInt");
local get_CurCtrlInputPriority_method = GUIBaseApp_type_def:get_method("get_CurCtrlInputPriority");

local ItemGridParts_type_def = ItemGridParts_field:get_type();
local get_Count_method = ItemGridParts_type_def:get_method("get_Count");
local get_Item_method = ItemGridParts_type_def:get_method("get_Item(System.Int32)");

local GUIItemGridPartsFluent_type_def = get_Item_method:get_return_type();
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem"); -- via.gui.SelectItem
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_method("get__PanelNewMark"); -- via.gui.Panel

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_method("get_ActualVisible");
--
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
--
local RESULT_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil);
--
local jumpFixQuestJudge_method = sdk.find_type_definition("app.GUI020100"):get_method("jumpFixQuestJudge");

local GUI020100PanelQuestRewardItem_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestRewardItem");
local Reward_endFix_method = GUI020100PanelQuestRewardItem_type_def:get_method("endFix");
local get_MyOwner_method = GUI020100PanelQuestRewardItem_type_def:get_method("get_MyOwner");
local JudgeMode_field = GUI020100PanelQuestRewardItem_type_def:get_field("JudgeMode");

local MODE02 = JudgeMode_field:get_type():get_field("MODE02"):get_data(nil);

local GUI020100PanelQuestResultList_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestResultList");
local Result_endFix_method = GUI020100PanelQuestResultList_type_def:get_method("endFix");

local terminateQuestResult_method = Constants.GUIManager_type_def:get_method("terminateQuestResult");

local function skipJudgeAnimation(GUIPartsReward)
    if GUIPartsReward_get__JudgeAnimationEnd_method:call(GUIPartsReward) == false then
        if GUIPartsReward_get__WaitAnimationTime_method:call(GUIPartsReward) > 0.01 then
            GUIPartsReward_set__WaitAnimationTime_method:call(GUIPartsReward, 0.01);
        end
        if get__WaitControlTime_method:call(GUIPartsReward) > 0.01 then
            set__WaitControlTime_method:call(GUIPartsReward, 0.01);
        end
    end
end

local function hasNewItem(GUIPartsReward)
    local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward);
    local partsCount = get_Count_method:call(ItemGridParts);
    if partsCount > 0 then
        for i = 0, partsCount - 1 do
            local GUIItemGridPartsFluent = get_Item_method:call(ItemGridParts, i);
            if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) == true and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) == true then
                return true;
            end
        end
    end
    return false;
end

local function receiveAll(GUIPartsReward)
    if get_CurCtrlInputPriority_method:call(get_Owner_method:call(GUIPartsReward)) == 0 and hasNewItem(GUIPartsReward) == false then
        receiveAll_method:call(GUIPartsReward);
    end
end

local GUIPartsReward = nil;
sdk.hook(GUIPartsReward_type_def:get_method("start(app.cGUIPartsRewardInfo, app.cGUIPartsReward.MODE, System.Boolean, System.Boolean)"), function(args)
    local this = sdk.to_managed_object(args[2]);
    if get__IsViewMode_method:call(this) == false and get_IDInt_method:call(get_Owner_method:call(this)) == UI070000 then
        GUIPartsReward = this;
    end
end);

sdk.hook(GUIPartsReward_type_def:get_method("onVisibleUpdate"), nil, function()
    if GUIPartsReward ~= nil then
        if get__Mode_method:call(GUIPartsReward) == REWARD then
            receiveAll(GUIPartsReward);
        else
            if get__isRandomAmuletMode_method:call(GUIPartsReward) == false then
                receiveAll(GUIPartsReward);
            else
                skipJudgeAnimation(GUIPartsReward);
            end
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI070000"):get_method("onClose"), nil, function()
    if GUIPartsReward ~= nil then
        GUIPartsReward = nil;
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
    if Constants.getGUIAppKey_Type(GUIAppOnTimerKey) == RESULT_SKIP then
        thread.get_hook_storage()["this"] = GUIAppOnTimerKey;
        isResultSkip = true;
    end
end, function()
    if isResultSkip == true then
        isResultSkip = nil;
        thread.get_hook_storage()["this"]:set_field("_Success", true);
    end
end);

local GUI020100PanelQuestRewardItem = nil;
sdk.hook(GUI020100PanelQuestRewardItem_type_def:get_method("start"), function(args)
    GUI020100PanelQuestRewardItem = sdk.to_managed_object(args[2]);
end);

sdk.hook(GUI020100PanelQuestRewardItem_type_def:get_method("onVisibleUpdate"), nil, function()
    if GUI020100PanelQuestRewardItem ~= nil then
        if JudgeMode_field:get_data(GUI020100PanelQuestRewardItem) == MODE02 then
            jumpFixQuestJudge_method:call(get_MyOwner_method:call(GUI020100PanelQuestRewardItem));
        else
            Reward_endFix_method:call(GUI020100PanelQuestRewardItem);
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.cGUIPartsRewardItems"):get_method("end(System.Action)"), nil, function()
    if GUI020100PanelQuestRewardItem ~= nil then
        GUI020100PanelQuestRewardItem = nil;
    end
end);

sdk.hook(GUI020100PanelQuestResultList_type_def:get_method("start"), Constants.getObject, function()
    Result_endFix_method:call(thread.get_hook_storage()["this"]);
    terminateQuestResult_method:call(Constants.GUIManager);
end);