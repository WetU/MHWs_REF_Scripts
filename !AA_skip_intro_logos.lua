local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");
local Flow_field = GUI010001_type_def:get_field("_Flow");
local Skip_field = GUI010001_type_def:get_field("_Skip");
local EnableSkip_field = GUI010001_type_def:get_field("_EnableSkip");

local FLOW_type_def = sdk.find_type_definition("app.GUI010001.FLOW");
local STARTUP = FLOW_type_def:get_field("STARTUP"):get_data(nil); -- static
local COPYRIGHT = FLOW_type_def:get_field("COPYRIGHT"):get_data(nil); -- static

local TRUE_ptr = sdk.to_ptr(true);

sdk.hook(GUI010001_type_def:get_method("guiVisibleUpdate"), function(args)
    thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
end, function()
    local GUI010001 = thread.get_hook_storage()["this"];
    local Flow = Flow_field:get_data(GUI010001);
    if (Flow > STARTUP and Flow <= COPYRIGHT) and EnableSkip_field:get_data(GUI010001) == true and Skip_field:get_data(GUI010001) == false then
        GUI010001:set_field("_Skip", true);
    end
end);

local isWaitConfirm = nil;
sdk.hook(sdk.find_type_definition("app.LogoController.cAutoSaveConfirm"):get_method("enter"), nil, function(retval)
    isWaitConfirm = (sdk.to_int64(retval) & 1) == 1;
    return retval;
end);

sdk.hook(GUI010001_type_def:get_method("isInputDecideTriggerCore"), nil, function(retval)
    if isWaitConfirm == true then
        isWaitConfirm = nil;
        return TRUE_ptr;
    end
    return retval;
end);

local isWaitPressAnyKey = nil;
sdk.hook(sdk.find_type_definition("app.GUI010100"):get_method("guiVisibleUpdate"), nil, function()
    isWaitPressAnyKey = true;
end);

sdk.hook(sdk.find_type_definition("app.TitleController.cTitleMenu"):get_method("enter"), nil, function(retval)
    isWaitPressAnyKey = (sdk.to_int64(retval) & 1) ~= 1;
    return retval;
end);

sdk.hook(GUI010001_type_def:get_method("isInputSuccessCore(app.GUIFunc.TYPE)"), nil, function(retval)
    if isWaitPressAnyKey == true then
        isWaitPressAnyKey = nil;
        return TRUE_ptr;
    end
    return retval;
end);