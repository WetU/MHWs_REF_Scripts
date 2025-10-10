local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local GUI050000_type_def = sdk.find_type_definition("app.GUI050000");
local get_QuestCounterContext_method = GUI050000_type_def:get_method("get_QuestCounterContext");

local QuestCounterContext_type_def = get_QuestCounterContext_method:get_return_type();
local QuestViewType_field = QuestCounterContext_type_def:get_field("QuestViewType");

local GRID = QuestViewType_field:get_type():get_field("GRID"):get_data(nil);

local GUI050000QuestListParts_type_def = sdk.find_type_definition("app.GUI050000QuestListParts");
local get_ViewCategory_method = GUI050000QuestListParts_type_def:get_method("get_ViewCategory");
local setSortDifficulty_method = GUI050000QuestListParts_type_def:get_method("setSortDifficulty(System.Boolean, System.Boolean)");
local setSortNewest_method = GUI050000QuestListParts_type_def:get_method("setSortNewest(System.Boolean)");
local PNLChangeSortType_field = GUI050000QuestListParts_type_def:get_field("_PNLChangeSortType");

local set_Message_method = PNLChangeSortType_field:get_type():get_method("set_Message(System.String)");

local CATEGORY_type_def = get_ViewCategory_method:get_return_type();
local SortNewest = {
    CATEGORY_type_def:get_field("DECLARATION_HISTORY"):get_data(nil),
    CATEGORY_type_def:get_field("KEEP_QUEST"):get_data(nil)
};
local SortDifficulty = {
    CATEGORY_type_def:get_field("STORY"):get_data(nil),
    CATEGORY_type_def:get_field("FREE"):get_data(nil),
    CATEGORY_type_def:get_field("EVENT"):get_data(nil),
    CATEGORY_type_def:get_field("ARENA"):get_data(nil),
    CATEGORY_type_def:get_field("FREE_TA"):get_data(nil),
    CATEGORY_type_def:get_field("CHALLENGE"):get_data(nil),
    CATEGORY_type_def:get_field("RECRUITMENT_LOBBY"):get_data(nil),
    CATEGORY_type_def:get_field("LINK_MEMBER"):get_data(nil),
    CATEGORY_type_def:get_field("SERCH_RESCUE_SIGNAL"):get_data(nil)
};

sdk.hook(GUI050000QuestListParts_type_def:get_method("sortQuestDataList(System.Boolean)"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    local curCategory = get_ViewCategory_method:call(this_ptr);
    for _, v in pairs(SortNewest) do
        if v == curCategory then
            setSortNewest_method:call(this_ptr, false);
            set_Message_method:call(PNLChangeSortType_field:get_data(this_ptr), "새로운 순");
            return;
        end
    end
    for _, v in pairs(SortDifficulty) do
        if v == curCategory then
            setSortDifficulty_method:call(this_ptr, false, false);
            set_Message_method:call(PNLChangeSortType_field:get_data(this_ptr), "난이도 높은 순");
            return;
        end
    end
end);

sdk.hook(GUI050000_type_def:get_method("onOpen"), getThisPtr, function()
    local QuestCounterContext = get_QuestCounterContext_method:call(thread.get_hook_storage()["this_ptr"]);
    if QuestViewType_field:get_data(QuestCounterContext) ~= GRID then
        sdk.set_native_field(QuestCounterContext, QuestCounterContext_type_def, "QuestViewType", GRID);
    end
end);