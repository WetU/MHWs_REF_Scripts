local Constants = _G.require("Constants/Constants");

local type = Constants.type;
local pairs = Constants.pairs;
local table = Constants.table;

local json = Constants.json;
local sdk = Constants.sdk;
local re = Constants.re;
local thread = Constants.thread;

local config = json.load_file("remember_quest_settings.json") or {view_type = 0, sort_types = {}};
if config.view_type == nil or type(config.view_type) ~= "number" then
    config.view_type = 0;
end
if config.sort_types == nil or type(config.sort_types) ~= "table" then
    config.sort_types = {};
end

local function saveConfig()
    json.dump_file("remember_quest_settings.json", config);
end

local GUI050000_type_def = sdk.find_type_definition("app.GUI050000");
local get_QuestCounterContext_method = GUI050000_type_def:get_method("get_QuestCounterContext");

local QuestCounterContext_type_def = get_QuestCounterContext_method:get_return_type();
local QuestViewType_field = QuestCounterContext_type_def:get_field("QuestViewType");
local QuestCategorySortType_field = QuestCounterContext_type_def:get_field("QuestCategorySortType");

local value_field = sdk.find_type_definition("app.GUI050000QuestListParts.SORT_TYPE"):get_field("value__");

local getObject = Constants.getObject;

sdk.hook(GUI050000_type_def:get_method("onOpen"), function(args)
    if #config.sort_types > 0 then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    if #config.sort_types > 0 then
        local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this"]);
        local sort_type_list = QuestCategorySortType_field:get_data(QuestCounterContext);
        local sort_type_list_size = sort_type_list:get_size();
        if sort_type_list_size > 0 then
            local isApplied = false;
            for i = 0, sort_type_list_size - 1 do
                local sort_type = sort_type_list:get_element(i);
                local saved_sort_type = config.sort_types[i + 1];
                if value_field:get_data(sort_type) ~= saved_sort_type then
                    sort_type:set_field("value__", saved_sort_type);
                    sort_type_list[i] = sort_type;
                    if isApplied == false then
                        isApplied = true;
                    end
                end
            end
            if isApplied == true then
                QuestCounterContext:set_field("QuestCategorySortType", sort_type_list);
            end
        end
        if QuestViewType_field:get_data(QuestCounterContext) ~= config.view_type then
            QuestCounterContext:set_field("QuestViewType", config.view_type);
        end
    end
end);

sdk.hook(GUI050000_type_def:get_method("closeQuestDetailWindow"), getObject, function()
    local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this"]);
    local sort_type_list = QuestCategorySortType_field:get_data(QuestCounterContext);
    local sort_type_list_size = sort_type_list:get_size();
    if sort_type_list_size > 0 then
        config.sort_types = {};
        for i = 0, sort_type_list_size - 1 do
            table.insert(config.sort_types, value_field:get_data(sort_type_list:get_element(i)));
        end
    end
    local QuestViewType = QuestViewType_field:get_data(QuestCounterContext);
    if QuestViewType ~= config.view_type then
        config.view_type = QuestViewType;
    end
    saveConfig();
end);

re.on_config_save(saveConfig);