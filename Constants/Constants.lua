local _G = _G;

local sdk = _G.sdk;

local Constants = {
    pairs = _G.pairs,
    tostring = _G.tostring,
    math = _G.math,
    string = _G.string,

    sdk = sdk,
    re = _G.re,
    thread = _G.thread,
    json = _G.json,
    imgui = _G.imgui,

    ["CameraManager_type_def"] = sdk.find_type_definition("app.CameraManager"),
    ["ItemUtil_type_def"] = sdk.find_type_definition("app.ItemUtil"),
    ["QuestDirector_type_def"] = sdk.find_type_definition("app.cQuestDirector"),

    FALSE_ptr = sdk.to_ptr(false)
};

return Constants;