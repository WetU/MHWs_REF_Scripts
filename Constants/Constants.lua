local _G = _G;

local sdk = _G.sdk;

local CameraManager_type_def = sdk.find_type_definition("app.CameraManager");
local ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil");
local GraphicsManager_type_def = sdk.find_type_definition("app.GraphicsManager");
local QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector");

local get_NowGraphicsSetting_method = GraphicsManager_type_def:get_method("get_NowGraphicsSetting");
local setGraphicsSetting_method = GraphicsManager_type_def:get_method("setGraphicsSetting(ace.cGraphicsSetting)");

local Constants = {
    os = _G.os,
    pairs = _G.pairs,
    ipairs = _G.ipairs,
    tostring = _G.tostring,
    table = _G.table,
    math = _G.math,
    string = _G.string,

    sdk = sdk,
    re = _G.re,
    thread = _G.thread,
    json = _G.json,
    imgui = _G.imgui,

    ["CameraManager_type_def"] = CameraManager_type_def,
    ["ItemUtil_type_def"] = ItemUtil_type_def,
    ["GraphicsManager_type_def"] = GraphicsManager_type_def,
    ["QuestDirector_type_def"] = QuestDirector_type_def,

    ["get_NowGraphicsSetting_method"] = get_NowGraphicsSetting_method,
    ["setGraphicsSetting_method"] = setGraphicsSetting_method,

    FALSE_ptr = sdk.to_ptr(false)
};

return Constants;