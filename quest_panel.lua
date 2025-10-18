local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;
local table = Constants.table;

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;
local GenericList_set_Item_method = Constants.GenericList_set_Item_method;

local checkQuestClear_method = sdk.find_type_definition("app.QuestUtil"):get_method("checkQuestClear(app.MissionIDList.ID)"); -- static

local GUI050000_type_def = sdk.find_type_definition("app.GUI050000");
local get_QuestCounterContext_method = GUI050000_type_def:get_method("get_QuestCounterContext");

local QuestCounterContext_type_def = get_QuestCounterContext_method:get_return_type();
local QuestViewType_field = QuestCounterContext_type_def:get_field("QuestViewType");

local GRID = QuestViewType_field:get_type():get_field("GRID"):get_data(nil);

local GUI050000QuestListParts_type_def = sdk.find_type_definition("app.GUI050000QuestListParts");
local get_ViewCategory_method = GUI050000QuestListParts_type_def:get_method("get_ViewCategory");
local get_ViewQuestDataList_method = GUI050000QuestListParts_type_def:get_method("get_ViewQuestDataList");
local setSortDifficulty_method = GUI050000QuestListParts_type_def:get_method("setSortDifficulty(System.Boolean, System.Boolean)");
local setSortNewest_method = GUI050000QuestListParts_type_def:get_method("setSortNewest(System.Boolean)");
local PNLChangeSortType_field = GUI050000QuestListParts_type_def:get_field("_PNLChangeSortType");

local set_Message_method = PNLChangeSortType_field:get_type():get_method("set_Message(System.String)");

local get_MissionID_method = sdk.find_type_definition("app.cGUIQuestViewData"):get_method("get_MissionID");

local CATEGORY_type_def = get_ViewCategory_method:get_return_type();
local CATEGORY_FREE = CATEGORY_type_def:get_field("FREE"):get_data(nil);
local SortNewest = {
    CATEGORY_type_def:get_field("DECLARATION_HISTORY"):get_data(nil),
    CATEGORY_type_def:get_field("KEEP_QUEST"):get_data(nil)
};
local SortDifficulty = {
    CATEGORY_type_def:get_field("STORY"):get_data(nil),
    CATEGORY_type_def:get_field("EVENT"):get_data(nil),
    CATEGORY_type_def:get_field("ARENA"):get_data(nil),
    CATEGORY_type_def:get_field("FREE_TA"):get_data(nil),
    CATEGORY_type_def:get_field("CHALLENGE"):get_data(nil),
    CATEGORY_type_def:get_field("RECRUITMENT_LOBBY"):get_data(nil),
    CATEGORY_type_def:get_field("LINK_MEMBER"):get_data(nil),
    CATEGORY_type_def:get_field("SERCH_RESCUE_SIGNAL"):get_data(nil)
};

local function sortDifficulty(obj)
    setSortDifficulty_method:call(obj, false, false);
    set_Message_method:call(PNLChangeSortType_field:get_data(obj), "난이도 높은 순");
end

sdk.hook(GUI050000QuestListParts_type_def:get_method("sortQuestDataList(System.Boolean)"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    local curCategory = get_ViewCategory_method:call(this_ptr);
    if curCategory == CATEGORY_FREE then
        sortDifficulty(this_ptr);
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
    else
        for _, v in pairs(SortNewest) do
            if v == curCategory then
                setSortNewest_method:call(this_ptr, false);
                set_Message_method:call(PNLChangeSortType_field:get_data(this_ptr), "새로운 순");
                return;
            end
        end
        for _, v in pairs(SortDifficulty) do
            if v == curCategory then
                sortDifficulty(this_ptr);
                return;
            end
        end
    end
end);

sdk.hook(GUI050000_type_def:get_method("onOpen"), getThisPtr, function()
    local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this_ptr"]);
    if QuestViewType_field:get_data(QuestCounterContext) ~= GRID then
        sdk.set_native_field(QuestCounterContext, QuestCounterContext_type_def, "QuestViewType", GRID);
    end
end);