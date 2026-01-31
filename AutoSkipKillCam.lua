local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;

local get_hook_storage = Constants.get_hook_storage;

local isInput_method = Constants.isInput_method;
local requestCallTrigger_method = Constants.requestCallTrigger_method;
local getThisPtr = Constants.getThisPtr;
local requestClose = Constants.requestClose;

local GUI020202_type_def = find_type_definition("app.GUI020202");
local Input_field = GUI020202_type_def:get_field("_Input");

local RETURN_TIME_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil);

local FALSE_ptr = Constants.to_ptr(false);
local ZERO_float_ptr = Constants.ZERO_float_ptr;

hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function()
    return FALSE_ptr;
end);

hook(find_type_definition("app.mcHunterQuestActionController"):get_method("requestDelayStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE, System.Single)"), function(args)
    args[4] = ZERO_float_ptr;
end);

hook(GUI020202_type_def:get_method("guiVisibleUpdate"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    if isInput_method:call(this_ptr, RETURN_TIME_SKIP) then
        requestCallTrigger_method:call(Input_field:get_data(this_ptr), RETURN_TIME_SKIP);
    end
end);

hook(find_type_definition("app.GUI020204"):get_method("onOpen"), getThisPtr, requestClose);