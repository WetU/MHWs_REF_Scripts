local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local GUIAppKey_type_def = sdk.find_type_definition("app.cGUIAppKey");
local Key_Type_field = GUIAppKey_type_def:get_field("_Type");

local GUIAppOnTimerKey_type_def = sdk.find_type_definition("app.cGUIAppOnTimerKey");
local OnTimerKey_Type_field = GUIAppOnTimerKey_type_def:get_field("_Type");

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
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
    GUIAppKey_type_def = GUIAppKey_type_def,
    GUIAppOnTimerKey_type_def = GUIAppOnTimerKey_type_def,
    GUIFunc_TYPE_type_def = Key_Type_field:get_type(),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    TRUE_ptr = sdk.to_ptr(true),
    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end,
    getKey_Type = function(obj)
        return Key_Type_field:get_data(obj);
    end,
    getOnTimerKey_Type = function(obj)
        return OnTimerKey_Type_field:get_data(obj);
    end
};

return Constants;