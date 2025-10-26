local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");

local GUIAppKey_type_def = Constants.GUIAppKey_type_def;
local Type_field = Constants.GUIAppKey_Type_field;

local TITLE_START = Constants.GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

sdk.hook(GUI010001_type_def:get_method("onOpen"), Constants.getThisPtr, function()
    local GUI010001_ptr = thread.get_hook_storage()["this_ptr"];
    sdk.set_native_field(GUI010001_ptr, GUI010001_type_def, "_Flow", 5);
    sdk.set_native_field(GUI010001_ptr, GUI010001_type_def, "_Skip", true);
end);

sdk.hook(sdk.find_type_definition("app.GUI010002"):get_method("onOpen"), Constants.getObject, function()
    local GUI010002 = thread.get_hook_storage()["this"];
    GUI010002:write_float(0x220, GUI010002:read_float(0x224));
end);

local isTitleStart = nil;
sdk.hook(GUIAppKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local this_ptr = args[2];
    if Type_field:get_data(this_ptr) == TITLE_START then
        thread.get_hook_storage()["this_ptr"] = this_ptr;
        isTitleStart = true;
    end
end, function()
    if isTitleStart == true then
        isTitleStart = nil;
        sdk.set_native_field(thread.get_hook_storage()["this_ptr"], GUIAppKey_type_def, "_Success", true);
    end
end);