local Constants = _G.require("Constants/Constants");

local string = Constants.string;
local tostring = Constants.tostring;

local sdk = Constants.sdk;

local getThisPtr = Constants.getThisPtr;

local addSystemLog_method = Constants.addSystemLog_method;

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local fillPouchItems_method = ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = sdk.find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local isArenaQuest_method = Constants.ActiveQuestData_type_def:get_method("isArenaQuest");

local getHunterCharacter_method = sdk.find_type_definition("app.GUIHudBase"):get_method("getHunterCharacter") -- static

local get_IsInAllTent_method = Constants.HunterCharacter_type_def:get_method("get_IsInAllTent");

local GUI090000_type_def = sdk.find_type_definition("app.GUI090000");
local get__MainText_method = GUI090000_type_def:get_method("get__MainText");

local get_Message_method = get__MainText_method:get_return_type():get_method("get_Message");

local mySet = 0;

local function restockItems()
    if isValidData_method:call(nil, mySet) == true then
        applyMySetToPouch_method:call(nil, mySet);
        addSystemLog_method:call(Constants.ChatManager, "아이템 세트가 적용되었습니다: [" .. tostring(mySet) .. "]");
    else
        fillPouchItems_method:call(nil);
        addSystemLog_method:call(Constants.ChatManager, "아이템이 보충되었습니다.");
    end
    fillShellPouchItems_method:call(nil);
end

sdk.hook(GUI090000_type_def:get_method("onClose"), getThisPtr, function()
    if string.match(get_Message_method:call(get__MainText_method:call(thread.get_hook_storage()["this_ptr"])), "캠프 메뉴") ~= nil then
        restockItems();
    end
end);

sdk.hook(Constants.QuestDirector_type_def:get_method("acceptQuest(app.cActiveQuestData, app.cQuestAcceptArg, System.Boolean, System.Boolean)"), function(args)
    if isArenaQuest_method:call(args[3]) == false and get_IsInAllTent_method:call(getHunterCharacter_method:call(nil)) == false then
        restockItems();
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI030210"):get_method("onOpen"), nil, function()
    if isValidData_method:call(nil, mySet) == true then
        applyMySetToPouch_method:call(nil, mySet);
    else
        fillPouchItems_method:call(nil);
    end
    fillShellPouchItems_method:call(nil);
end);

sdk.hook(applyMySetToPouch_method, function(args)
    mySet = sdk.to_int64(args[2]) & 0xFFFFFFFF;
end);