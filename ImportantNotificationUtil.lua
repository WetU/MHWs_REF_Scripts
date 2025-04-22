local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

local get_GUI020100Accessor_method = Constants.GUIManager_type_def:get_method("get_GUI020100Accessor");
local get_IsJustTimingShortcutWaiting_method = Constants.GUIManager_type_def:get_method("get_IsJustTimingShortcutWaiting");

local GUIs_field = get_GUI020100Accessor_method:get_return_type():get_parent_type():get_field("GUIs");

local get_FixPanelType_method = sdk.find_type_definition("app.GUI020100"):get_method("get_FixPanelType");

local getMasterPlayer_method = nil;
local get_Character_method = nil;
local HunterContinueFlag_field = Constants.HunterCharacter_type_def:get_field("_HunterContinueFlag");
local off_method = nil;

local FIX_PANEL_TYPE_type_def = get_FixPanelType_method:get_return_type();
local FIX_PANEL_TYPE = {
    IMPORTANT_LINE1 = FIX_PANEL_TYPE_type_def:get_field("IMPORTANT_LINE1"):get_data(nil),
    IMPORTANT_LINE2 = FIX_PANEL_TYPE_type_def:get_field("IMPORTANT_LINE2"):get_data(nil)
};

local config = json.load_file("ImportantNotificationUtil.json") or {enabled = true};

local function saveConfig()
    json.dump_file("ImportantNotificationUtil.json", config);
end

local GUI020100 = nil;
sdk.hook(Constants.GUIManager_type_def:get_method("updatePlCommandMask"), function(args)
    if config.enabled == true then
        if Constants.GUIManager == nil then
            Constants.GUIManager = sdk.to_managed_object(args[2]);
        end
    else
        if GUI020100 ~= nil then
            GUI020100 = nil;
        end
    end
end, function()
    if config.enabled == true and get_IsJustTimingShortcutWaiting_method:call(Constants.GUIManager) == true then
        if GUI020100 == nil then
            GUI020100 = GUIs_field:get_data(get_GUI020100Accessor_method:call(Constants.GUIManager)):get_element(0);
        end
        local FixPanelType = get_FixPanelType_method:call(GUI020100);
        if FixPanelType == FIX_PANEL_TYPE.IMPORTANT_LINE1 or FixPanelType == FIX_PANEL_TYPE.IMPORTANT_LINE2 then
            if Constants.PlayerManager == nil then
                Constants.PlayerManager = sdk.get_managed_singleton("app.PlayerManager");
            end
            if getMasterPlayer_method == nil then
                getMasterPlayer_method = Constants.PlayerManager.getMasterPlayer;
            end
            local MasterPlayer = getMasterPlayer_method:call(Constants.PlayerManager);
            if MasterPlayer ~= nil then
                if get_Character_method == nil then
                    get_Character_method = MasterPlayer.get_Character;
                end
                local Character = get_Character_method:call(MasterPlayer);
                if Character ~= nil then
                    local HunterContinueFlag = HunterContinueFlag_field:get_data(Character);
                    if HunterContinueFlag ~= nil then
                        if off_method == nil then
                            off_method = HunterContinueFlag["off(System.UInt32)"];
                        end
                        off_method:call(HunterContinueFlag, 200);
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