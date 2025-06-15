local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

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

    ActiveQuestData_type_def = sdk.find_type_definition("app.cActiveQuestData"),
    GUIFunc_TYPE_type_def = sdk.find_type_definition("app.GUIFunc.TYPE"),
    HunterCharacter_type_def = sdk.find_type_definition("app.HunterCharacter"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    TRUE_ptr = sdk.to_ptr(true),
    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
};

return Constants;