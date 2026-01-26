local Constants = _G.require("Constants/Constants");

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local GUI090002PartsItemReceive_type_def = Constants.find_type_definition("app.GUI090002PartsItemReceive");
local set__WaitControlTime_method = GUI090002PartsItemReceive_type_def:get_method("set__WaitControlTime(System.Single)");

Constants.hook(GUI090002PartsItemReceive_type_def:get_method("start(app.cGUIPartsRecieveItemsInfo, System.Collections.Generic.List`1<app.cReceiveItemInfo>)"), getThisPtr, function()
    set__WaitControlTime_method:call(get_hook_storage().this_ptr, 0.0);
end);