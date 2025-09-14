local Constants = _G.require("Constants.Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local table = Constants.table;

local getThisPtr = Constants.getThisPtr;
local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;
local GenericList_set_Item_method = Constants.GenericList_set_Item_method;

local checkQuestClear_method = sdk.find_type_definition("app.QuestUtil"):get_method("checkQuestClear(app.MissionIDList.ID)"); -- static

local GUI050000QuestListParts_type_def = sdk.find_type_definition("app.GUI050000QuestListParts");
local get_ViewCategory_method = GUI050000QuestListParts_type_def:get_method("get_ViewCategory");
local get_ViewQuestDataList_method = GUI050000QuestListParts_type_def:get_method("get_ViewQuestDataList");

local CATEGORY_FREE = get_ViewCategory_method:get_return_type():get_field("FREE"):get_data(nil); -- static

local get_MissionID_method = sdk.find_type_definition("app.cGUIQuestViewData"):get_method("get_MissionID");

sdk.hook(GUI050000QuestListParts_type_def:get_method("sortQuestDataList(System.Boolean)"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    if get_ViewCategory_method:call(this_ptr) == CATEGORY_FREE then
        local ViewQuestDataList = get_ViewQuestDataList_method:call(this_ptr);
        local ViewQuestDataList_size = GenericList_get_Count_method:call(ViewQuestDataList);
        if ViewQuestDataList_size > 0 then
            local cleared_quests = {};
            local uncleared_quests = {};
            for i = 0, ViewQuestDataList_size - 1 do
                local quest_data = GenericList_get_Item_method:call(ViewQuestDataList, i);
                table.insert(checkQuestClear_method:call(nil, get_MissionID_method:call(quest_data)) == true and cleared_quests or uncleared_quests, quest_data);
            end
            local unclearedCount = #uncleared_quests;
            local clearedCount = #cleared_quests;
            if unclearedCount > 0 and clearedCount > 0 then
                for i = 0, unclearedCount - 1 do
                    GenericList_set_Item_method:call(ViewQuestDataList, i, uncleared_quests[i + 1]);
                end
                for i = 0, clearedCount - 1 do
                    GenericList_set_Item_method:call(ViewQuestDataList, unclearedCount + i, cleared_quests[i + 1]);
                end
            end
        end
    end
end);