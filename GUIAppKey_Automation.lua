local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local getGUI_method = Constants.GUIManager_type_def:get_method("getGUI(app.GUIID.ID)");

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");

local GUIAppKey_type_def = GUIAppOnTimerKey_type_def:get_parent_type();
local isOn_method = GUIAppKey_type_def:get_method("isOn");
local Type_field = GUIAppKey_type_def:get_field("_Type");
local Success_field = GUIAppKey_type_def:get_field("_Success");

local GUI020025_type_def = sdk.find_type_definition("app.GUI020025");
local isEnableControllCutScene_method = GUI020025_type_def:get_method("isEnableControllCutScene");
local doSkip_method = GUI020025_type_def:get_method("doSkip");

local UI020025 = Constants.GUIID_type_def:get_field("UI020025"):get_data(nil);

local GUIFunc_TYPE_type_def = Type_field:get_type();
local AppKey_Types = {
    TITLE_START = GUIFunc_TYPE_type_def:get_field("TITLE_START"):get_data(nil),
    SPECIALTY_GUIDE_CUTSCENE_SKIP = GUIFunc_TYPE_type_def:get_field("SPECIALTY_GUIDE_CUTSCENE_SKIP"):get_data(nil)
};
local onTimerKey_Types = {
    RETURN_TIME_SKIP = GUIFunc_TYPE_type_def:get_field("RETURN_TIME_SKIP"):get_data(nil),
    RESULT_SKIP = GUIFunc_TYPE_type_def:get_field("RESULT_SKIP"):get_data(nil)
};

local appKey = nil;
sdk.hook(GUIAppKey_type_def:get_method("onUpdate(System.Single)"), function(args)
    local this_ptr = args[2];
    local Type = Type_field:get_data(this_ptr);
    for k, v in pairs(AppKey_Types) do
        if Type == v then
            thread.get_hook_storage()["this_ptr"] = this_ptr;
            appKey = k;
            break;
        end
    end
end, function()
    if appKey ~= nil then
        local this_ptr = thread.get_hook_storage()["this_ptr"];
        if appKey == "TITLE_START" then
            sdk.set_native_field(this_ptr, GUIAppKey_type_def, "_Success", true);
        elseif Success_field:get_data(this_ptr) == true then
            local GUI020025 = getGUI_method:call(Constants.GUIManager, UI020025);
            if isEnableControllCutScene_method:call(GUI020025) == true then
                doSkip_method:call(GUI020025);
            end
        end
        appKey = nil;
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