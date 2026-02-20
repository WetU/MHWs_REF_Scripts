local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;

local find_type_definition = Constants.find_type_definition;
local hook = Constants.hook;
local to_int64 = Constants.to_int64;

local get_hook_storage = Constants.get_hook_storage;

local addSystemLog_method = Constants.addSystemLog_method;
local getThisPtr = Constants.getThisPtr;

local isArenaQuest_method = find_type_definition("app.NpcPartnerUtil"):get_method("isArenaQuest"); -- static

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local fillPouchItems_method = ItemUtil_type_def:get_method("fillPouchItems"); -- static
local fillShellPouchItems_method = ItemUtil_type_def:get_method("fillShellPouchItems"); -- static

local ItemMySetUtil_type_def = find_type_definition("app.ItemMySetUtil");
local applyMySetToPouch_method = ItemMySetUtil_type_def:get_method("applyMySetToPouch(System.Int32)"); -- static
local isValidData_method = ItemMySetUtil_type_def:get_method("isValidData(System.Int32)"); -- static

local GUI090001_type_def = find_type_definition("app.GUI090001");
local isActive_method = GUI090001_type_def:get_method("isActive");
local CurrentMenu_field = GUI090001_type_def:get_field("_CurrentMenu");

local MenuType_type_def = CurrentMenu_field:get_type();
local restockMenus = {
    MenuType_type_def:get_field("TENT"):get_data(nil),
    MenuType_type_def:get_field("TEMPORARY_TENT"):get_data(nil),
    MenuType_type_def:get_field("SIMPLE_TENT"):get_data(nil),
    MenuType_type_def:get_field("ITEM_BOX"):get_data(nil)
};

local GUI020201_type_def = find_type_definition("app.GUI020201");
local StampPanels_field = GUI020201_type_def:get_field("_StampPanels");
local GUI020201_CurType_field = GUI020201_type_def:get_field("_CurType");

local GUI020216_type_def = find_type_definition("app.GUI020216");
local Panel_field = GUI020216_type_def:get_field("_Panel");
local GUI020216_CurType_field = GUI020216_type_def:get_field("_CurType");

local START = GUI020201_CurType_field:get_type():get_field("START"):get_data(nil);

local set_PlayState_method = Panel_field:get_type():get_parent_type():get_parent_type():get_method("set_PlayState(System.String)");

local mySetIdx = 0;

local function restockItems(sendMessage)
    if isValidData_method:call(nil, mySetIdx) then
        applyMySetToPouch_method:call(nil, mySetIdx);
        if sendMessage then
            addSystemLog_method:call(Constants.ChatManager, "아이템 세트가 적용되었습니다: [" .. mySetIdx .. "]");
        end
    else
        fillPouchItems_method:call(nil);
        if sendMessage then
            addSystemLog_method:call(Constants.ChatManager, "아이템이 보충되었습니다.");
        end
    end
    fillShellPouchItems_method:call(nil);
end

local function PlayerStartRiding(retval)
    if isArenaQuest_method:call(nil) == false then
        restockItems(false);
    end
    return retval;
end

hook(applyMySetToPouch_method, function(args)
    mySetIdx = to_int64(args[2]) & 0xFFFFFFFF;
end);

local valid_GUI090001 = nil;
hook(GUI090001_type_def:get_method("onClose"), function(args)
    if isArenaQuest_method:call(nil) == false then
        local this_ptr = args[2];
        local CurrentMenu = CurrentMenu_field:get_data(this_ptr);
        for _, v in ipairs(restockMenus) do
            if CurrentMenu == v then
                get_hook_storage().this_ptr = this_ptr;
                valid_GUI090001 = true;
                break;
            end
        end
    end
end, function()
    if valid_GUI090001 then
        valid_GUI090001 = nil;
        if isActive_method:call(get_hook_storage().this_ptr) == false then
            restockItems(true);
        end
    end
end);

hook(GUI020201_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    local CurType = GUI020201_CurType_field:get_data(this_ptr);
    set_PlayState_method:call(StampPanels_field:get_data(this_ptr):get_element(CurType), "DISABLE");
    if CurType == START and isArenaQuest_method:call(nil) == false then
        restockItems(true);
    end
end);

hook(GUI020216_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    set_PlayState_method:call(Panel_field:get_data(this_ptr), "HIDDEN");
    if GUI020216_CurType_field:get_data(this_ptr) == START then
        restockItems(true);
    end
end);

hook(find_type_definition("app.PlayerCommonAction.cPorterRideStart"):get_method("doEnter"), nil, PlayerStartRiding);
hook(find_type_definition("app.PlayerCommonAction.cPorterRideStartJumpOnto"):get_method("doEnter"), nil, PlayerStartRiding);