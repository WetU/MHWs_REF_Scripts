local Constants = _G.require("Constants/Constants");

local set_native_field = Constants.set_native_field;
local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_managed_object = Constants.to_managed_object;

local get_hook_storage = Constants.get_hook_storage;

local isInput_method = Constants.isInput_method;
local getThisPtr = Constants.getThisPtr;
local requestClose = Constants.requestClose;

local skipOriginal = Constants.skipOriginal;

local isHagitoriTime_method = Constants.NpcPartnerUtil_type_def:get_method("isHagitoriTime"); -- static

local GUI020202_type_def = find_type_definition("app.GUI020202");
local Input_field = GUI020202_type_def:get_field("_Input");

local get_Callback_method = Input_field:get_type():get_method("get_Callback");

local Callback_type_def = get_Callback_method:get_return_type()
local CallOtherFuncFlag_field = Callback_type_def:get_field("_CallOtherFuncFlag");

local BaseState_field = Constants.BaseState_field;

local RETURN_TIME_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil);
local VISIBLE = BaseState_field:get_type():get_field("VISIBLE"):get_data(nil);

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
    local this_ptr = args[2];
    if isHagitoriTime_method:call(nil) then
        get_hook_storage().this_ptr = this_ptr;
        isHagitoriTime = true;
    elseif BaseState_field:get_data(this_ptr) == VISIBLE then
        get_hook_storage().this = to_managed_object(this_ptr);
        isHagitoriTime = false;
    end
end, function()
    if isHagitoriTime ~= nil then
        if isHagitoriTime then
            local this_ptr = get_hook_storage().this_ptr;
            if isInput_method:call(this_ptr, RETURN_TIME_SKIP) then
                local Callback = get_Callback_method:call(Input_field:get_data(this_ptr));
                if CallOtherFuncFlag_field:get_data(Callback) == false then
                    set_native_field(Callback, Callback_type_def, "_CallOtherFuncFlag", true);
                    set_native_field(Callback, Callback_type_def, "_CallFunc", RETURN_TIME_SKIP);
                end
            end
        else
            get_hook_storage().this:write_byte(0x287, 0);
        end
        isHagitoriTime = nil;
    end
end);

hook(find_type_definition("app.GUI020204"):get_method("onOpen"), getThisPtr, requestClose);