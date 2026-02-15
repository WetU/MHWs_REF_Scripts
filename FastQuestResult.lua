local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_int64 = Constants.to_int64;

local get_hook_storage = Constants.get_hook_storage;

local get_IDInt_method = Constants.get_IDInt_method;
local get_InputPriority_method = Constants.get_InputPriority_method;
local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;
local requestCallTrigger_method = Constants.requestCallTrigger_method;
local getThisPtr = Constants.getThisPtr;

local ZERO_float_ptr = Constants.ZERO_float_ptr;
--<< GUI070000 Fix Quest Result >>--
local UI070000 = Constants.GUIID_type_def:get_field("UI070000"):get_data(nil); -- static

local GUIPartsReward_type_def = find_type_definition("app.cGUIPartsReward");
local set__WaitControlTime_method = GUIPartsReward_type_def:get_method("set__WaitControlTime(System.Single)");
local receiveAll_method = GUIPartsReward_type_def:get_method("receiveAll");
local GUIPartsReward_InputCtrl_field = GUIPartsReward_type_def:get_field("_InputCtrl");
local ItemGridParts_field = GUIPartsReward_type_def:get_field("_ItemGridParts");

local get_Owner_method = GUIPartsReward_type_def:get_parent_type():get_method("get_Owner");

local GUIItemGridPartsFluent_type_def = find_type_definition("app.cGUIItemGridPartsFluent");
local get_SelectItem_method = GUIItemGridPartsFluent_type_def:get_method("get_SelectItem");
local get__PanelNewMark_method = GUIItemGridPartsFluent_type_def:get_parent_type():get_parent_type():get_method("get__PanelNewMark");

local get_Enabled_method = Constants.get_Enabled_method;

local get_ActualVisible_method = Constants.get_ActualVisible_method;

local GUI070001_type_def = find_type_definition("app.GUI070001");
local get_IsViewMode_method = GUI070001_type_def:get_method("get_IsViewMode");
local skipAnimation_method = GUI070001_type_def:get_method("skipAnimation");

-- args[5] = isViewMode;
-- args[6] = isRandomAmuletJudge;
local isFixQuestResult = nil;
hook(GUIPartsReward_type_def:get_method("start(app.cGUIPartsRewardInfo, app.cGUIPartsReward.MODE, System.Boolean, System.Boolean)"), function(args)
    if (to_int64(args[5]) & 1) == 0 then
        local this_ptr = args[2];
        if get_IDInt_method:call(get_Owner_method:call(this_ptr)) == UI070000 then
            local storage = get_hook_storage();
            storage.this_ptr = this_ptr;
            storage.isRandomAmuletJudge = (to_int64(args[6]) & 1) == 1;
            isFixQuestResult = true;
        end
    end
end, function()
    if isFixQuestResult then
        isFixQuestResult = nil;
        local storage = get_hook_storage();
        local this_ptr = storage.this_ptr;
        set__WaitControlTime_method:call(this_ptr, 0.0);
        if storage.isRandomAmuletJudge == false then
            local ItemGridParts = ItemGridParts_field:get_data(this_ptr);
            for i = 0, GenericList_get_Count_method:call(ItemGridParts) - 1 do
                local GUIItemGridPartsFluent = GenericList_get_Item_method:call(ItemGridParts, i);
                if get_Enabled_method:call(get_SelectItem_method:call(GUIItemGridPartsFluent)) and get_ActualVisible_method:call(get__PanelNewMark_method:call(GUIItemGridPartsFluent)) then
                    return;
                end
            end
            if get_InputPriority_method:call(GUIPartsReward_InputCtrl_field:get_data(this_ptr)) == 0 then
                receiveAll_method:call(this_ptr);
            end
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
local GUI020100_InputCtrl_field = GUI020100_type_def:get_field("_InputCtrl");

local get_FixControl_method = get__PartsQuestRewardItem_method:get_return_type():get_parent_type():get_parent_type():get_method("get_FixControl");

local finish_method = get_FixControl_method:get_return_type():get_method("finish");

local terminateQuestResult_method = Constants.GUIManager_type_def:get_method("terminateQuestResult");

local JUST_TIMING_SHORTCUT = Constants.GUIFunc_TYPE_type_def:get_field("JUST_TIMING_SHORTCUT"):get_data(nil);

local function endQuestReward()
    finish_method:call(get_FixControl_method:call(get__PartsQuestRewardItem_method:call(get_hook_storage().this_ptr)));
end

hook(GUI020100_type_def:get_method("toQuestReward"), getThisPtr, endQuestReward);
hook(GUI020100_type_def:get_method("toQuestJudge"), getThisPtr, endQuestReward);
hook(GUI020100_type_def:get_method("toRandomAmuletJudge"), getThisPtr, function()
    requestCallTrigger_method:call(GUI020100_InputCtrl_field:get_data(get_hook_storage().this_ptr), JUST_TIMING_SHORTCUT);
end);

hook(find_type_definition("app.cGUI020100PanelQuestResultList"):get_method("start"), nil, function()
    terminateQuestResult_method:call(Constants.GUIManager);
end);

hook(find_type_definition("app.cGUIQuestResultInfo"):get_method("getSeamlesResultListDispTime"), nil, function()
    return ZERO_float_ptr;
end);