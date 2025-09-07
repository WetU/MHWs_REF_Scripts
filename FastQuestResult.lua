local Constants = _G.require("Constants/Constants");

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
--<< GUI070000 Fix Quest Result >>--
local UI070000 = sdk.find_type_definition("app.GUIID.ID"):get_field("UI070000"):get_data(nil); -- static

local RESULT_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil); -- static

local GUI070000_type_def = sdk.find_type_definition("app.GUI070000");
local get_IDInt_method = GUI070000_type_def:get_method("get_IDInt");
local get_CurCtrlInputPriority_method = GUI070000_type_def:get_method("get_CurCtrlInputPriority");

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

local REWARD = get__Mode_method:get_return_type():get_field("REWARD"):get_data(nil); -- static

local get_Item_method = ItemGridParts_field:get_type():get_method("get_Item(System.Int32)");

local GUIItemGridPartsFluent_type_def = get_Item_method:get_return_type();
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem"); -- via.gui.SelectItem
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_method("get__PanelNewMark"); -- via.gui.Panel

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_method("get_ActualVisible");

local GUIAppOnTimerKey_type_def = Constants.GUIAppOnTimerKey_type_def;
local GUIAppKey_Type_field = Constants.GUIAppKey_Type_field;

local function skipJudgeAnimation(GUIPartsReward_ptr)
    if get__JudgeAnimationEnd_method:call(GUIPartsReward_ptr) == false then
        if get__WaitAnimationTime_method:call(GUIPartsReward_ptr) > 0.01 then
            set__WaitAnimationTime_method:call(GUIPartsReward_ptr, 0.01);
        end
    else
        if get__WaitControlTime_method:call(GUIPartsReward_ptr) > 0.01 then
            set__WaitControlTime_method:call(GUIPartsReward_ptr, 0.01);
        end
    end
end

local hook_data = {
    GUI070000 = nil,
    GUIPartsReward_ptr = nil,
    checkedNewItem = {}
};

sdk.hook(GUIPartsReward_type_def:get_method("onVisibleUpdate"), function(args)
    if hook_data.GUIPartsReward_ptr == nil then
        local this_ptr = args[2];
        if get__IsViewMode_method:call(this_ptr) == false then
            local Owner = get_Owner_method:call(this_ptr);
            if get_IDInt_method:call(Owner) == UI070000 then
                hook_data.GUI070000 = Owner;
                hook_data.GUIPartsReward_ptr = this_ptr;
            end
        end
    end
end, function()
    local GUIPartsReward_ptr = hook_data.GUIPartsReward_ptr;
    if GUIPartsReward_ptr ~= nil then
        if get__isRandomAmuletMode_method:call(GUIPartsReward_ptr) == true then
            skipJudgeAnimation(GUIPartsReward_ptr);
        else
            local Mode = get__Mode_method:call(GUIPartsReward_ptr);
            if hook_data.checkedNewItem[Mode] == nil then
                hook_data.checkedNewItem[Mode] = false;
                local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward_ptr);
                for i = 0, GenericList_get_Count_method:call(ItemGridParts) - 1 do
                    local GUIItemGridPartsFluent = get_Item_method:call(ItemGridParts, i);
                    if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) == true and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) == true then
                        hook_data.checkedNewItem[Mode] = true;
                        break;
                    end
                end
            end
            if Mode == REWARD then
                if hook_data.checkedNewItem[Mode] == false and get_CurCtrlInputPriority_method:call(hook_data.GUI070000) == 0 then
                    receiveAll_method:call(GUIPartsReward_ptr);
                end
            else
                if hook_data.checkedNewItem[Mode] == true then
                    skipJudgeAnimation(GUIPartsReward_ptr);
                elseif get_CurCtrlInputPriority_method:call(hook_data.GUI070000) == 0 then
                    receiveAll_method:call(GUIPartsReward_ptr);
                end
            end
        end
    end
end);

local isResultSkip = nil;
sdk.hook(Constants.GUIAppOnTimerKey_onUpdate_method, function(args)
    local this_ptr = args[2];
    if GUIAppKey_Type_field:get_data(this_ptr) == RESULT_SKIP then
        thread.get_hook_storage()["this_ptr"] = this_ptr;
        isResultSkip = true;
    end
end, function()
    if isResultSkip == true then
        isResultSkip = nil;
        sdk.set_native_field(thread.get_hook_storage()["this_ptr"], GUIAppOnTimerKey_type_def, "_Success", true);
    end
end);

