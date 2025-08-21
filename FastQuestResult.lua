local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;
--<< GUI070000 Fix Quest Result >>--
local UI070000 = sdk.find_type_definition("app.GUIID.ID"):get_field("UI070000"):get_data(nil);

local GUIPartsReward_type_def = sdk.find_type_definition("app.cGUIPartsReward");
local get__Mode_method = GUIPartsReward_type_def:get_method("get__Mode");
local get__IsViewMode_method = GUIPartsReward_type_def:get_method("get__IsViewMode");
local get__JudgeAnimationEnd_method = GUIPartsReward_type_def:get_method("get__JudgeAnimationEnd");
local get__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("get__WaitAnimationTime");
local set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
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

local GUIAppKey_Type_field = Constants.GUIAppKey_Type_field;

local RESULT_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil);

local getObject = Constants.getObject;

local hook_data = {
    GUI070000 = nil,
    GUIPartsReward = nil,
    checkedNewItem = {}
};
local function skipJudgeAnimation(GUIPartsReward)
    if get__JudgeAnimationEnd_method:call(GUIPartsReward) == false then
        if get__WaitAnimationTime_method:call(GUIPartsReward) > 0.01 then
            set__WaitAnimationTime_method:call(GUIPartsReward, 0.01);
        end
    else
        if get__WaitControlTime_method:call(GUIPartsReward) > 0.01 then
            set__WaitControlTime_method:call(GUIPartsReward, 0.01);
        end
    end
end

local function hasNewItem(GUIPartsReward, Mode)
    hook_data.checkedNewItem[Mode] = false;
    local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward);
    local partsCount = get_Count_method:call(ItemGridParts);
    if partsCount > 0 then
        for i = 0, partsCount - 1 do
            local GUIItemGridPartsFluent = get_Item_method:call(ItemGridParts, i);
            if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) == true and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) == true then
                hook_data.checkedNewItem[Mode] = true;
                break;
            end
        end
    end
    return hook_data.checkedNewItem[Mode];
end

sdk.hook(GUIPartsReward_type_def:get_method("onVisibleUpdate"), function(args)
    if hook_data.GUIPartsReward == nil then
        local this = sdk.to_managed_object(args[2]);
        if get__IsViewMode_method:call(this) == false then
            local Owner = get_Owner_method:call(this);
            if get_IDInt_method:call(Owner) == UI070000 then
                hook_data.GUI070000 = Owner;
                hook_data.GUIPartsReward = this;
            end
        end
    end
end, function()
    local GUIPartsReward = hook_data.GUIPartsReward;
    if GUIPartsReward ~= nil then
        if get__isRandomAmuletMode_method:call(GUIPartsReward) == true then
            skipJudgeAnimation(GUIPartsReward);
        else
            local Mode = get__Mode_method:call(GUIPartsReward);
            if Mode == REWARD then
                if get_CurCtrlInputPriority_method:call(hook_data.GUI070000) == 0 then
                    local data = hook_data.checkedNewItem[Mode];
                    local newMarkVisible = data ~= nil and data or hasNewItem(GUIPartsReward, Mode);
                    if newMarkVisible == false then
                        receiveAll_method:call(GUIPartsReward);
                    end
                end
            else
                local data = hook_data.checkedNewItem[Mode];
                local newMarkVisible = data ~= nil and data or hasNewItem(GUIPartsReward, Mode);
                if newMarkVisible == true then
                    skipJudgeAnimation(GUIPartsReward);
                elseif get_CurCtrlInputPriority_method:call(hook_data.GUI070000) == 0 then
                    receiveAll_method:call(GUIPartsReward);
                end
            end
        end
    end
end);

local isResultSkip = nil;
sdk.hook(Constants.GUIAppOnTimerKey_onUpdate_method, function(args)
    local GUIAppOnTimerKey = sdk.to_managed_object(args[2]);
    if GUIAppKey_Type_field:get_data(GUIAppOnTimerKey) == RESULT_SKIP then
        thread.get_hook_storage()["this"] = GUIAppOnTimerKey;
        isResultSkip = true;
    end
end, function()
    if isResultSkip == true then
        isResultSkip = nil;
        thread.get_hook_storage()["this"]:set_field("_Success", true);
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI070000"):get_method("onClose"), function(args)
    hook_data = {
        GUI070000 = nil,
        GUIPartsReward = nil,
        checkedNewItem = {}
    };
end);
--<< GUI000003 Skip Confirm Dialogue >>--
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

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), getObject, function()
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
--<< GUI020100 Seamless Quest Result >>--
local GUI020100PanelQuestRewardItem_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestRewardItem");
local Reward_endFix_method = GUI020100PanelQuestRewardItem_type_def:get_method("endFix");
local Reward_endFix_Post_method = GUI020100PanelQuestRewardItem_type_def:get_method("<endFix>b__21_0");
local get_MyOwner_method = GUI020100PanelQuestRewardItem_type_def:get_method("get_MyOwner");
local JudgeMode_field = GUI020100PanelQuestRewardItem_type_def:get_field("JudgeMode");

