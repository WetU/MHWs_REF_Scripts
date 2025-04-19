local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local fillPouchItems_method = Constants.ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = Constants.ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = sdk.find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local isArenaQuest_method = nil;

local mySet = 0;

local isSelfCall = false;

local function restockItems()
    local ChatManager = Constants.get_Chat_method:call(nil);

    if isValidData_method:call(nil, mySet) == true then
        isSelfCall = true;
        applyMySetToPouch_method:call(nil, mySet);
        Constants.addSystemLog_method:call(ChatManager, "아이템 세트가 적용되었습니다.");
    else
        fillPouchItems_method:call(nil);
        Constants.addSystemLog_method:call(ChatManager, "아이템이 보충되었습니다.");
    end

    fillShellPouchItems_method:call(nil);
end

local function getAppliedSet(setVar)
    local appliedSet = sdk.to_int64(setVar) & 0xFFFFFFFF;
    if mySet ~= appliedSet then
        mySet = appliedSet;
    end
end

sdk.hook(sdk.find_type_definition("app.mcHunterTentAction"):get_method("updateBegin"), nil, restockItems);
sdk.hook(Constants.QuestDirector_type_def:get_method("acceptQuest(app.cActiveQuestData, app.cQuestAcceptArg, System.Boolean, System.Boolean)"), function(args)
    local ActiveQuestData = sdk.to_managed_object(args[3]);
    if isArenaQuest_method == nil then
        isArenaQuest_method = ActiveQuestData.isArenaQuest;
    end
    if isArenaQuest_method:call(ActiveQuestData) == false then
        restockItems();
    end
end);
sdk.hook(sdk.find_type_definition("app.GUI030210"):get_method("onClose"), nil, restockItems);
sdk.hook(applyMySetToPouch_method, function(args)
    if isSelfCall == true then
        isSelfCall = false;
    else
        getAppliedSet(args[2]);
    end
end);
sdk.hook(sdk.find_type_definition("app.GUI030203"):get_method("applyMySet(System.Int32)"), function(args)
    getAppliedSet(args[3]);
end);