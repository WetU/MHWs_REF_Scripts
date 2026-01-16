local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_int64 = Constants.to_int64;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local requestCallTrigger_method = Constants.requestCallTrigger_method;

local getMethod = Constants.getMethod;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;
--<< GUI070000 Fix Quest Result >>--
local UI070000 = Constants.GUIID_type_def:get_field("UI070000"):get_data(nil); -- static

local GUI070000_type_def = Constants.GUI070000_type_def;
local get_IDInt_method = GUI070000_type_def:get_method("get_IDInt");
local get_CurCtrlInputPriority_method = GUI070000_type_def:get_method("get_CurCtrlInputPriority");

local GUIPartsReward_type_def = find_type_definition("app.cGUIPartsReward");
local get__JudgeAnimationEnd_method = GUIPartsReward_type_def:get_method("get__JudgeAnimationEnd");
local get__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("get__WaitAnimationTime");
local set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local get__WaitControlTime_method = GUIPartsReward_type_def:get_method("get__WaitControlTime");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local get_Owner_method = GUIPartsReward_type_def:get_method("get_Owner");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");

local JUDGE = find_type_definition("app.cGUIPartsReward.MODE"):get_field("JUDGE"):get_data(nil); -- static

local GUIItemGridPartsFluent_type_def = find_type_definition("app.cGUIItemGridPartsFluent");
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem"); -- via.gui.SelectItem
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_method("get__PanelNewMark"); -- via.gui.Panel

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = get__PanelNewMark_method:get_return_type():get_method("get_ActualVisible");

local GUI070001_type_def = find_type_definition("app.GUI070001");
local get_IsViewMode_method = GUI070001_type_def:get_method("get_IsViewMode");
local skipAnimation_method = GUI070001_type_def:get_method("skipAnimation");

local function skipJudgeAnimation(GUIPartsReward)
    if get__JudgeAnimationEnd_method:call(GUIPartsReward) == false then
        if get__WaitAnimationTime_method:call(GUIPartsReward) > 0.01 then
            set__WaitAnimationTime_method:call(GUIPartsReward, 0.01);
        end
    elseif get__WaitControlTime_method:call(GUIPartsReward) > 0.01 then
        set__WaitControlTime_method:call(GUIPartsReward, 0.01);
    end
end

local GUI070000 = nil;
local GUIPartsReward_ptr = nil;
local Mode = nil;
local checkedNewItem = {};

hook(GUIPartsReward_type_def:get_method("start(app.cGUIPartsRewardInfo, app.cGUIPartsReward.MODE, System.Boolean, System.Boolean)"), function(args)
    if (to_int64(args[5]) & 1) == 0 then
        if GUI070000 == nil then
            local this_ptr = args[2];
            local Owner = get_Owner_method:call(this_ptr);
            if get_IDInt_method:call(Owner) == UI070000 then
                GUI070000 = Owner;
                GUIPartsReward_ptr = this_ptr;
            end
        end
        Mode = to_int64(args[4]) & 0xFFFFFFFF;
        if Mode == JUDGE and (to_int64(args[6]) & 1) == 1 then
            Mode = 2;
        end
    end
end, function()
    if GUIPartsReward_ptr ~= nil and Mode ~= 2 then
        local ItemGridParts = ItemGridParts_field:get_data(GUIPartsReward_ptr);
        for i = 0, GenericList_get_Count_method:call(ItemGridParts) - 1 do
            local GUIItemGridPartsFluent = GenericList_get_Item_method:call(ItemGridParts, i);
            if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) then
                checkedNewItem[Mode] = true;
                break;
            end
        end
    end
end);

hook(GUIPartsReward_type_def:get_method("onVisibleUpdate"), nil, function()
    if GUIPartsReward_ptr ~= nil then
        if Mode == 2 then
            skipJudgeAnimation(GUIPartsReward_ptr);
        else
            if checkedNewItem[Mode] ~= true then
                if get_CurCtrlInputPriority_method:call(GUI070000) == 0 then
                    receiveAll_method:call(GUIPartsReward_ptr);
                end
            elseif Mode == JUDGE then
                skipJudgeAnimation(GUIPartsReward_ptr);
            end
        end
    end
end);

hook(GUI070000_type_def:get_method("onClose"), function()
    GUI070000 = nil;
    GUIPartsReward_ptr = nil;
    Mode = nil;
    checkedNewItem = {};
end);

hook(GUI070001_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    if get_IsViewMode_method:call(this_ptr) == false then
        skipAnimation_method:call(this_ptr);
    end
end);
--<< GUI020100 Seamless Quest Result >>--
local GUI020100PanelQuestRewardItem_type_def = find_type_definition("app.cGUI020100PanelQuestRewardItem");
local GUI020100PanelQuestRewardItem_methods = GUI020100PanelQuestRewardItem_type_def:get_methods();
local Reward_endFix_method = getMethod(GUI020100PanelQuestRewardItem_methods, "endFix", false);
local Reward_endFix_callback_method = getMethod(GUI020100PanelQuestRewardItem_methods, "endFix", true);
local get_FixControl_method = GUI020100PanelQuestRewardItem_type_def:get_method("get_FixControl");
local get_MyOwner_method = GUI020100PanelQuestRewardItem_type_def:get_method("get_MyOwner");
local JudgeMode_field = GUI020100PanelQuestRewardItem_type_def:get_field("JudgeMode");

