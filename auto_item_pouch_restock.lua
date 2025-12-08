local Constants = _G.require("Constants/Constants");

local tostring = Constants.tostring;
local ipairs = Constants.ipairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local addSystemLog_method = Constants.addSystemLog_method;

local IsArenaQuest_method = sdk.find_type_definition("app.EnemyUtil"):get_method("IsArenaQuest"); -- static

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local fillPouchItems_method = ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = sdk.find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local GUI090001_type_def = sdk.find_type_definition("app.GUI090001");
local isActive_method = GUI090001_type_def:get_method("isActive");
local CurrentMenu_field = GUI090001_type_def:get_field("_CurrentMenu");

local MenuType_type_def = CurrentMenu_field:get_type();
local restockMenus = {
    MenuType_type_def:get_field("TENT"):get_data(nil),
    MenuType_type_def:get_field("TEMPORARY_TENT"):get_data(nil),
    MenuType_type_def:get_field("SIMPLE_TENT"):get_data(nil),
    MenuType_type_def:get_field("ITEM_BOX"):get_data(nil)
};

local ShortcutPalletParam_type_def = Constants.ShortcutPalletParam_type_def;
local setCurrentIndex_method = ShortcutPalletParam_type_def:get_method("setCurrentIndex(app.ItemDef.PALLET_TYPE, System.Int32)");
local getCurrentIndex_method = ShortcutPalletParam_type_def:get_method("getCurrentIndex(app.ItemDef.PALLET_TYPE)");

local PC = sdk.find_type_definition("app.ItemDef.PALLET_TYPE"):get_field("PC"):get_data(nil); -- static

local mySetIdx = 0;

local function restockItems(sendMessage)
    if isValidData_method:call(nil, mySetIdx) == true then
        applyMySetToPouch_method:call(nil, mySetIdx);
        if sendMessage == true then
            addSystemLog_method:call(Constants.ChatManager, "아이템 세트가 적용되었습니다: [" .. tostring(mySetIdx) .. "]");
        end
    else
        fillPouchItems_method:call(nil);
        if sendMessage == true then
            addSystemLog_method:call(Constants.ChatManager, "아이템이 보충되었습니다.");
        end
    end
    fillShellPouchItems_method:call(nil);
end

local function PlayerStartRiding(retval)
    if IsArenaQuest_method:call(nil) == false then
        restockItems(false);
    end
    local ShortcutPalletParam = Constants.ShortcutPalletParam;
    if getCurrentIndex_method:call(ShortcutPalletParam, PC) ~= 0 then
        setCurrentIndex_method:call(ShortcutPalletParam, PC, 0);
    end
    return retval;
end

sdk.hook(applyMySetToPouch_method, function(args)
    mySetIdx = sdk.to_int64(args[2]) & 0xFFFFFFFF;
end);

local valid_GUI090001 = nil;
sdk.hook(GUI090001_type_def:get_method("onClose"), function(args)
    if IsArenaQuest_method:call(nil) == false then
        local this_ptr = args[2];
        local CurrentMenu = CurrentMenu_field:get_data(this_ptr);
        for _, v in ipairs(restockMenus) do
            if CurrentMenu == v then
                thread.get_hook_storage()["this_ptr"] = this_ptr;
                valid_GUI090001 = true;
                break;
            end
        end
    end
end, function()
    if valid_GUI090001 == true then
        valid_GUI090001 = nil;
        if isActive_method:call(thread.get_hook_storage()["this_ptr"]) == false then
            restockItems(true);
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.MissionMusicManager.QuestMusicManager"):get_method("onQuestStart"), nil, function()
    if IsArenaQuest_method:call(nil) == false then
        restockItems(true);
    end
end);

sdk.hook(sdk.find_type_definition("app.PlayerCommonAction.cPorterRideStart"):get_method("doEnter"), nil, PlayerStartRiding);
sdk.hook(sdk.find_type_definition("app.PlayerCommonAction.cPorterRideStartJumpOnto"):get_method("doEnter"), nil, PlayerStartRiding);