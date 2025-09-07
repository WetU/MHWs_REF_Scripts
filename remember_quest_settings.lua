local Constants = _G.require("Constants/Constants");

local type = Constants.type;
local table = Constants.table;

local json = Constants.json;
local sdk = Constants.sdk;
local re = Constants.re;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local config = json.load_file("remember_quest_settings.json") or {view_type = 0, sort_types = {-1, -1, 0, 4, 0, 0, 4, 2, -1, 2, 2, 2, 2}};
if config.view_type == nil or type(config.view_type) ~= "number" then
    config.view_type = 0;
end
if config.sort_types == nil or type(config.sort_types) ~= "table" then
    config.sort_types = {-1, -1, 0, 4, 0, 0, 4, 2, -1, 2, 2, 2, 2};
end

local function saveConfig()
    json.dump_file("remember_quest_settings.json", config);
end

local GUI050000_type_def = sdk.find_type_definition("app.GUI050000");
local get_QuestCounterContext_method = GUI050000_type_def:get_method("get_QuestCounterContext");

local QuestCounterContext_type_def = get_QuestCounterContext_method:get_return_type();
local QuestViewType_field = QuestCounterContext_type_def:get_field("QuestViewType");
local QuestCategorySortType_field = QuestCounterContext_type_def:get_field("QuestCategorySortType");

local SORT_TYPE_type_def = sdk.find_type_definition("app.GUI050000QuestListParts.SORT_TYPE");
local value_field = SORT_TYPE_type_def:get_field("value__");

sdk.hook(GUI050000_type_def:get_method("onOpen"), getThisPtr, function()
    local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this_ptr"]);
    local sort_type_list = QuestCategorySortType_field:get_data(QuestCounterContext);
    for i = 0, sort_type_list:get_size() - 1 do
        local sort_type = sort_type_list:get_element(i);
        local saved_sort_type = config.sort_types[i + 1];
        if value_field:get_data(sort_type) ~= saved_sort_type then
            sdk.set_native_field(sort_type, SORT_TYPE_type_def, "value__", saved_sort_type);
        end
    end
    if QuestViewType_field:get_data(QuestCounterContext) ~= config.view_type then
        sdk.set_native_field(QuestCounterContext, QuestCounterContext_type_def, "QuestViewType", config.view_type);
    end
end);

sdk.hook(GUI050000_type_def:get_method("closeQuestDetailWindow"), getThisPtr, function()
    local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this_ptr"]);
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