local finish_method = get_FixControl_method:get_return_type():get_method("finish");

local JUDGE_MODE_type_def = JudgeMode_field:get_type();
local JUDGE_MODE = {
    MODE01 = JUDGE_MODE_type_def:get_field("MODE01"):get_data(nil), -- static
    MODE02 = JUDGE_MODE_type_def:get_field("MODE02"):get_data(nil)  -- static
};

local GUI020100_type_def = get_MyOwner_method:get_return_type();
local hasContribution_method = GUI020100_type_def:get_method("hasContribution");
local quitResult_method = GUI020100_type_def:get_method("quitResult");
local InputCtrl_field = GUI020100_type_def:get_field("_InputCtrl");

local GUI020100PanelQuestResultList_type_def = find_type_definition("app.cGUI020100PanelQuestResultList");
local Result_endFix_method = GUI020100PanelQuestResultList_type_def:get_method("endFix");

local GUI020100PanelQuestContribution_type_def = find_type_definition("app.cGUI020100PanelQuestContribution");
local Contribution_endFix_method = GUI020100PanelQuestContribution_type_def:get_method("endFix");

local GUIManager_type_def = Constants.GUIManager_type_def;
local hasRandomAmuletJudge_method = GUIManager_type_def:get_method("hasRandomAmuletJudge");
local hasJudgeItemIgnoreRandomAmulet_method = GUIManager_type_def:get_method("hasJudgeItemIgnoreRandomAmulet");
local terminateQuestResult_method = GUIManager_type_def:get_method("terminateQuestResult");

local JUST_TIMING_SHORTCUT = Constants.GUIFunc_TYPE_type_def:get_field("JUST_TIMING_SHORTCUT"):get_data(nil);

local GUI020100 = nil;
local GUI020100PanelQuestRewardItem_ptr = nil;

local function endReward()
    Reward_endFix_method:call(GUI020100PanelQuestRewardItem_ptr);
    if Reward_endFix_callback_method ~= nil then
        Reward_endFix_callback_method:call(GUI020100PanelQuestRewardItem_ptr);
    end
    GUI020100PanelQuestRewardItem_ptr = nil;
end

local function terminateQuestResultFlow()
    quitResult_method:call(GUI020100);
    terminateQuestResult_method:call(Constants.GUIManager);
    GUI020100 = nil;
end

hook(getMethod(GUI020100PanelQuestRewardItem_methods, "start", false), function(args)
    GUI020100PanelQuestRewardItem_ptr = args[2];
    GUI020100 = get_MyOwner_method:call(GUI020100PanelQuestRewardItem_ptr);
end);

hook(getMethod(GUI020100PanelQuestRewardItem_methods, "onVisibleUpdate", false), nil, function()
    if GUI020100PanelQuestRewardItem_ptr ~= nil then
        local JudgeMode = JudgeMode_field:get_data(GUI020100PanelQuestRewardItem_ptr);
        if JudgeMode == JUDGE_MODE.MODE02 then
            requestCallTrigger_method:call(InputCtrl_field:get_data(GUI020100), JUST_TIMING_SHORTCUT);
            GUI020100 = nil;
            GUI020100PanelQuestRewardItem_ptr = nil;
        else
            local GUIManager = Constants.GUIManager;
            if JudgeMode == JUDGE_MODE.MODE01 then
                if hasRandomAmuletJudge_method:call(GUIManager) == false then
                    endReward();
                else
                    finish_method:call(get_FixControl_method:call(GUI020100PanelQuestRewardItem_ptr));
                end
            else
                if hasJudgeItemIgnoreRandomAmulet_method:call(GUIManager) == false and hasRandomAmuletJudge_method:call(GUIManager) == false then
                    endReward();
                else
                    finish_method:call(get_FixControl_method:call(GUI020100PanelQuestRewardItem_ptr));
                end
            end
        end
    end
end);

hook(GUI070000_type_def:get_method("onOpen"), function()
    if GUI020100 ~= nil then
        GUI020100 = nil;
    end
    if GUI020100PanelQuestRewardItem_ptr ~= nil then
        GUI020100PanelQuestRewardItem_ptr = nil;
    end
end);

hook(GUI020100PanelQuestResultList_type_def:get_method("start"), function(args)
    if GUI020100PanelQuestRewardItem_ptr ~= nil then
        GUI020100PanelQuestRewardItem_ptr = nil;
    end
    get_hook_storage().this_ptr = args[2];
end, function()
    Result_endFix_method:call(get_hook_storage().this_ptr);
    if hasContribution_method:call(GUI020100) == false then
        terminateQuestResultFlow();
    end
end);

hook(GUI020100PanelQuestContribution_type_def:get_method("start"), getThisPtr, function()
    Contribution_endFix_method:call(get_hook_storage().this_ptr);
    terminateQuestResultFlow();
end);