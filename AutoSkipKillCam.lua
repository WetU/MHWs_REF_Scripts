local Constants = _G.require("Constants/Constants");

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_ptr = Constants.to_ptr;
local float_to_ptr = Constants.float_to_ptr;

local get_hook_storage = Constants.get_hook_storage;

local on_script_reset = Constants.on_script_reset;

local getThisPtr = Constants.getThisPtr;

local requestClose_method = Constants.requestClose_method;

local GUI020201_type_def = find_type_definition("app.GUI020201");
local StampPanels_field = GUI020201_type_def:get_field("_StampPanels");
local GUI020201_CurType_field = GUI020201_type_def:get_field("_CurType");

local TYPE_MAX = GUI020201_CurType_field:get_type():get_field("MAX"):get_data(nil);

local GUI020202_type_def = find_type_definition("app.GUI020202");
local Input_field = GUI020202_type_def:get_field("_Input");
local isInput_method = GUI020202_type_def:get_method("isInput(app.GUIFunc.TYPE)");

local requestCallTrigger_method = Constants.requestCallTrigger_method;

local RETURN_TIME_SKIP = Constants.GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil);

local GUI020216_type_def = find_type_definition("app.GUI020216");
local Panel_field = GUI020216_type_def:get_field("_Panel");
local GUI020216_CurType_field = GUI020216_type_def:get_field("_CurType");

local get_Component_method = Panel_field:get_type():get_method("get_Component");

local set_PlaySpeed_method = get_Component_method:get_return_type():get_method("set_PlaySpeed(System.Single)");

local FALSE_ptr = to_ptr(false);
local ZERO_float_ptr = Constants.ZERO_float_ptr;

hook(Constants.QuestDirector_type_def:get_method("canPlayHuntCompleteCamera"), nil, function()
    return FALSE_ptr;
end);

hook(find_type_definition("app.mcHunterQuestActionController"):get_method("requestDelayStamp(app.mcHunterQuestActionController.QUEST_ACTION_TYPE, System.Single)"), function(args)
    args[4] = ZERO_float_ptr;
end);

local hook_datas = {
    GUI = nil,
    reqSkip = nil,
    isSetted = nil
};

local function postHook_guiVisibleUpdate()
    if hook_datas.reqSkip and hook_datas.isSetted ~= true then
        set_PlaySpeed_method:call(hook_datas.GUI, 30.0);
        hook_datas.isSetted = true;
        hook_datas.reqSkip = nil;
    end
end

local function preHook_onCloseApp()
    if hook_datas.isSetted then
        set_PlaySpeed_method:call(hook_datas.GUI, 1.0);
        hook_datas.isSetted = nil;
        hook_datas.GUI = nil;
    end
end

hook(GUI020201_type_def:get_method("onOpen"), getThisPtr, function()
    local GUI020201_ptr = get_hook_storage().this_ptr;
    if GUI020201_CurType_field:get_data(GUI020201_ptr) ~= TYPE_MAX then
        hook_datas.GUI = get_Component_method:call(StampPanels_field:get_data(GUI020201_ptr):get_element(0));
        hook_datas.reqSkip = true;
    end
end);

hook(GUI020201_type_def:get_method("guiVisibleUpdate"), nil, postHook_guiVisibleUpdate);

hook(GUI020201_type_def:get_method("onCloseApp"), preHook_onCloseApp);

hook(GUI020216_type_def:get_method("onOpen"), getThisPtr, function()
    local GUI020216_ptr = get_hook_storage().this_ptr;
    if GUI020216_CurType_field:get_data(GUI020216_ptr) ~= TYPE_MAX then
        hook_datas.GUI = get_Component_method:call(Panel_field:get_data(GUI020216_ptr));
        hook_datas.reqSkip = true;
    end
end);

hook(GUI020216_type_def:get_method("guiVisibleUpdate"), nil, postHook_guiVisibleUpdate);

hook(GUI020216_type_def:get_method("onCloseApp"), preHook_onCloseApp);

hook(GUI020202_type_def:get_method("guiVisibleUpdate"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    if isInput_method:call(this_ptr, RETURN_TIME_SKIP) then
        requestCallTrigger_method:call(Input_field:get_data(this_ptr), RETURN_TIME_SKIP);
    end
end);

hook(find_type_definition("app.GUI020204"):get_method("onOpen"), getThisPtr, function()
    requestClose_method:call(get_hook_storage().this_ptr, true);
end);

on_script_reset(function()
    if hook_datas.isSetted then
        set_PlaySpeed_method:call(hook_datas.GUI, 1.0);
    end
end);