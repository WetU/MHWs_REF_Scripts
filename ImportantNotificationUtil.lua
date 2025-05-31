local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

local GUIManager_type_def = sdk.find_type_definition("app.GUIManager");
local get_IsJustTimingShortcutWaiting_method = GUIManager_type_def:get_method("get_IsJustTimingShortcutWaiting");
local getGUI_method = GUIManager_type_def:get_method("getGUI(app.GUIID.ID)");

local UI020100 = sdk.find_type_definition("app.GUIID.ID"):get_field("UI020100"):get_data(nil);

local GUI020100_type_def = sdk.find_type_definition("app.GUI020100");
local get_FixPanelType_method = GUI020100_type_def:get_method("get_FixPanelType");
local getHunterCharacter_method = GUI020100_type_def:get_method("getHunterCharacter"); -- static

local FIX_PANEL_TYPE_type_def = get_FixPanelType_method:get_return_type();
local FIX_PANEL_TYPE = {
    IMPORTANT_LINE1 = FIX_PANEL_TYPE_type_def:get_field("IMPORTANT_LINE1"):get_data(nil),
    IMPORTANT_LINE2 = FIX_PANEL_TYPE_type_def:get_field("IMPORTANT_LINE2"):get_data(nil)
};

local offHunterContinueFlag_method = Constants.HunterCharacter_type_def:get_method("offHunterContinueFlag(app.HunterDef.CONTINUE_FLAG)");

local DISABLE_OPEN_MAP = sdk.find_type_definition("app.HunterDef.CONTINUE_FLAG"):get_field("DISABLE_OPEN_MAP"):get_data(nil);

local config = json.load_file("ImportantNotificationUtil.json") or {enabled = true};
if config.enabled == nil then
    config.enabled = true;
end

local function saveConfig()
    json.dump_file("ImportantNotificationUtil.json", config);
end

local GUI020100 = nil;
local HunterCharacter = nil;
sdk.hook(GUIManager_type_def:get_method("updatePlCommandMask"), function(args)
    if config.enabled == true then
        if Constants.GUIManager == nil then
            Constants.GUIManager = sdk.to_managed_object(args[2]);
        end
    else
        if GUI020100 ~= nil then
            GUI020100 = nil;
        end
        if HunterCharacter ~= nil then
            HunterCharacter = nil;
        end
    end
end, function()
    if config.enabled == true and get_IsJustTimingShortcutWaiting_method:call(Constants.GUIManager) == true then
        if GUI020100 == nil then
            GUI020100 = getGUI_method:call(Constants.GUIManager, UI020100);
        end
        local FixPanelType = get_FixPanelType_method:call(GUI020100);
        if FixPanelType == FIX_PANEL_TYPE.IMPORTANT_LINE1 or FixPanelType == FIX_PANEL_TYPE.IMPORTANT_LINE2 then
            if HunterCharacter == nil then
                HunterCharacter = getHunterCharacter_method:call(nil);
            end
            offHunterContinueFlag_method:call(HunterCharacter, DISABLE_OPEN_MAP);
        end
    end
end);

re.on_draw_ui(function()
    if imgui.tree_node("Important Notification Util") == true then
		local changed = false;
		changed, config.enabled = imgui.checkbox("Enable", config.enabled);
        if changed == true then
            saveConfig();
        end
		imgui.tree_pop();
	end
end);

re.on_config_save(saveConfig);