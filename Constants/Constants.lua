local _G = _G;

local sdk = _G.sdk;
local thread = _G.thread;

local addSystemLog_method = sdk.find_type_definition("app.ChatManager"):get_method("addSystemLog(System.String)");

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
    QuestDirector_type_def = sdk.find_type_definition("app.cQuestDirector"),

    FALSE_ptr = sdk.to_ptr(false),

    getObject = function(args)
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
};

function Constants:addSystemLog(msg)
    if self.ChatManager == nil then
        self.ChatManager = self.sdk.get_managed_singleton("app.ChatManager");
    end
    addSystemLog_method:call(self.ChatManager, msg);
end

return Constants;