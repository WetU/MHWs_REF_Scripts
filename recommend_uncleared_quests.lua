local Constants = _G.require("Constants.Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local imgui = Constants.imgui;
local re = Constants.re;

local config = {
	enabled = true
};

local function saveConfig()
    json.dump_file("recommend_uncleared_quests.json", config);
end

local file = json.load_file("recommend_uncleared_quests.json");
if file ~= nil then
    config = file;
else
    saveConfig();
end

local checkQuestClear_method = sdk.find_type_definition("app.QuestUtil"):get_method("checkQuestClear(app.MissionIDList.ID)"); -- static

local GUI050000QuestListParts_type_def = sdk.find_type_definition("app.GUI050000QuestListParts");
local get_ViewCategory_method = GUI050000QuestListParts_type_def:get_method("get_ViewCategory");
local get_ViewQuestDataList_method = GUI050000QuestListParts_type_def:get_method("get_ViewQuestDataList");

local ViewQuestDataList_type_def = get_ViewQuestDataList_method:get_return_type();
local get_Count_method = ViewQuestDataList_type_def:get_method("get_Count");
local get_Item_method = ViewQuestDataList_type_def:get_method("get_Item(System.Int32)");
local set_Item_method = ViewQuestDataList_type_def:get_method("set_Item(System.Int32, app.cGUIQuestViewData)");

local get_MissionID_method = get_Item_method:get_return_type():get_method("get_MissionID");

local CATEGORY_FREE = get_ViewCategory_method:get_return_type():get_field("FREE"):get_data(nil); -- static

local should_sort = false;
sdk.hook(GUI050000QuestListParts_type_def:get_method("setSortFree(System.Boolean, System.Boolean)"), function(args)
    if config.enabled == true then
        should_sort = (sdk.to_int64(args[4]) & 1) == 1;
    end
end);

sdk.hook(GUI050000QuestListParts_type_def:get_method("sortQuestDataList(System.Boolean)"), function(args)
    if config.enabled == true then
        thread.get_hook_storage()["this"] = sdk.to_managed_object(args[2]);
    end
end, function()
    local GUI050000QuestListParts = thread.get_hook_storage()["this"];
    if GUI050000QuestListParts ~= nil then
        if get_ViewCategory_method:call(GUI050000QuestListParts) == CATEGORY_FREE and should_sort == true then
            local ViewQuestDataList = get_ViewQuestDataList_method:call(GUI050000QuestListParts);
            if ViewQuestDataList ~= nil then
                local ViewQuestDataList_size = get_Count_method:call(ViewQuestDataList);
                if ViewQuestDataList_size > 0 then
                    local cleared_quests = {};
                    local uncleared_quests = {};
                    for i = 0, ViewQuestDataList_size - 1 do
                        local quest_data = get_Item_method:call(ViewQuestDataList, i);
                        if quest_data ~= nil then
                            table.insert(checkQuestClear_method:call(nil, get_MissionID_method:call(quest_data)) == true and cleared_quests or uncleared_quests, quest_data);
                        end
                    end

                    local unclearedCount = #uncleared_quests;
                    local clearedCount = #cleared_quests;
                    if unclearedCount ~= 0 and clearedCount ~= 0 then
                        for i = 0, unclearedCount - 1 do
                            set_Item_method:call(ViewQuestDataList, i, uncleared_quests[i + 1]);
                        end
                        for i = 0, clearedCount - 1 do
                            set_Item_method:call(ViewQuestDataList, unclearedCount + i, cleared_quests[i + 1]);
                        end
                    end
                end
            end
            should_sort = false;
        end
    end
end);

re.on_config_save(saveConfig);

re.on_draw_ui(function()
	if imgui.tree_node("Recommend Uncleared Quests##Recommend_Uncleared_Quests_Config") == true then
        local changed = false;
		changed, config.enabled = imgui.checkbox("Enabled##Recommend_Uncleared_Quests_Enabled", config.enabled);
        if changed == true then
            saveConfig();
        end
        imgui.tree_pop();
	end
end);