sdk.hook(GUI070000_type_def:get_method("onClose"), function(args)
    hook_data = {
        GUI070000 = nil,
        GUIPartsReward_ptr = nil,
        checkedNewItem = {}
    };
end);
--<< GUI020100 Seamless Quest Result >>--
local GUI020100PanelQuestRewardItem_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestRewardItem");
local Reward_endFix_callback_method = GUI020100PanelQuestRewardItem_type_def:get_method("<endFix>b__21_0");
local get_MyOwner_method = GUI020100PanelQuestRewardItem_type_def:get_method("get_MyOwner");
local JudgeMode_field = GUI020100PanelQuestRewardItem_type_def:get_field("JudgeMode");

local JUDGE_MODE_type_def = JudgeMode_field:get_type();
local JUDGE_MODE = {
    MODE01 = JUDGE_MODE_type_def:get_field("MODE01"):get_data(nil), -- static
    MODE02 = JUDGE_MODE_type_def:get_field("MODE02"):get_data(nil)  -- static
};

local Fix_endFix_method = GUI020100PanelQuestRewardItem_type_def:get_parent_type():get_parent_type():get_method("endFix");

local GUI020100_type_def = get_MyOwner_method:get_return_type();
local hasContribution_method = GUI020100_type_def:get_method("hasContribution");
local endQuestReward_method = GUI020100_type_def:get_method("endQuestReward");
local endQuestJudge_method = GUI020100_type_def:get_method("endQuestJudge");
local endQuestResultList_method = GUI020100_type_def:get_method("endQuestResultList");
local endQuestContribution_method = GUI020100_type_def:get_method("endQuestContribution");
local jumpFixQuestJudge_method = GUI020100_type_def:get_method("jumpFixQuestJudge");

local GUI020100PanelQuestResultList_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestResultList");
local Result_endFix_method = GUI020100PanelQuestResultList_type_def:get_method("endFix");

local GUI020100PanelQuestContribution_type_def = sdk.find_type_definition("app.cGUI020100PanelQuestContribution");
local Contribution_endFix_method = GUI020100PanelQuestContribution_type_def:get_method("endFix");

local terminateQuestResult_method = Constants.GUIManager_type_def:get_method("terminateQuestResult");

local GUI020100 = nil;
local GUI020100PanelQuestRewardItem_ptr = nil;

local function terminateQuestResultFlow()
    terminateQuestResult_method:call(Constants.GUIManager);
    GUI020100 = nil;
end

sdk.hook(GUI020100PanelQuestRewardItem_type_def:get_method("start"), function(args)
    GUI020100PanelQuestRewardItem_ptr = args[2];
    GUI020100 = get_MyOwner_method:call(GUI020100PanelQuestRewardItem_ptr);
end);

sdk.hook(GUI020100PanelQuestRewardItem_type_def:get_method("onVisibleUpdate"), nil, function()
    if GUI020100PanelQuestRewardItem_ptr ~= nil then
        local JudgeMode = JudgeMode_field:get_data(GUI020100PanelQuestRewardItem_ptr);
        if JudgeMode == JUDGE_MODE.MODE01 then
            endQuestJudge_method:call(GUI020100);
        elseif JudgeMode == JUDGE_MODE.MODE02 then
            jumpFixQuestJudge_method:call(GUI020100);
            Fix_endFix_method:call(GUI020100PanelQuestRewardItem_ptr);
            Reward_endFix_callback_method:call(GUI020100PanelQuestRewardItem_ptr);
            GUI020100 = nil;
            GUI020100PanelQuestRewardItem_ptr = nil;
        else
            endQuestReward_method:call(GUI020100);
        end
    end
end);

sdk.hook(GUIPartsReward_type_def:get_method("endDialog(app.GUINotifyWindowDef.ID)"), function(args)
    if GUI020100PanelQuestRewardItem_ptr ~= nil then
        GUI020100PanelQuestRewardItem_ptr = nil;
    end
end);

local hasContribution = nil;
sdk.hook(GUI020100PanelQuestResultList_type_def:get_method("start"), function(args)
    if GUI020100PanelQuestRewardItem_ptr ~= nil then
        GUI020100PanelQuestRewardItem_ptr = nil;
    end
    hasContribution = hasContribution_method:call(GUI020100);
    if hasContribution == false then
        thread.get_hook_storage()["this_ptr"] = args[2];
    end
end, function()
    endQuestResultList_method:call(GUI020100);
    if hasContribution == false then
        Result_endFix_method:call(thread.get_hook_storage()["this_ptr"]);
        terminateQuestResultFlow();
    end
    hasContribution = nil;
end);

sdk.hook(GUI020100PanelQuestContribution_type_def:get_method("start"), getThisPtr, function()
    endQuestContribution_method:call(GUI020100);
    Contribution_endFix_method:call(thread.get_hook_storage()["this_ptr"]);
    terminateQuestResultFlow();
end);