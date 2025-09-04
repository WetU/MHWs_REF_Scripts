local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;

local addSystemLog_method = Constants.addSystemLog_method;

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local fillPouchItems_method = ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = sdk.find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local isArenaQuest_method = Constants.ActiveQuestData_type_def:get_method("isArenaQuest");

local getHunterCharacter_method = sdk.find_type_definition("app.GUIHudBase"):get_method("getHunterCharacter") -- static

local get_IsInAllTent_method = getHunterCharacter_method:get_return_type():get_method("get_IsInAllTent");

local mySet = 0;

local isSelfCall = false;

local function restockItems()
    if isValidData_method:call(nil, mySet) == true then
        isSelfCall = true;
        applyMySetToPouch_method:call(nil, mySet);
        addSystemLog_method:call(Constants.ChatManager, "아이템 세트가 적용되었습니다.");
    else
        fillPouchItems_method:call(nil);
        addSystemLog_method:call(Constants.ChatManager, "아이템이 보충되었습니다.");
    end
    fillShellPouchItems_method:call(nil);
end

local function getAppliedSet(setVar)
    local appliedSet = sdk.to_int64(setVar) & 0xFFFFFFFF;
    if mySet ~= appliedSet then
        mySet = appliedSet;
    end
end

sdk.hook(sdk.find_type_definition("app.Gm170_002"):get_method("buttonPushEvent"), nil, restockItems);
sdk.hook(sdk.find_type_definition("app.mcHunterTentAction"):get_method("updateBegin"), nil, restockItems);
sdk.hook(Constants.QuestDirector_type_def:get_method("acceptQuest(app.cActiveQuestData, app.cQuestAcceptArg, System.Boolean, System.Boolean)"), function(args)
    if isArenaQuest_method:call(args[3]) == false and get_IsInAllTent_method:call(getHunterCharacter_method:call(nil)) == false then
        restockItems();
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI030210"):get_method("onOpen"), nil, function()
    if isValidData_method:call(nil, mySet) == true then
        isSelfCall = true;
        applyMySetToPouch_method:call(nil, mySet);
    else
        fillPouchItems_method:call(nil);
    end
    fillShellPouchItems_method:call(nil);
end);

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