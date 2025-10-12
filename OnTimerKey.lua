local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local GUIAppOnTimerKey_type_def = Constants.GUIAppOnTimerKey_type_def;
local isOn_method = GUIAppOnTimerKey_type_def:get_method("isOn");
local Type_field = Constants.GUIAppKey_Type_field;

local GUIFunc_TYPE_type_def = Constants.GUIFunc_TYPE_type_def;
local GUIFunc_TYPE = {
    RETURN_TIME_SKIP = GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil),
    RESULT_SKIP = GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil),
};

local TYPE_key = nil;
sdk.hook(GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local this_ptr = args[2];
    local Type = Type_field:get_data(this_ptr);
    for k, v in pairs(GUIFunc_TYPE) do
        if v == Type then
            thread.get_hook_storage()["this_ptr"] = this_ptr;
            TYPE_key = k;
            break;
        end
    end
end, function()
    if TYPE_key ~= nil then
        local this_ptr = thread.get_hook_storage()["this_ptr"];
        if TYPE_key == "RESULT_SKIP" or (TYPE_key == "RETURN_TIME_SKIP" and isOn_method:call(this_ptr) == true) then
            sdk.set_native_field(this_ptr, GUIAppOnTimerKey_type_def, "_Success", true);
        end
        TYPE_key = nil;
    end
end);