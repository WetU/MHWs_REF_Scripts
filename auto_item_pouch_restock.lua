local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;

local fillPouchItems_method = Constants.ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = Constants.ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = sdk.find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local isArenaQuest_method = Constants.ActiveQuestData_type_def:get_method("isArenaQuest");
local addSystemLog_method = Constants.ChatManager_type_def:get_method("addSystemLog(System.String)");

local mySet = 0;

local isSelfCall = false;

local function restockItems()
    local ChatManager = Constants.get_Chat_method:call(nil);

    if isValidData_method:call(nil, mySet) == true then
        isSelfCall = true;
        applyMySetToPouch_method:call(nil, mySet);
        addSystemLog_method:call(ChatManager, "아이템 세트가 적용되었습니다.");
    else
        fillPouchItems_method:call(nil);
        addSystemLog_method:call(ChatManager, "아이템이 보충되었습니다.");
    end

    fillShellPouchItems_method:call(nil);
end

sdk.hook(sdk.find_type_definition("app.mcHunterTentAction"):get_method("updateBegin"), nil, restockItems);
sdk.hook(Constants.QuestDirector_type_def:get_method("acceptQuest(app.cActiveQuestData, app.cQuestAcceptArg, System.Boolean, System.Boolean)"), function(args)
    if isArenaQuest_method:call(sdk.to_managed_object(args[3])) ~= true then
        restockItems();
    end
end);
sdk.hook(sdk.find_type_definition("app.FacilitySupplyItems"):get_method("openGUI"), nil, function(retval)
    restockItems();
    return retval;
end);
sdk.hook(applyMySetToPouch_method, function(args)
    if isSelfCall == true then
        isSelfCall = false;
    else
        local appliedSet = sdk.to_int64(args[2]) & 0xFFFFFFFF;
        if mySet ~= appliedSet then
            mySet = appliedSet;
        end
    end
end);
sdk.hook(sdk.find_type_definition("app.GUI030203"):get_method("applyMySet(System.Int32)"), function(args)
    local appliedSet = sdk.to_int64(args[3]) & 0xFFFFFFFF;
    if mySet ~= appliedSet then
        mySet = appliedSet;
    end
end);