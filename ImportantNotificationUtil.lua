local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

local GUIManager_type_def = sdk.find_type_definition("app.GUIManager");
local get_GUI020100Accessor_method = GUIManager_type_def:get_method("get_GUI020100Accessor");
local get_IsJustTimingShortcutWaiting_method = GUIManager_type_def:get_method("get_IsJustTimingShortcutWaiting");

local GUIs_field = get_GUI020100Accessor_method:get_return_type():get_parent_type():get_field("GUIs");

local get_FixPanelType_method = sdk.find_type_definition("app.GUI020100"):get_method("get_FixPanelType");

local get_Pl_method = Constants.GA_type_def:get_method("get_Pl"); -- static

local getMasterPlayer_method = get_Pl_method:get_return_type():get_method("getMasterPlayer");
local get_Character_method = getMasterPlayer_method:get_return_type():get_method("get_Character");
local HunterContinueFlag_field = get_Character_method:get_return_type():get_field("_HunterContinueFlag");
local off_method = HunterContinueFlag_field:get_type():get_method("off(System.UInt32)");

local FIX_PANEL_TYPE_type_def = get_FixPanelType_method:get_return_type();
local FIX_PANEL_TYPE = {
    IMPORTANT_LINE1 = FIX_PANEL_TYPE_type_def:get_field("IMPORTANT_LINE1"):get_data(nil),
    IMPORTANT_LINE2 = FIX_PANEL_TYPE_type_def:get_field("IMPORTANT_LINE2"):get_data(nil)
};

local config = json.load_file("ImportantNotificationUtil.json") or {enabled = true};

local function saveConfig()
    json.dump_file("ImportantNotificationUtil.json", config);
end

sdk.hook(GUIManager_type_def:get_method("updatePlCommandMask"), function(args)
    if config.enabled == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    local GUIManager = thread.get_hook_storage()["this"];
    if GUIManager ~= nil and get_IsJustTimingShortcutWaiting_method:call(GUIManager) == true then
        local GUI020100Accessor = get_GUI020100Accessor_method:call(GUIManager);
        if GUI020100Accessor ~= nil then
            local GUIs = GUIs_field:get_data(GUI020100Accessor);
            if GUIs ~= nil and GUIs:get_size() > 0 then
                local GUI020100 = GUIs:get_element(0);
                if GUI020100 ~= nil then
                    local FixPanelType = get_FixPanelType_method:call(GUI020100);
                    if FixPanelType ~= nil and (FixPanelType == FIX_PANEL_TYPE.IMPORTANT_LINE1 or FixPanelType == FIX_PANEL_TYPE.IMPORTANT_LINE2) then
                        off_method:call(HunterContinueFlag_field:get_data(get_Character_method:call(getMasterPlayer_method:call(get_Pl_method:call(nil)))), 200);
                    end
                end
            end
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