local JUDGE_MODE_type_def = JudgeMode_field:get_type();
local JUDGE_MODE = {
    MODE01 = JUDGE_MODE_type_def:get_field("MODE01"):get_data(nil),
    MODE02 = JUDGE_MODE_type_def:get_field("MODE02"):get_data(nil)
};

local GUI020100_type_def = get_MyOwner_method:get_return_type();
local hasContribution_method = GUI020100_type_def:get_method("hasContribution");
local endQuestReward_method = GUI020100_type_def:get_method("endQuestReward");
local endQuestJudge_method = GUI020100_type_def:get_method("endQuestJudge");
local endRandomAmuletJudge_method = GUI020100_type_def:get_method("endRandomAmuletJudge");
local endQuestResultList_method = GUI020100_type_def:get_method("endQuestResultList");
local endQuestContribution_method = GUI020100_type_def:get_method("endQuestContribution");
local jumpFixQuestJudge_method = GUI020100_type_def:get_method("jumpFixQuestJudge");

local GUI020100PanelQuestResultList_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestResultList");
local Result_endFix_method = GUI020100PanelQuestResultList_type_def:get_method("endFix");

local GUI020100PanelQuestContribution_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestContribution");
local Contribution_endFix_method = GUI020100PanelQuestContribution_type_def:get_method("endFix");

local terminateQuestResult_method = Constants.GUIManager_type_def:get_method("terminateQuestResult");

local GUI020100 = nil;
local GUI020100PanelQuestRewardItem = nil;

local function finishRewardFlow()
    Reward_endFix_method:call(GUI020100PanelQuestRewardItem);
    Reward_endFix_Post_method:call(GUI020100PanelQuestRewardItem);
    GUI020100PanelQuestRewardItem = nil;
end

local function terminateQuestResultFlow()
    terminateQuestResult_method:call(Constants.GUIManager);
    GUI020100 = nil;
end

sdk.hook(GUI020100PanelQuestRewardItem_type_def:get_method("start"), function(args)
    GUI020100PanelQuestRewardItem = sdk.to_managed_object(args[2]);
    GUI020100 = get_MyOwner_method:call(GUI020100PanelQuestRewardItem);
end);

sdk.hook(GUI020100PanelQuestRewardItem_type_def:get_method("onVisibleUpdate"), nil, function()
    if GUI020100PanelQuestRewardItem ~= nil then
        local JudgeMode = JudgeMode_field:get_data(GUI020100PanelQuestRewardItem);
        if JudgeMode == JUDGE_MODE.MODE01 then
            endQuestJudge_method:call(GUI020100);
        elseif JudgeMode == JUDGE_MODE.MODE02 then
            jumpFixQuestJudge_method:call(GUI020100);
            endRandomAmuletJudge_method:call(GUI020100);
        else
            endQuestReward_method:call(GUI020100);
        end
    end
end);

sdk.hook(GUIPartsReward_type_def:get_method("endDialog(app.GUINotifyWindowDef.ID)"), function(args)
    if GUI020100PanelQuestRewardItem ~= nil then
        finishRewardFlow();
    end
end);

local hasContribution = nil;
sdk.hook(GUI020100PanelQuestResultList_type_def:get_method("start"), function(args)
    if GUI020100PanelQuestRewardItem ~= nil then
        finishRewardFlow();
    end
    hasContribution = hasContribution_method:call(GUI020100);
    if hasContribution == false then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    endQuestResultList_method:call(GUI020100);
    if hasContribution == false then
        Result_endFix_method:call(thread.get_hook_storage()["this"]);
        terminateQuestResultFlow();
    end
    hasContribution = nil;
end);

sdk.hook(GUI020100PanelQuestContribution_type_def:get_method("start"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    endQuestContribution_method:call(GUI020100);
    Contribution_endFix_method:call(thread.get_hook_storage()["this"]);
    terminateQuestResultFlow();
end);