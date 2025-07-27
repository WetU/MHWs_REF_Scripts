local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local COPYRIGHT = sdk.find_type_definition("app.GUI010001.FLOW"):get_field("COPYRIGHT"):get_data(nil);

local TITLE_START = Constants.GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

sdk.hook(sdk.find_type_definition("app.GUI010001"):get_method("onOpen"), Constants.getObject, function()
    local GUI010001 = thread.get_hook_storage()["this"];
    GUI010001:set_field("_Flow", COPYRIGHT);
    GUI010001:set_field("_Skip", true);
end);

sdk.hook(sdk.find_type_definition("app.GUI010002"):get_method("onOpen"), Constants.getObject, function()
    local GUI010002 = thread.get_hook_storage()["this"];
    GUI010002:write_float(0x220, GUI010002:read_float(0x224));
end);

local isTitleStart = nil;
sdk.hook(Constants.GUIAppKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local GUIAppKey = sdk.to_managed_object(args[2]);
    if Constants.getKey_Type(GUIAppKey) == TITLE_START then
        thread.get_hook_storage()["this"] = GUIAppKey;
        isTitleStart = true;
    end
end, function()
    if isTitleStart == true then
        isTitleStart = nil;
        thread.get_hook_storage()["this"]:set_field("_Success", true);
    end
end);