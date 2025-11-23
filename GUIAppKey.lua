local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local getGUI_method = Constants.GUIManager_type_def:get_method("getGUI(app.GUIID.ID)");

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local isOn_method = GUIAppOnTimerKey_type_def:get_method("isOn");

local GUIAppKey_type_def = GUIAppOnTimerKey_type_def:get_parent_type();
local isInputSuccess_method = GUIAppKey_type_def:get_method("isInputSuccess");
local Type_field = GUIAppKey_type_def:get_field("_Type");

local doSkip_method = sdk.find_type_definition("app.GUI020025"):get_method("doSkip");

local UI020025 = Constants.GUIID_type_def:get_field("UI020025"):get_data(nil);

local GUIFunc_TYPE_type_def = Type_field:get_type();
local skipKeyTypes = {
    TITLE_START = GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil),
    SPECIALTY_GUIDE_CUTSCENE_SKIP = GUIFunc_TYPE_type_def:get_field("SPECIALTY_GUIDE_CUTSCENE_SKIP"):get_data(nil),
    RETURN_TIME_SKIP = GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil),
    RESULT_SKIP = GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil)
};

local appKey = nil;
sdk.hook(GUIAppKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local this_ptr = args[2];
    local Type = Type_field:get_data(this_ptr);
    if Type == skipKeyTypes.TITLE_START or Type == skipKeyTypes.SPECIALTY_GUIDE_CUTSCENE_SKIP then
        thread.get_hook_storage()["this_ptr"] = this_ptr;
        appKey = Type;
    end
end, function()
    if appKey == skipKeyTypes.TITLE_START then
        appKey = nil;
        sdk.set_native_field(thread.get_hook_storage()["this_ptr"], GUIAppKey_type_def, "_Success", true);
    elseif appKey == skipKeyTypes.SPECIALTY_GUIDE_CUTSCENE_SKIP then
        appKey = nil;
        if isInputSuccess_method:call(thread.get_hook_storage()["this_ptr"]) == true then
            doSkip_method:call(getGUI_method:call(Constants.GUIManager, UI020025));
        end
    end
end);

local onTimerKey = nil;
sdk.hook(GUIAppOnTimerKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local this_ptr = args[2];
    local Type = Type_field:get_data(this_ptr);
    if Type == skipKeyTypes.RETURN_TIME_SKIP or Type == skipKeyTypes.RESULT_SKIP then
        thread.get_hook_storage()["this_ptr"] = this_ptr;
        onTimerKey = Type;
    end
end, function()
    if onTimerKey ~= nil then
        local this_ptr = thread.get_hook_storage()["this_ptr"];
        if onTimerKey == skipKeyTypes.RESULT_SKIP or (onTimerKey == skipKeyTypes.RETURN_TIME_SKIP and isOn_method:call(this_ptr) == true) then
            sdk.set_native_field(this_ptr, GUIAppOnTimerKey_type_def, "_Success", true);
        end
        onTimerKey = nil;
    end
end);