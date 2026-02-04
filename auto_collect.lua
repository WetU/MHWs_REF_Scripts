local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;
local tinsert = Constants.tinsert;

local hook = Constants.hook;
local find_type_definition = Constants.find_type_definition;
local to_int64 = Constants.to_int64;
local to_ptr = Constants.to_ptr;
local set_native_field = Constants.set_native_field;

local ValueType_new = Constants.ValueType_new;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local SKIP_ORIGINAL = Constants.SKIP_ORIGINAL;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;
local GenericList_Clear_method = Constants.GenericList_Clear_method;
local GenericList_RemoveAt_method = Constants.GenericList_RemoveAt_method;

local FacilityUtil_type_def = find_type_definition("app.FacilityUtil");
local payItem_method = FacilityUtil_type_def:get_method("payItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local isEnoughPoint_method = FacilityUtil_type_def:get_method("isEnoughPoint(System.Int32)"); -- static
local payPoint_method = FacilityUtil_type_def:get_method("payPoint(System.Int32)"); -- static

local Shikyu_method = find_type_definition("app.ItemDef"):get_method("Shikyu(app.ItemDef.ID)"); -- static

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local changeItemNumFromDialogue_method = ItemUtil_type_def:get_method("changeItemNumFromDialogue(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE, System.Boolean)"); -- static
local getSellItem_method = ItemUtil_type_def:get_method("getSellItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local getItemNum_method = ItemUtil_type_def:get_method("getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static

local WeaponUtil_type_def = find_type_definition("app.WeaponUtil");
local getWeaponData_method = WeaponUtil_type_def:get_method("getWeaponData(System.Int32, app.WeaponDef.TYPE)"); -- static
local getWeaponEnumId_method = WeaponUtil_type_def:get_method("getWeaponEnumId(app.WeaponDef.TYPE, System.Int32)"); -- static

local get_Facility_method = Constants.get_Facility_method;

local FacilityManager_type_def = get_Facility_method:get_return_type();
local get_Dining_method = FacilityManager_type_def:get_method("get_Dining")
local get_Moriver_method = FacilityManager_type_def:get_method("get_Moriver");

local FacilityDining_type_def = get_Dining_method:get_return_type();
local isSuppliableFoodMax_method = FacilityDining_type_def:get_method("isSuppliableFoodMax");
local supplyFood_method = FacilityDining_type_def:get_method("supplyFood");

local FacilityMoriver_type_def = get_Moriver_method:get_return_type();
local get__HavingCampfire_method = FacilityMoriver_type_def:get_method("get__HavingCampfire");
local executedSharing_method = FacilityMoriver_type_def:get_method("executedSharing(app.FacilityMoriver.MoriverInfo)");
local MoriverInfos_field = FacilityMoriver_type_def:get_field("_MoriverInfos");

local MoriverInfo_type_def = find_type_definition("app.FacilityMoriver.MoriverInfo");
local FacilityId_field = MoriverInfo_type_def:get_field("_FacilityId");
local ItemFromMoriver_field = MoriverInfo_type_def:get_field("ItemFromMoriver");
local ItemFromPlayer_field = MoriverInfo_type_def:get_field("ItemFromPlayer");

local ItemWork_type_def = ItemFromMoriver_field:get_type();
local ItemWork_get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
local ItemWork_Num_field = ItemWork_type_def:get_field("Num");

local UserSaveParam_type_def = Constants.UserSaveParam_type_def;
local get_Equip_method = UserSaveParam_type_def:get_method("get_Equip");
local get_Collection_method = UserSaveParam_type_def:get_method("get_Collection");
local get_LargeWorkshop_method = UserSaveParam_type_def:get_method("get_LargeWorkshop");

local addEquipBoxWeapon_method = get_Equip_method:get_return_type():get_method("addEquipBoxWeapon(app.user_data.WeaponData.cData, app.EquipDef.WeaponRecipeInfo)");

local CollectionParam_type_def = get_Collection_method:get_return_type();
local get_CollectionNPC_method = CollectionParam_type_def:get_method("get_CollectionNPC");
local COLLECTION_NPC_NUM = CollectionParam_type_def:get_field("COLLECTION_NPC_NUM"):get_data(nil); -- static

local CollectionNPCParam_type_def = find_type_definition("app.savedata.cCollectionNPCParam");
local get_CollectionItem_method = CollectionNPCParam_type_def:get_method("get_CollectionItem");
local clearAllCollectionItem_method = CollectionNPCParam_type_def:get_method("clearAllCollectionItem");
local NPCFixedId_field = CollectionNPCParam_type_def:get_field("NPCFixedId");
local NPCFixedId_INIT_VALUE = CollectionNPCParam_type_def:get_field("NPCFixedId_INIT_VALUE"):get_data(nil); -- static
local Collection_MAX_ITEM_NUM = CollectionNPCParam_type_def:get_field("MAX_ITEM_NUM"):get_data(nil); -- static

local LargeWorkshopParam_type_def = get_LargeWorkshop_method:get_return_type();
local get_Rewards_method = LargeWorkshopParam_type_def:get_method("get_Rewards");
local clearRewardItem_method = LargeWorkshopParam_type_def:get_method("clearRewardItem(System.Int32)");
local LargeWorkshop_MAX_ITEM_NUM = LargeWorkshopParam_type_def:get_field("MAX_ITEM_NUM"):get_data(nil); -- static

local FacilityPugee_type_def = find_type_definition("app.FacilityPugee");
local stroke_method = FacilityPugee_type_def:get_method("stroke(System.Boolean)");

local FacilityRallus_type_def = find_type_definition("app.FacilityRallus");
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local resetSupplyNum_method = FacilityRallus_type_def:get_method("resetSupplyNum");
local Event_field = FacilityRallus_type_def:get_field("_Event");

local execute_method = Event_field:get_type():get_method("execute");

local getRewardItemData_method = find_type_definition("app.GimmickRewardUtil"):get_method("getRewardItemData(app.GimmickDef.ID, app.FieldDef.STAGE, System.Boolean, System.Int32)"); -- static

local getReward_method = find_type_definition("app.cSendItemInfo"):get_method("getReward(System.Boolean, System.Boolean)");

local GM262_000_00 = find_type_definition("app.GimmickDef.ID"):get_field("GM262_000_00"):get_data(nil); -- static
local ST502 = Constants.STAGES.ST502;

local SupportShipData_type_def = find_type_definition("app.user_data.SupportShipData.cData");
local SupportShipData_get_ItemId_method = SupportShipData_type_def:get_method("get_ItemId");
local SupportShipData_get_WeaponType_method = SupportShipData_type_def:get_method("get_WeaponType");
local SupportShipData_get_ParamId_method = SupportShipData_type_def:get_method("get_ParamId");
local SupportShipData_get_StockNum_method = SupportShipData_type_def:get_method("get_StockNum");
local SupportShipData_get_Point_method = SupportShipData_type_def:get_method("get_Point");

local ItemID_type_def = ItemWork_get_ItemId_method:get_return_type();
local ItemID = {
    NONE = ItemID_type_def:get_field("NONE"):get_data(nil),
    MAX = ItemID_type_def:get_field("MAX"):get_data(nil)
};

local STOCK_TYPE_type_def = find_type_definition("app.ItemUtil.STOCK_TYPE");
local STOCK_TYPE = {
    POUCH = STOCK_TYPE_type_def:get_field("POUCH"):get_data(nil),
    BOX = STOCK_TYPE_type_def:get_field("BOX"):get_data(nil),
    BOTH_BOX_POUCH = STOCK_TYPE_type_def:get_field("BOTH_BOX_POUCH"):get_data(nil)
};

local FacilityID_type_def = FacilityId_field:get_type();
local FacilityID = {
    SHARING = FacilityID_type_def:get_field("SHARING"):get_data(nil),
    SWOP = FacilityID_type_def:get_field("SWOP"):get_data(nil)
};

local WeaponType_type_def = SupportShipData_get_WeaponType_method:get_return_type();
local WeaponType = {
    INVALID = WeaponType_type_def:get_field("INVALID"):get_data(nil),
    MAX = WeaponType_type_def:get_field("MAX"):get_data(nil)
};

local function dummy()
    local dummy_STOCK_TYPE = ValueType_new(STOCK_TYPE_type_def);
    set_native_field(dummy_STOCK_TYPE, STOCK_TYPE_type_def, "value__", STOCK_TYPE.BOTH_BOX_POUCH);
    return to_ptr(dummy_STOCK_TYPE);
end

local BOTH_BOX_POUCH_ptr = dummy();
local TRUE_ptr = Constants.to_ptr(true);

hook(changeItemNumFromDialogue_method, function(args)
    args[4] = BOTH_BOX_POUCH_ptr;
    args[5] = TRUE_ptr;
end);

hook(find_type_definition("app.FacilityCollection"):get_method("lotItem"), nil, function()
    local NPCParam_array = get_CollectionNPC_method:call(get_Collection_method:call(Constants.UserSaveData));
    for i = 0, COLLECTION_NPC_NUM - 1 do
        local NPCParam = NPCParam_array:get_element(i);
        if NPCFixedId_field:get_data(NPCParam) ~= NPCFixedId_INIT_VALUE then
            local CollectionItem = get_CollectionItem_method:call(NPCParam);
            for j = 0, Collection_MAX_ITEM_NUM - 1 do
                local ItemWork = CollectionItem:get_element(j);
                local ItemId = ItemWork_get_ItemId_method:call(ItemWork);
                if ItemId > ItemID.NONE and ItemId < ItemID.MAX then
                    local Num = ItemWork_Num_field:get_data(ItemWork);
                    if Num > 0 then
                        getSellItem_method:call(nil, ItemId, Num, STOCK_TYPE.BOX);
                    end
                end
            end
            clearAllCollectionItem_method:call(NPCParam);
        end
    end
end);

hook(find_type_definition("app.FacilityLargeWorkshop"):get_method("endFestival"), nil, function()
    local LargeWorkshopParam = get_LargeWorkshop_method:call(Constants.UserSaveData);
    local Rewards = get_Rewards_method:call(LargeWorkshopParam);
    for i = 0, LargeWorkshop_MAX_ITEM_NUM - 1 do
        local Reward = Rewards:get_element(i);
        local ItemId = ItemWork_get_ItemId_method:call(Reward);
        if ItemId > ItemID.NONE and ItemId < ItemID.MAX then
            local Num = ItemWork_Num_field:get_data(Reward);
            if Num > 0 then
                getSellItem_method:call(nil, ItemId, Num, STOCK_TYPE.BOX);
                clearRewardItem_method:call(LargeWorkshopParam, i);
            end
        end
    end
end);

hook(FacilityPugee_type_def:get_method("isEnableCoolTimer"), getThisPtr, function(retval)
    if (to_int64(retval) & 1) == 0 then
        stroke_method:call(get_hook_storage().this_ptr, true);
        return TRUE_ptr;
    end
    return retval;
end);

local function getSuppliedFood(facilityDining)
    if isSuppliableFoodMax_method:call(facilityDining) then
        supplyFood_method:call(facilityDining);
    end
end

local function getItemFromMoriver(moriverInfo, completedTbl)
    local ItemFromMoriver = ItemFromMoriver_field:get_data(moriverInfo);
    local gettingItemId = ItemWork_get_ItemId_method:call(ItemFromMoriver);
    if gettingItemId > ItemID.NONE and gettingItemId < ItemID.MAX then
        local gettingNum = ItemWork_Num_field:get_data(ItemFromMoriver);
        if gettingNum > 0 then
            changeItemNumFromDialogue_method:call(nil, gettingItemId, gettingNum, STOCK_TYPE.BOX, true);
        end
    end
    tinsert(completedTbl, moriverInfo);
end

local function execMoriver(facilityMoriver)
    local MoriverInfos = MoriverInfos_field:get_data(facilityMoriver);
    local moriverCount = GenericList_get_Count_method:call(MoriverInfos);
    if moriverCount > 0 then
        local completedMoriverInfos = {};
        for i = 0, moriverCount - 1 do
            local MoriverInfo = GenericList_get_Item_method:call(MoriverInfos, i);
            local FacilityId = FacilityId_field:get_data(MoriverInfo);
            if FacilityId == FacilityID.SHARING then
                getItemFromMoriver(MoriverInfo, completedMoriverInfos);
            elseif FacilityId == FacilityID.SWOP then
                local ItemFromPlayer = ItemFromPlayer_field:get_data(MoriverInfo);
                local givingItemId = ItemWork_get_ItemId_method:call(ItemFromPlayer);
                if givingItemId > ItemID.NONE and givingItemId < ItemID.MAX then
                    local givingNum = ItemWork_Num_field:get_data(ItemFromPlayer);
                    local boxNum = getItemNum_method:call(nil, givingItemId, STOCK_TYPE.BOX);
                    if boxNum >= givingNum then
                        payItem_method:call(nil, givingItemId, givingNum, STOCK_TYPE.BOX);
                        getItemFromMoriver(MoriverInfo, completedMoriverInfos);
                    else
                        local pouchNum = getItemNum_method:call(nil, giveItemId, STOCK_TYPE.POUCH);
                        if pouchNum >= givingNum or (boxNum + pouchNum) >= givingNum then
                            if boxNum > 0 then
                                payItem_method:call(nil, givingItemId, boxNum, STOCK_TYPE.BOX);
                                payItem_method:call(nil, givingItemId, givingNum - boxNum, STOCK_TYPE.POUCH);
                            else
                                payItem_method:call(nil, givingItemId, pouchNum, STOCK_TYPE.POUCH);
                            end
                            getItemFromMoriver(MoriverInfo, completedMoriverInfos);
                        end
                    end
                end
            end
        end
        for _, completedMoriverInfo in ipairs(completedMoriverInfos) do
            executedSharing_method:call(facilityMoriver, completedMoriverInfo);
        end
    end
end

hook(find_type_definition("app.IngameState"):get_method("enter"), nil, function()
    local FacilityManager = get_Facility_method:call(nil);
    local FacilityMoriver = get_Moriver_method:call(FacilityManager);
    if get__HavingCampfire_method:call(FacilityMoriver) then
        execMoriver(FacilityMoriver);
    end
    getSuppliedFood(get_Dining_method:call(FacilityManager));
end);

hook(FacilityDining_type_def:get_method("addSupplyNum"), getThisPtr, function()
    getSuppliedFood(get_hook_storage().this_ptr);
end);

hook(FacilityMoriver_type_def:get_method("startCampfire(System.Boolean)"), getThisPtr, function()
    execMoriver(get_hook_storage().this_ptr);
end);

hook(FacilityRallus_type_def:get_method("supplyTimerGoal(app.cFacilityTimer)"), getThisPtr, function()
    local FacilityRallus_ptr = get_hook_storage().this_ptr;
    local SupplyNum = get_SupplyNum_method:call(FacilityRallus_ptr);
    local SendItemInfo_List = getRewardItemData_method:call(nil, GM262_000_00, ST502, true, 1 - SupplyNum);
    for i = 0, SupplyNum - 1 do
        getReward_method:call(GenericList_get_Item_method:call(SendItemInfo_List, i), true, true);
    end
    GenericList_Clear_method:call(SendItemInfo_List);
    execute_method:call(Event_field:get_data(FacilityRallus_ptr));
    resetSupplyNum_method:call(FacilityRallus_ptr);
end);

hook(Constants.FacilitySupplyItems_type_def:get_method("addItem(System.Collections.Generic.List`1<app.cSupplyInfo>, app.ItemDef.ID, System.Int16)"), function(args)
    local ItemId = to_int64(args[3]) & 0xFFFFFFFF;
    if Shikyu_method:call(nil, ItemId) == false then
        getSellItem_method:call(nil, ItemId, to_int64(args[4]) & 0xFFFF, STOCK_TYPE.BOX);
        return SKIP_ORIGINAL;
    end
end);

hook(find_type_definition("app.savedata.cShipParam"):get_method("setItems(System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>)"), function(args)
    local dataList_ptr = args[3];
    local EquipParam = nil;
    for i = 0, GenericList_get_Count_method:call(dataList_ptr) - 1 do
        local ShipData = GenericList_get_Item_method:call(dataList_ptr, i);
        local StockNum = SupportShipData_get_StockNum_method:call(ShipData);
        if StockNum > 0 then
            local cost = SupportShipData_get_Point_method:call(ShipData);
            for j = StockNum, 1, -1 do
                local totalCost = cost * j;
                if isEnoughPoint_method:call(nil, totalCost) then
                    local ItemId = SupportShipData_get_ItemId_method:call(ShipData);
                    if ItemId > ItemID.NONE and ItemId < ItemID.MAX then
                        getSellItem_method:call(nil, ItemId, j, STOCK_TYPE.BOX);
                        payPoint_method:call(nil, totalCost);
                        set_native_field(ShipData, SupportShipData_type_def, "_StockNum", StockNum - j);
                    else
                        local weaponType = SupportShipData_get_WeaponType_method:call(ShipData);
                        if weaponType > WeaponType.INVALID and weaponType < WeaponType.MAX then
                            if EquipParam == nil then
                                EquipParam = get_Equip_method:call(Constants.UserSaveData);
                            end
                            addEquipBoxWeapon_method:call(EquipParam, getWeaponData_method:call(nil, getWeaponEnumId_method:call(nil, weaponType, SupportShipData_get_ParamId_method:call(ShipData)), weaponType), nil);
                            payPoint_method:call(nil, totalCost);
                            set_native_field(ShipData, SupportShipData_type_def, "_StockNum", StockNum - j);
                        end
                    end
                    break;
                end
            end
        end
    end
end);