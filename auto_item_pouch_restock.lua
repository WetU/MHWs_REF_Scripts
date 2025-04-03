local require = _G.require;

local Constants = require("Constants/Constants");
local sdk = Constants.sdk;

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local fillPouchItems_method = ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = sdk.find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local addSystemLog_method = Constants.ChatManager_type_def:get_method("addSystemLog(System.String)");

local mySet = 0;

local isSelfCall = false;
local function mySetTracker(args)
    if isSelfCall == true then
        isSelfCall = false;
    else
        local appliedSet = sdk.to_int64(args[2]) & 0xFFFFFFFF;
        if mySet ~= appliedSet then
            mySet = appliedSet;
        end
    end
end

local function restockItems()
    if isValidData_method:call(nil, mySet) == true then
        isSelfCall = true;
        applyMySetToPouch_method:call(nil, mySet);
        addSystemLog_method:call(sdk.get_managed_singleton("app.ChatManager"), "아이템 세트가 적용되었습니다.");
    else
        fillPouchItems_method:call(nil);
        addSystemLog_method:call(sdk.get_managed_singleton("app.ChatManager"), "아이템이 보충되었습니다.");
    end

    fillShellPouchItems_method:call(nil);
end

sdk.hook(sdk.find_type_definition("app.cCampManager"):get_method("tentGetIn(via.GameObject)"), nil, restockItems);
sdk.hook(sdk.find_type_definition("app.cQuestStart"):get_method("enter"), nil, function(retval)
    restockItems();
    return retval;
end);
sdk.hook(sdk.find_type_definition("app.FacilitySupplyItems"):get_method("openGUI"), nil, function(retval)
    restockItems();
    return retval;
end);
sdk.hook(applyMySetToPouch_method, mySetTracker);
sdk.hook(sdk.find_type_definition("app.GUI030203"):get_method("applyMySet"), mySetTracker);