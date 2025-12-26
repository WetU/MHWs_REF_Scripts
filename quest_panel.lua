local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;
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
local set_ViewQuestDataList_method = GUI050000QuestListParts_type_def:get_method("set_ViewQuestDataList(System.Collections.Generic.List`1<app.cGUIQuestViewData>)");
local get_IsCancel_method = GUI050000QuestListParts_type_def:get_method("get_IsCancel");
local setSortDifficulty_method = GUI050000QuestListParts_type_def:get_method("setSortDifficulty(System.Boolean, System.Boolean, System.Boolean, System.Boolean, System.Boolean, System.Boolean, System.Boolean)");
-- false, false, false, false, false, false, false = High difficulty first
-- true, false, false, false, false, false, false = Low difficulty first
-- false, false, false, false, false, true, false = Most Attempts left
-- false, false, false, false, false, false, true = Least Attempts left
-- false, false, true, false, false, false, false = No password
-- false, false, false, true, false, false, false = Newly started first
-- false, false, false, false, true false, false = Open member slots
local setSortNewest_method = GUI050000QuestListParts_type_def:get_method("setSortNewest(System.Boolean)");  -- true = old first, false = new first
local PNLChangeSortType_field = GUI050000QuestListParts_type_def:get_field("_PNLChangeSortType");

local Remove_method = get_ViewQuestDataList_method:get_return_type():get_method("Remove(app.cGUIQuestViewData)");

local GUIQuestViewData_type_def = sdk.find_type_definition("app.cGUIQuestViewData");
local get_MissionID_method = GUIQuestViewData_type_def:get_method("get_MissionID");
local Session_field = GUIQuestViewData_type_def:get_field("Session");

local get_SearchResult_method = Session_field:get_type():get_method("get_SearchResult");

local SearchResultQuest_type_def = get_SearchResult_method:get_return_type();
local isAutoAccept_field = SearchResultQuest_type_def:get_field("isAutoAccept");
local memberNum_field = SearchResultQuest_type_def:get_field("memberNum");
local maxMemberNum_field = SearchResultQuest_type_def:get_field("maxMemberNum");

local set_Message_method = PNLChangeSortType_field:get_type():get_method("set_Message(System.String)");

local CATEGORY_type_def = get_ViewCategory_method:get_return_type();
local CATEGORY_FREE = CATEGORY_type_def:get_field("FREE"):get_data(nil);
local CATEGORY_DECLARATION_HISTORY = CATEGORY_type_def:get_field("DECLARATION_HISTORY"):get_data(nil);
local CATEGORY_KEEP_QUEST = CATEGORY_type_def:get_field("KEEP_QUEST"):get_data(nil);
local SortDifficulty = {
    CATEGORY_type_def:get_field("STORY"):get_data(nil),
    CATEGORY_type_def:get_field("EVENT"):get_data(nil),
    CATEGORY_type_def:get_field("ARENA"):get_data(nil),
    CATEGORY_type_def:get_field("FREE_TA"):get_data(nil),
    CATEGORY_type_def:get_field("CHALLENGE"):get_data(nil)
};
local onlineLists = {
    CATEGORY_type_def:get_field("RECRUITMENT_LOBBY"):get_data(nil),
    CATEGORY_type_def:get_field("LINK_MEMBER"):get_data(nil),
    CATEGORY_type_def:get_field("SERCH_RESCUE_SIGNAL"):get_data(nil)
};

local function sortDifficulty(obj)
    setSortDifficulty_method:call(obj, false, false, false, false, false, false, false);
    set_Message_method:call(PNLChangeSortType_field:get_data(obj), "난이도 높은 순");
end

sdk.hook(GUI050000_type_def:get_method("onOpen"), getThisPtr, function()
    local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this_ptr"]);
    if QuestViewType_field:get_data(QuestCounterContext) ~= GRID then
        sdk.set_native_field(QuestCounterContext, QuestCounterContext_type_def, "QuestViewType", GRID);
    end
end);

sdk.hook(GUI050000QuestListParts_type_def:get_method("sortQuestDataList(System.Boolean)"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    if get_IsCancel_method:call(this_ptr) ~= true then
        local CATEGORY = get_ViewCategory_method:call(this_ptr);
        if CATEGORY == CATEGORY_FREE then
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
        elseif CATEGORY == CATEGORY_DECLARATION_HISTORY then
            setSortNewest_method:call(this_ptr, false);
            set_Message_method:call(PNLChangeSortType_field:get_data(this_ptr), "새로운 순");
        elseif CATEGORY == CATEGORY_KEEP_QUEST then
            setSortDifficulty_method:call(this_ptr, false, false, false, false, false, false, true);
            set_Message_method:call(PNLChangeSortType_field:get_data(this_ptr), "수주 가능 수 적은 순");
        else
            for _, v in ipairs(onlineLists) do
                if CATEGORY == v then
                    local shouldHideItems = {};
                    local ViewQuestDataList = get_ViewQuestDataList_method:call(this_ptr);
                    local ViewQuestDataList_size = GenericList_get_Count_method:call(ViewQuestDataList);
                    if ViewQuestDataList_size > 0 then
                        for i = 0, ViewQuestDataList_size - 1 do
                            local quest_data = GenericList_get_Item_method:call(ViewQuestDataList, i);
                            local SearchResultQuest = get_SearchResult_method:call(Session_field:get_data(quest_data));
                            if isAutoAccept_field:get_data(SearchResultQuest) ~= true or memberNum_field:get_data(SearchResultQuest) == maxMemberNum_field:get_data(SearchResultQuest) then
                                table.insert(shouldHideItems, quest_data);
                            end
                        end
                        if #shouldHideItems > 0 then
                            for _, v in ipairs(shouldHideItems) do
                                Remove_method:call(ViewQuestDataList, v);
                            end
                            set_ViewQuestDataList_method:call(this_ptr, ViewQuestDataList);
                        end
                        setSortDifficulty_method:call(this_ptr, false, false, false, true, false, false, false);
                        set_Message_method:call(PNLChangeSortType_field:get_data(this_ptr), "퀘스트 시작 최신 순");
                    end
                    return;
                end
            end
            for _, v in ipairs(SortDifficulty) do
                if CATEGORY == v then
                    sortDifficulty(this_ptr);
                    break;
                end
            end
        end
    end
end);