local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_managed_object = Constants.to_managed_object;

local get_hook_storage = Constants.get_hook_storage;

local isInput_method = Constants.isInput_method;
local requestCallTrigger_method = Constants.requestCallTrigger_method;
local getThisPtr = Constants.getThisPtr;
local requestClose = Constants.requestClose;

local skipOriginal = Constants.skipOriginal;

local isHagitoriTime_method = Constants.NpcPartnerUtil_type_def:get_method("isHagitoriTime"); -- static

local GUI020202_type_def = find_type_definition("app.GUI020202");
local Input_field = GUI020202_type_def:get_field("_Input");

local RETURN_TIME_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil);

local FALSE_ptr = Constants.to_ptr(false);
local ZERO_float_ptr = Constants.ZERO_float_ptr;

hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), skipOriginal, function()
    return FALSE_ptr;
end);

hook(find_type_definition("app.mcHunterQuestActionController"):get_method("requestDelayStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE, System.Single)"), function(args)
    args[4] = ZERO_float_ptr;
end);

local isHagitoriTime = nil;
hook(GUI020202_type_def:get_method("guiVisibleUpdate"), function(args)
    isHagitoriTime = isHagitoriTime_method:call(nil);
    if isHagitoriTime ~= nil then
        if isHagitoriTime then
            get_hook_storage().this_ptr = args[2];
        else
            get_hook_storage().this = to_managed_object(args[2]);
        end
    end
end, function()
    if isHagitoriTime ~= nil then
        if isHagitoriTime then
            local this_ptr = get_hook_storage().this_ptr;
            if isInput_method:call(this_ptr, RETURN_TIME_SKIP) then
                requestCallTrigger_method:call(Input_field:get_data(this_ptr), RETURN_TIME_SKIP);
            end
        else
            get_hook_storage().this:write_byte(0x287, 0);
        end
        isHagitoriTime = nil;
    end
end);

hook(find_type_definition("app.GUI020204"):get_method("onOpen"), getThisPtr, requestClose);