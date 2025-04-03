local _G = _G;

local pairs = _G.pairs;
local ipairs = _G.ipairs;
local tostring = _G.tostring;
local type = _G.type;
local table = _G.table;
local math = _G.math;
local string = _G.string;

local sdk = _G.sdk;
local re = _G.re;
local thread = _G.thread;
local json = _G.json;
local imgui = _G.imgui;

local CameraManager_type_def = sdk.find_type_definition("app.CameraManager");
local ChatManager_type_def = sdk.find_type_definition("app.ChatManager");
local ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil");
local GraphicsManager_type_def = sdk.find_type_definition("app.GraphicsManager");
local QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector");

local get_NowGraphicsSetting_method = GraphicsManager_type_def:get_method("get_NowGraphicsSetting");
local setGraphicsSetting_method = GraphicsManager_type_def:get_method("setGraphicsSetting(ace.cGraphicsSetting)");

local Constants = {
    pairs = pairs,
    ipairs = ipairs,
    tostring = tostring,
    type = type,
    table = table,
    math = math,
    string = string,

    sdk = sdk,
    re = re,
    thread = thread,
    json = json,
    imgui = imgui,

    ["CameraManager_type_def"] = CameraManager_type_def,
    ["ChatManager_type_def"] = ChatManager_type_def,
    ["ItemUtil_type_def"] = ItemUtil_type_def,
    ["GraphicsManager_type_def"] = GraphicsManager_type_def,
    ["QuestDirector_type_def"] = QuestDirector_type_def,

    ["get_NowGraphicsSetting_method"] = get_NowGraphicsSetting_method,
    ["setGraphicsSetting_method"] = setGraphicsSetting_method
};

return Constants;