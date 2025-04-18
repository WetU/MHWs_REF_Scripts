local Constants = _G.require("Constants/Constants");
local json = Constants.json;
local sdk = Constants.sdk;
local re = Constants.re;
local imgui = Constants.imgui;
local thread = Constants.thread;

local GUI050000_type_def = sdk.find_type_definition("app.GUI050000");
local get_QuestCounterContext_method = GUI050000_type_def:get_method("get_QuestCounterContext");

local QuestCounterContext_type_def = get_QuestCounterContext_method:get_return_type();
local QuestViewType_field = QuestCounterContext_type_def:get_field("QuestViewType");
local QuestCategorySortType_field = QuestCounterContext_type_def:get_field("QuestCategorySortType");

local SORT_TYPE_type_def = sdk.find_type_definition("app.GUI050000QuestListParts.SORT_TYPE");
local value_field = SORT_TYPE_type_def:get_field("value__");
local NONE = SORT_TYPE_type_def:get_field("NONE"):get_data(nil); --static
local NEWEST = SORT_TYPE_type_def:get_field("NEWEST"):get_data(nil); -- static
local HARD = SORT_TYPE_type_def:get_field("HARD"):get_data(nil); -- static
local RECOMMEND = SORT_TYPE_type_def:get_field("RECOMMEND"):get_data(nil); -- static

local config = {
	enabled = true,
    view_type = 0,
    sort_types = {NONE, NONE, NEWEST, RECOMMEND, NEWEST, NEWEST, RECOMMEND, HARD, NONE, HARD, HARD, HARD, HARD}
};

local function saveConfig()
    json.dump_file("remember_quest_settings.json", config);
end

if json ~= nil then
    local file = json.load_file("remember_quest_settings.json");
    if file ~= nil then
        for key, value in Constants.pairs(config) do
            if file[key] == nil then
                file[key] = value;
            end
        end
		config = file;
    end
    saveConfig();
end

local function getObject(args)
    if config.enabled == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end

sdk.hook(GUI050000_type_def:get_method("onOpen"), getObject, function()
    local GUI050000 = thread.get_hook_storage()["this"];
    if GUI050000 ~= nil then
        local QuestCounterContext = get_QuestCounterContext_method:call(GUI050000);
        if QuestCounterContext ~= nil then
            local sort_type_list = QuestCategorySortType_field:get_data(QuestCounterContext);
            if sort_type_list ~= nil then
                local sort_type_list_size = sort_type_list:get_size();
                if sort_type_list_size > 0 then
                    for i = 0, sort_type_list_size - 1 do
                        local sort_type = sort_type_list:get_element(i);
                        if value_field:get_data(sort_type) ~= config.sort_types[i + 1] then
                            sort_type:set_field("value__", config.sort_types[i + 1]);
                            sort_type_list[i] = sort_type;
                        end
                    end
                end
            end
            if QuestViewType_field:get_data(QuestCounterContext) ~= config.view_type then
                QuestCounterContext:set_field("QuestViewType", config.view_type);
            end
        end
    end
end);

sdk.hook(GUI050000_type_def:get_method("closeQuestDetailWindow"), getObject, function()
    local GUI050000 = thread.get_hook_storage()["this"];
    if GUI050000 ~= nil then
        local QuestCounterContext = get_QuestCounterContext_method:call(GUI050000);
        if QuestCounterContext ~= nil then
            local requireSave = false;
            local sort_type_list = QuestCategorySortType_field:get_data(QuestCounterContext);
            if sort_type_list ~= nil then
                local sort_type_list_size = sort_type_list:get_size();
                if sort_type_list_size > 0 then
                    config.sort_types = {};
                    for i = 0, sort_type_list_size - 1 do
                        Constants.table.insert(config.sort_types, value_field:get_data(sort_type_list:get_element(i)));
                    end
                    if requireSave ~= true then
                        requireSave = true;
                    end
                end
            end

            local QuestViewType = QuestViewType_field:get_data(QuestCounterContext);
            if QuestViewType ~= nil and QuestViewType ~= config.view_type then
                config.view_type = QuestViewType;
                if requireSave ~= true then
                    requireSave = true;
                end
            end
            if requireSave == true then
                saveConfig();
            end
        end
    end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
	if imgui.tree_node("Remember Quest Settings##remember_quest_settings_Config") == true then
        local changed = false;
		changed, config.enabled = imgui.checkbox("Enabled##remember_quest_settings_Enabled", config.enabled);
        if changed == true then
            saveConfig();
        end
        imgui.tree_pop();
	end
end);