local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local addSystemLog_method = sdk.find_type_definition("app.ChatManager"):get_method("addSystemLog(System.String)");

local PorterUtil_type_def = sdk.find_type_definition("app.PorterUtil");
local getCurrentStageMasterPlayer_method = PorterUtil_type_def:get_method("getCurrentStageMasterPlayer"); -- static
local STAGE_type_def = getCurrentStageMasterPlayer_method:get_return_type();

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

    CameraManager_type_def = sdk.find_type_definition("app.CameraManager"),
    GraphicsManager_type_def = sdk.find_type_definition("app.GraphicsManager"),
    GUIManager_type_def = sdk.find_type_definition("app.GUIManager"),
    HunterCharacter_type_def = sdk.find_type_definition("app.HunterCharacter"),
    ItemUtil_type_def = sdk.find_type_definition("app.ItemUtil"),
    PorterUtil_type_def = PorterUtil_type_def,
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    Stages = {
        STAGE_type_def:get_field("ST101"):get_data(nil),
        STAGE_type_def:get_field("ST102"):get_data(nil),
        STAGE_type_def:get_field("ST103"):get_data(nil),
        STAGE_type_def:get_field("ST104"):get_data(nil),
        STAGE_type_def:get_field("ST105"):get_data(nil),
        STAGE_type_def:get_field("ST401"):get_data(nil),
        STAGE_type_def:get_field("ST403"):get_data(nil),
        STAGE_type_def:get_field("ST503"):get_data(nil),
        INVALID = STAGE_type_def:get_field("INVALID"):get_data(nil)
    },
    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
};

function Constants:addSystemLog(msg)
    if self.ChatManager == nil then
        self.ChatManager = sdk.get_managed_singleton("app.ChatManager");
    end
    addSystemLog_method:call(self.ChatManager, msg);
end

function Constants:getCurrentStageMasterPlayer()
    return self.curStage or getCurrentStageMasterPlayer_method:call(nil);
end

return Constants;