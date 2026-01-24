local Constants = _G.require("Constants/Constants");

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local GUI090002PartsItemReceive_type_def = Constants.find_type_definition("app.GUI090002PartsItemReceive");
local get__Mode_method = GUI090002PartsItemReceive_type_def:get_method("get__Mode");
local set__WaitAnimationTime_method = GUI090002PartsItemReceive_type_def:get_method("set__WaitAnimationTime(System.Single)");
local set__WaitControlTime_method = GUI090002PartsItemReceive_type_def:get_method("set__WaitControlTime(System.Single)");

local MODE_type_def = get__Mode_method:get_return_type();
local JUDGE00 = MODE_type_def:get_field("JUDGE00"):get_data(nil);
local JUDGE01 = MODE_type_def:get_field("JUDGE01"):get_data(nil);

Constants.hook(GUI090002PartsItemReceive_type_def:get_method("start(app.cGUIPartsRecieveItemsInfo, System.Collections.Generic.List`1<app.cReceiveItemInfo>)"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    set__WaitControlTime_method:call(this_ptr, 0.0);
    local Mode = get__Mode_method:call(this_ptr);
    if Mode == JUDGE00 or Mode == JUDGE01 then
        set__WaitAnimationTime_method:call(this_ptr, 0.01);
    end
end);