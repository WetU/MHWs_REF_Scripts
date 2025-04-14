local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local GA_type_def = sdk.find_type_definition("app.GA");
local get_Camera_method = GA_type_def:get_method("get_Camera"); -- static
local get_Chat_method = GA_type_def:get_method("get_Chat"); -- static

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

    GA_type_def = GA_type_def,
    ActiveQuestData_type_def = sdk.find_type_definition("app.cActiveQuestData"),
    CameraManager_type_def = get_Camera_method:get_return_type(),
    ChatManager_type_def = get_Chat_method:get_return_type(),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    get_Camera_method = get_Camera_method,
    get_Chat_method = get_Chat_method,

    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end,

    RallusSupplyNum = nil
};

return Constants;