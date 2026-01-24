local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_int64 = Constants.to_int64;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local get_IDInt_method = Constants.get_IDInt_method;
local get_InputPriority_method = Constants.get_InputPriority_method;
local requestCallTrigger_method = Constants.requestCallTrigger_method;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;

local SMALL_float_ptr = Constants.SMALL_float_ptr;
--<< GUI070000 Fix Quest Result >>--
local UI070000 = Constants.GUIID_type_def:get_field("UI070000"):get_data(nil); -- static

local GUIPartsReward_type_def = find_type_definition("app.cGUIPartsReward");
local set__WaitAnimationTime_method = GUIPartsReward_type_def:get_method("set__WaitAnimationTime(System.Single)");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local GUIPartsReward_InputCtrl_field = GUIPartsReward_type_def:get_field("_InputCtrl");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");

local get_Owner_method = GUIPartsReward_type_def:get_parent_type():get_method("get_Owner");

local JUDGE = find_type_definition("app.cGUIPartsReward.MODE"):get_field("JUDGE"):get_data(nil); -- static

local GUIItemGridPartsFluent_type_def = find_type_definition("app.cGUIItemGridPartsFluent");
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem");
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_parent_type():get_parent_type():get_method("get__PanelNewMark");

local get_Enabled_method = get_SelectItem_method:get_return_type():get_method("get_Enabled");

local get_ActualVisible_method = Constants.get_ActualVisible_method;

local GUI070001_type_def = find_type_definition("app.GUI070001");
local get_IsViewMode_method = GUI070001_type_def:get_method("get_IsViewMode");
local skipAnimation_method = GUI070001_type_def:get_method("skipAnimation");

local function GUIPartsReward_getMode(mode_ptr, isRandomAmulet_ptr)
    local mode = to_int64(mode_ptr) & 0xFFFFFFFF;
    if mode == JUDGE and (to_int64(isRandomAmulet_ptr) & 1) == 1 then
        mode = 2;
    end
    return mode;
end

-- args[5] = isViewMode;
-- args[6] = isRandomAmuletJudge;
local isFixQuestResult = nil;
hook(GUIPartsReward_type_def:get_method("start(app.cGUIPartsRewardInfo, app.cGUIPartsReward.MODE, System.Boolean, System.Boolean)"), function(args)
    if (to_int64(args[5]) & 1) == 0 then
        local this_ptr = args[2];
        if get_IDInt_method:call(get_Owner_method:call(this_ptr)) == UI070000 then
            local storage = get_hook_storage();
            storage.this_ptr = this_ptr;
            storage.Mode = GUIPartsReward_getMode(args[4], args[6]);
            isFixQuestResult = true;
        end
    end
end, function()
    if isFixQuestResult then
        isFixQuestResult = nil;
        local storage = get_hook_storage();
        local this_ptr = storage.this_ptr;
        set__WaitControlTime_method:call(this_ptr, 0.0);
        local Mode = storage.Mode;
        if Mode ~= 2 then
            local ItemGridParts = ItemGridParts_field:get_data(this_ptr);
            for i = 0, GenericList_get_Count_method:call(ItemGridParts) - 1 do
                local GUIItemGridPartsFluent = GenericList_get_Item_method:call(ItemGridParts, i);
                if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) then
                    if Mode == JUDGE then
                        set__WaitAnimationTime_method:call(this_ptr, 0.01);
                    end
                    return;
                end
            end
            if get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                receiveAll_method:call(this_ptr);
            end
        else
            set__WaitAnimationTime_method:call(this_ptr, 0.01);
        end
    end
end);

hook(GUI070001_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    if get_IsViewMode_method:call(this_ptr) == false then
        skipAnimation_method:call(this_ptr);
    end
end);
--<< GUI020100 Seamless Quest Result >>--
local GUI020100_type_def = find_type_definition("app.GUI020100");
local get__PartsQuestRewardItem_method = GUI020100_type_def:get_method("get__PartsQuestRewardItem");
local endQuestReward_method = GUI020100_type_def:get_method("endQuestReward");
local endQuestJudge_method = GUI020100_type_def:get_method("endQuestJudge");
local endQuestResultList_method = GUI020100_type_def:get_method("endQuestResultList");
local endQuestContribution_method = GUI020100_type_def:get_method("endQuestContribution");
local GUI020100_InputCtrl_field = GUI020100_type_def:get_field("_InputCtrl");

local get_FixControl_method = get__PartsQuestRewardItem_method:get_return_type():get_parent_type():get_parent_type():get_method("get_FixControl");

local finish_method = get_FixControl_method:get_return_type():get_method("finish");

local JUST_TIMING_SHORTCUT = Constants.GUIFunc_TYPE_type_def:get_field("JUST_TIMING_SHORTCUT"):get_data(nil);

hook(GUI020100_type_def:get_method("toQuestReward"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    finish_method:call(get_FixControl_method:call(get__PartsQuestRewardItem_method:call(this_ptr)));
    endQuestReward_method:call(this_ptr);
end);

hook(GUI020100_type_def:get_method("toQuestJudge"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    finish_method:call(get_FixControl_method:call(get__PartsQuestRewardItem_method:call(this_ptr)));
    endQuestJudge_method:call(this_ptr);
end);

hook(GUI020100_type_def:get_method("toRandomAmuletJudge"), getThisPtr, function()
    requestCallTrigger_method:call(GUI020100_InputCtrl_field:get_data(get_hook_storage().this_ptr), JUST_TIMING_SHORTCUT);
end);

hook(GUI020100_type_def:get_method("toQuestResultList"), getThisPtr, function()
    endQuestResultList_method:call(get_hook_storage().this_ptr);
end);

hook(GUI020100_type_def:get_method("toQuestContribution"), getThisPtr, function()
    endQuestContribution_method:call(get_hook_storage().this_ptr);
end);

hook(find_type_definition("app.cGUIQuestResultInfo"):get_method("getSeamlesResultListDispTime"), nil, function()
    return SMALL_float_ptr;
end);