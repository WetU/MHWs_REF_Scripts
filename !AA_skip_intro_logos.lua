local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local GUI010001_type_def = sdk.find_type_definition("app.GUI010001");
local Skip_field = GUI010001_type_def:get_field("_Skip");
local EnableSkip_field = GUI010001_type_def:get_field("_EnableSkip");

local GUI010002_type_def = sdk.find_type_definition("app.GUI010002");
local requestClose_method = GUI010002_type_def:get_method("requestClose(System.Boolean)");

local GUIAppKey_type_def = sdk.find_type_definition("app.cGUIAppKey");
local Type_field = GUIAppKey_type_def:get_field("_Type");

local TITLE_START = Constants.GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

sdk.hook(GUI010001_type_def:get_method("onOpen"), function(args)
    local GUI010001 = sdk.to_managed_object(args[2]);
    sdk.hook_vtable(GUI010001, GUI010001.doUpdateApp, Constants.getObject, function()
        local GUI010001 = thread.get_hook_storage()["this"];
        if EnableSkip_field:get_data(GUI010001) == true and Skip_field:get_data(GUI010001) == false then
            GUI010001:set_field("_Skip", true);
        end
    end);
end);

sdk.hook(GUI010002_type_def:get_method("onOpen"), Constants.getObject, function()
    requestClose_method:call(thread.get_hook_storage()["this"], false);
end);

sdk.hook(GUIAppKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local GUIAppKey = sdk.to_managed_object(args[2]);
    if Type_field:get_data(GUIAppKey) == TITLE_START then
        thread.get_hook_storage()["this"] = GUIAppKey;
    end
end, function()
    local GUIAppKey = thread.get_hook_storage()["this"];
    if GUIAppKey ~= nil then
        GUIAppKey:set_field("_Success", true);
    end
end);