local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local Type_field = GUIAppOnTimerKey_type_def:get_field("_Type");

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    type = _G.type,
    math = _G.math,
    string = _G.string,
    table = _G.table,

    sdk = sdk,
    re = _G.re,
    thread = thread,
    json = _G.json,
    imgui = _G.imgui,
    draw = _G.draw,

    ActiveQuestData_type_def = sdk.find_type_definition("app.cActiveQuestData"),
    GUIAppOnTimerKey_type_def = GUIAppOnTimerKey_type_def,
    GUIFunc_TYPE_type_def = Type_field:get_type(),
    GUIManager_type_def = sdk.find_type_definition("app.GUIManager"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    TRUE_ptr = sdk.to_ptr(true),
    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end,
    getGUIAppKey_Type = function(obj)
        return Type_field:get_data(obj);
    end
};

Constants.init = function()
    Constants.ChatManager = sdk.get_managed_singleton("app.ChatManager");
    Constants.FacilityManager = sdk.get_managed_singleton("app.FacilityManager");
    Constants.GUIManager = sdk.get_managed_singleton("app.GUIManager");
    Constants.SaveDataManager = sdk.get_managed_singleton("app.SaveDataManager");
end

Constants.init();

return Constants;