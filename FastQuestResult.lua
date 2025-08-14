local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI070000_type_def = sdk.find_type_definition("app.GUI070000");
local get_IsViewMode_method = GUI070000_type_def:get_method("get_IsViewMode");
local get__PartsRewardItems_method = GUI070000_type_def:get_method("get__PartsRewardItems");
local get_CurCtrlInputPriority_method = GUI070000_type_def:get_method("get_CurCtrlInputPriority");
local JudgeMode_field = GUI070000_type_def:get_field("JudgeMode");

local JUDGE_MODE_type_def = JudgeMode_field:get_type();
local JUDGE_MODE = {
    MODE01 = JUDGE_MODE_type_def:get_field("MODE01"):get_data(nil),
    MODE02 = JUDGE_MODE_type_def:get_field("MODE02"):get_data(nil)
};

local GUIPartsReward_type_def = get__PartsRewardItems_method:get_return_type();
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
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem"); -- via.gui-SelectItem
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_method("get__PanelNewMark"); -- via.gui.Panel

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_method("get_ActualVisible");

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

local GUI020100_type_def = sdk.find_type_definition("app.GUI020100");
local get__PartsQuestRewardItem_method = GUI020100_type_def:get_method("get__PartsQuestRewardItem");
local get__PartsQuestResultList_method = GUI020100_type_def:get_method("get__PartsQuestResultList");
local get__State_method = GUI020100_type_def:get_method("get__State");
local get_FixPanelType_method = GUI020100_type_def:get_method("get_FixPanelType");
local jumpFixQuestJudge_method = GUI020100_type_def:get_method("jumpFixQuestJudge");

local GUI020100PanelQuestRewardItem_type_def = get__PartsQuestRewardItem_method:get_return_type();
local Reward_endFix_method = GUI020100PanelQuestRewardItem_type_def:get_method("endFix");
local Reward_endFix_Post_method = GUI020100PanelQuestRewardItem_type_def:get_method("<endFix>b__21_0");
local GUI020100_JudgeMode_field = GUI020100PanelQuestRewardItem_type_def:get_field("JudgeMode");

local Result_endFix_method = get__PartsQuestResultList_method:get_return_type():get_method("endFix");

local GUI020100_State_type_def = get__State_method:get_return_type();
local GUI020100_State = {
    QuestRewardItem = GUI020100_State_type_def:get_field("QuestRewardItem"):get_data(nil),
    QuestJudgeItem = GUI020100_State_type_def:get_field("QuestJudgeItem"):get_data(nil),
    QuestResultList = GUI020100_State_type_def:get_field("QuestResultList"):get_data(nil)
};

local FIX_PANEL_TYPE_type_def = get_FixPanelType_method:get_return_type();
local FIX_PANEL_TYPE = {
    REWARD_ITEMS = FIX_PANEL_TYPE_type_def:get_field("REWARD_ITEMS"):get_data(nil),
    RESULT_LIST = FIX_PANEL_TYPE_type_def:get_field("RESULT_LIST"):get_data(nil)
};

local terminateQuestResult_method = Constants.GUIManager_type_def:get_method("terminateQuestResult");

local function receiveAll(GUI070000, GUIPartsReward)
    if get_CurCtrlInputPriority_method:call(GUI070000) == 0 then
        receiveAll_method:call(GUIPartsReward);
    end
end

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

sdk.hook(GUI070000_type_def:get_method("guiVisibleUpdate"), Constants.getObject, function()
    local GUI070000 = thread.get_hook_storage()["this"];
    if get_IsViewMode_method:call(GUI070000) == false then
        local GUIPartsReward = get__PartsRewardItems_method:call(GUI070000);
        local JudgeMode = JudgeMode_field:get_data(GUI070000);
        if JudgeMode == JUDGE_MODE.MODE01 then
            local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward);
            local partsCount = get_Count_method:call(ItemGridParts);
            if partsCount > 0 then
                for i = 0, partsCount - 1 do
                    local GUIItemGridPartsFluent = get_Item_method:call(ItemGridParts, i);
                    if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) == true and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) == true then
                        skipJudgeAnimation(GUIPartsReward);
                        return;
                    end
                end
            end
            receiveAll(GUI070000, GUIPartsReward);
        elseif JudgeMode == JUDGE_MODE.MODE02 then
            skipJudgeAnimation(GUIPartsReward);
        else
            local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward);
            local partsCount = get_Count_method:call(ItemGridParts);
            if partsCount > 0 then
                for i = 0, partsCount - 1 do
                    local GUIItemGridPartsFluent = get_Item_method:call(ItemGridParts, i);
                    if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) == true and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) == true then
                        return;
                    end
                end
            end
            receiveAll(GUI070000, GUIPartsReward);
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

local function Reward_endFix(PartsQuestRewardItem)
    Reward_endFix_method:call(PartsQuestRewardItem);
    Reward_endFix_Post_method:call(PartsQuestRewardItem);
end

local GUI020100 = nil;
sdk.hook(GUI020100_type_def:get_method("guiHudUpdate"), function(args)
    if GUI020100 == nil then
        GUI020100 = sdk.to_managed_object(args[2]);
    end
end, function()
    local State = get__State_method:call(GUI020100);
    local FixPanelType = get_FixPanelType_method:call(GUI020100);
    if FixPanelType == FIX_PANEL_TYPE.REWARD_ITEMS then
        local PartsQuestRewardItem = get__PartsQuestRewardItem_method:call(GUI020100);
        if State == GUI020100_State.QuestRewardItem then
            Reward_endFix(PartsQuestRewardItem);
        elseif State == GUI020100_State.QuestJudgeItem then
            if GUI020100_JudgeMode_field:get_data(PartsQuestRewardItem) == JUDGE_MODE.MODE02 then
                jumpFixQuestJudge_method:call(GUI020100);
            else
                Reward_endFix(PartsQuestRewardItem);
            end
        end
    elseif FixPanelType == FIX_PANEL_TYPE.RESULT_LIST and State == GUI020100_State.QuestResultList then
        Result_endFix_method:call(get__PartsQuestResultList_method:call(GUI020100));
        terminateQuestResult_method:call(Constants.GUIManager);
    end
end);