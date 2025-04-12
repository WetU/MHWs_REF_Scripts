local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local Constants = {
    pairs = _G.pairs,
    tostring = _G.tostring,
    math = _G.math,
    string = _G.string,

    sdk = sdk,
    re = _G.re,
    thread = thread,
    json = _G.json,
    imgui = _G.imgui,

    ["CameraManager_type_def"] = sdk.find_type_definition("app.CameraManager"),
    ["ItemUtil_type_def"] = sdk.find_type_definition("app.ItemUtil"),
    ["QuestDirector_type_def"] = nil,

    requestClose_method = nil,

    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2])
    end,

    RallusSupplyNum = nil
};

return Constants;