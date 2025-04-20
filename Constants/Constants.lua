local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local GA_type_def = sdk.find_type_definition("app.GA");
local get_Chat_method = GA_type_def:get_method("get_Chat"); -- static
local get_Graphics_method = GA_type_def:get_method("get_Graphics"); -- static

local Constants = {
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    math = _G.math,
    string = _G.string,
    table = _G.table,
    os = _G.os,

    sdk = sdk,
    re = _G.re,
    thread = thread,
    json = _G.json,
    imgui = _G.imgui,

    GA_type_def = GA_type_def,
    GraphicsManager_type_def = get_Graphics_method:get_return_type(),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    get_Chat_method = get_Chat_method,
    get_Graphics_method = get_Graphics_method,

    addSystemLog_method = get_Chat_method:get_return_type():get_method("addSystemLog(System.String)"),

    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
};

return Constants;