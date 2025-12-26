local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");

local GUIAppKey_type_def = GUIAppOnTimerKey_type_def:get_parent_type();
local isOn_method = GUIAppKey_type_def:get_method("isOn");
local Type_field = GUIAppKey_type_def:get_field("_Type");

local GUIFunc_TYPE_type_def = Type_field:get_type();
local TITLE_START = GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil);

local onTimerKey_Types = {
    RETURN_TIME_SKIP = GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil),
    RESULT_SKIP = GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil)
};

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

local onTimerKey = nil;
sdk.hook(GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local this_ptr = args[2];
    local Type = Type_field:get_data(this_ptr);
    for k, v in pairs(onTimerKey_Types) do
        if Type == v then
            thread.get_hook_storage()["this_ptr"] = this_ptr;
            onTimerKey = k;
            break;
        end
    end
end, function()
    if onTimerKey ~= nil then
        local this_ptr = thread.get_hook_storage()["this_ptr"];
        if onTimerKey == "RESULT_SKIP" or isOn_method:call(this_ptr) == true then
            sdk.set_native_field(this_ptr, GUIAppOnTimerKey_type_def, "_Success", true);
        end
        onTimerKey = nil;
    end
end);