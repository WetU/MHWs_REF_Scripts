local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;
local table = Constants.table;

local sdk = Constants.sdk;
local thread = Constants.thread;

local init = Constants.init;
local getThisPtr = Constants.getThisPtr;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;

local FacilityUtil_type_def = sdk.find_type_definition("app.FacilityUtil");
local payItem_method = FacilityUtil_type_def:get_method("payItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local isEnoughPoint_method = FacilityUtil_type_def:get_method("isEnoughPoint(System.Int32)"); -- static
local payPoint_method = FacilityUtil_type_def:get_method("payPoint(System.Int32)"); -- static

local getItemData_method = sdk.find_type_definition("app.ItemDef"):get_method("Data(app.ItemDef.ID)"); -- static

local get_Shikyu_method = getItemData_method:get_return_type():get_method("get_Shikyu");

local ItemUtil_type_def = Constants.ItemUtil_type_def;
local changeItemNumFromDialogue_method = ItemUtil_type_def:get_method("changeItemNumFromDialogue(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE, System.Boolean)"); -- static
local getSellItem_method = ItemUtil_type_def:get_method("getSellItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local getItemNum_method = ItemUtil_type_def:get_method("getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static

local getWeaponEnumId_method = sdk.find_type_definition("app.WeaponUtil"):get_method("getWeaponEnumId(app.WeaponDef.TYPE, System.Int32)"); -- static
local getWeaponData_method = sdk.find_type_definition("app.WeaponDef"):get_method("Data(app.WeaponDef.TYPE, System.Int32)"); -- static

local FacilityManager_type_def = sdk.find_type_definition("app.FacilityManager");
local get_Moriver_method = FacilityManager_type_def:get_method("get_Moriver");
local get_Pugee_method = FacilityManager_type_def:get_method("get_Pugee");

local FacilityMoriver_type_def = get_Moriver_method:get_return_type();
local get__HavingCampfire_method = FacilityMoriver_type_def:get_method("get__HavingCampfire");
local executedSharing_method = FacilityMoriver_type_def:get_method("executedSharing(app.FacilityMoriver.MoriverInfo)");
local MoriverInfos_field = FacilityMoriver_type_def:get_field("_MoriverInfos");

local MoriverInfos_type_def = MoriverInfos_field:get_type();
local Moriver_get_Item_method = MoriverInfos_type_def:get_method("get_Item(System.Int32)");
local Moriver_Remove_method = MoriverInfos_type_def:get_method("Remove(app.FacilityMoriver.MoriverInfo)");

local MoriverInfo_type_def = Moriver_get_Item_method:get_return_type();
local FacilityId_field = MoriverInfo_type_def:get_field("_FacilityId");
local ItemFromMoriver_field = MoriverInfo_type_def:get_field("ItemFromMoriver");
local ItemFromPlayer_field = MoriverInfo_type_def:get_field("ItemFromPlayer");

local ItemWork_type_def = ItemFromMoriver_field:get_type();
local ItemWork_get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
local ItemWork_Num_field = ItemWork_type_def:get_field("Num");

local UserSaveData_type_def = sdk.find_type_definition("app.savedata.cUserSaveParam");
local get_BasicData_method = UserSaveData_type_def:get_method("get_BasicData");
local get_Equip_method = UserSaveData_type_def:get_method("get_Equip");
local get_Collection_method = UserSaveData_type_def:get_method("get_Collection");
local get_LargeWorkshop_method = UserSaveData_type_def:get_method("get_LargeWorkshop");
local Save_get_Pugee_method = UserSaveData_type_def:get_method("get_Pugee");

local BasicParam_type_def = get_BasicData_method:get_return_type();
local setMoriverNum_method = BasicParam_type_def:get_method("setMoriverNum(System.Int32)");
local getMoriverNum_method = BasicParam_type_def:get_method("getMoriverNum");

local addEquipBoxWeapon_method = get_Equip_method:get_return_type():get_method("addEquipBoxWeapon(app.user_data.WeaponData.cData, app.EquipDef.WeaponRecipeInfo)");

local CollectionParam_type_def = get_Collection_method:get_return_type();
local get_CollectionNPC_method = CollectionParam_type_def:get_method("get_CollectionNPC");
local COLLECTION_NPC_NUM = CollectionParam_type_def:get_field("COLLECTION_NPC_NUM"):get_data(nil); -- static

local CollectionNPCParam_type_def = sdk.find_type_definition("app.savedata.cCollectionNPCParam");
local get_CollectionItem_method = CollectionNPCParam_type_def:get_method("get_CollectionItem");
local clearAllCollectionItem_method = CollectionNPCParam_type_def:get_method("clearAllCollectionItem");
local NPCFixedId_field = CollectionNPCParam_type_def:get_field("NPCFixedId");
local NPCFixedId_INIT_VALUE = CollectionNPCParam_type_def:get_field("NPCFixedId_INIT_VALUE"):get_data(nil); -- static
local Collection_MAX_ITEM_NUM = CollectionNPCParam_type_def:get_field("MAX_ITEM_NUM"):get_data(nil); -- static

local LargeWorkshopParam_type_def = get_LargeWorkshop_method:get_return_type();
local get_Rewards_method = LargeWorkshopParam_type_def:get_method("get_Rewards");
local clearRewardItem_method = LargeWorkshopParam_type_def:get_method("clearRewardItem(System.Int32)");
local LargeWorkshop_MAX_ITEM_NUM = LargeWorkshopParam_type_def:get_field("MAX_ITEM_NUM"):get_data(nil); -- static

local stroke_method = get_Pugee_method:get_return_type():get_method("stroke(System.Boolean)");

local getCoolTimer_method = Save_get_Pugee_method:get_return_type():get_method("getCoolTimer");

local FacilityDining_type_def = sdk.find_type_definition("app.FacilityDining");
local isSuppliableFoodMax_method = FacilityDining_type_def:get_method("isSuppliableFoodMax");
local supplyFood_method = FacilityDining_type_def:get_method("supplyFood");

local FacilityRallus_type_def = sdk.find_type_definition("app.FacilityRallus");
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local resetSupplyNum_method = FacilityRallus_type_def:get_method("resetSupplyNum");
local Event_field = FacilityRallus_type_def:get_field("_Event");

local execute_method = Event_field:get_type():get_method("execute");

local getRewardItemData_method = sdk.find_type_definition("app.GimmickRewardUtil"):get_method("getRewardItemData(app.GimmickDef.ID, app.FieldDef.STAGE, System.Boolean, System.Int32)"); -- static

local SendItemInfo_get_Item_method = getRewardItemData_method:get_return_type():get_method("get_Item(System.Int32)");

local getReward_method = SendItemInfo_get_Item_method:get_return_type():get_method("getReward(System.Boolean, System.Boolean)");

local GM262_000_00 = sdk.find_type_definition("app.GimmickDef.ID"):get_field("GM262_000_00"):get_data(nil); -- static
local ST502 = sdk.find_type_definition("app.FieldDef.STAGE"):get_field("ST502"):get_data(nil); -- static

local SupplyInfo_List_type_def = sdk.find_type_definition("System.Collections.Generic.List`1<app.cSupplyInfo>");
local SupplyInfo_get_Item_method = SupplyInfo_List_type_def:get_method("get_Item(System.Int32)");
local SupplyInfo_RemoveAt_method = SupplyInfo_List_type_def:get_method("RemoveAt(System.Int32)");

local SupplyInfo_type_def = SupplyInfo_get_Item_method:get_return_type();
local SupplyInfo_ItemId_field = SupplyInfo_type_def:get_field("ItemId");
local SupplyInfo_Count_field = SupplyInfo_type_def:get_field("Count");

local SupportShipData_get_Item_method = Constants.SupportShipData_List_type_def:get_method("get_Item(System.Int32)");

local SupportShipData_type_def = SupportShipData_get_Item_method:get_return_type();
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

local STOCK_TYPE_type_def = sdk.find_type_definition("app.ItemUtil.STOCK_TYPE");
local STOCK_TYPE = {
    POUCH = STOCK_TYPE_type_def:get_field("POUCH"):get_data(nil),
    BOX = STOCK_TYPE_type_def:get_field("BOX"):get_data(nil)
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

local isSelfCall = false;
local BOX_ptr = sdk.to_ptr(STOCK_TYPE.BOX);
sdk.hook(changeItemNumFromDialogue_method, function(args)
    if isSelfCall == true then
        isSelfCall = false;
    else
        args[4] = BOX_ptr;
    end
end);

sdk.hook(sdk.find_type_definition("app.FacilityCollection"):get_method("lotItem"), nil, function()
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

sdk.hook(sdk.find_type_definition("app.FacilityLargeWorkshop"):get_method("endFestival"), nil, function()
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

local PugeeParam = nil;
sdk.hook(FacilityManager_type_def:get_method("update"), function(args)
    if PugeeParam == nil then
        local UserSaveData = Constants.UserSaveData;
        if UserSaveData ~= nil then
            PugeeParam = Save_get_Pugee_method:call(UserSaveData);
        end
    end
end, function()
    if PugeeParam ~= nil and getCoolTimer_method:call(PugeeParam) <= 0.0 then
        stroke_method:call(get_Pugee_method:call(Constants.FacilityManager), true);
    end
end);

sdk.hook(FacilityDining_type_def:get_method("addSuplyNum"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    if isSuppliableFoodMax_method:call(this_ptr) == true then
        supplyFood_method:call(this_ptr);
    end
end);

local function getItemFromMoriver(moriverInfo, completedTbl)
    local ItemFromMoriver = ItemFromMoriver_field:get_data(moriverInfo);
    local gettingItemId = ItemWork_get_ItemId_method:call(ItemFromMoriver);
    if gettingItemId > ItemID.NONE and gettingItemId < ItemID.MAX then
        local gettingNum = ItemWork_Num_field:get_data(ItemFromMoriver);
        if gettingNum > 0 then
            isSelfCall = true;
            changeItemNumFromDialogue_method:call(nil, gettingItemId, gettingNum, STOCK_TYPE.BOX, true);
        end
    end
    table.insert(completedTbl, moriverInfo);
end

local function execMoriver(facilityMoriver)
    local MoriverInfos = MoriverInfos_field:get_data(facilityMoriver);
    local Count = GenericList_get_Count_method:call(MoriverInfos);
    if Count > 0 then
        local completedSharing = {};
        local completedSWOP = {};
        for i = 0, Count - 1 do
            local MoriverInfo = Moriver_get_Item_method:call(MoriverInfos, i);
            local FacilityId = FacilityId_field:get_data(MoriverInfo);
            if FacilityId == FacilityID.SHARING then
                getItemFromMoriver(MoriverInfo, completedSharing);
            elseif FacilityId == FacilityID.SWOP then
                local ItemFromPlayer = ItemFromPlayer_field:get_data(MoriverInfo);
                local givingItemId = ItemWork_get_ItemId_method:call(ItemFromPlayer);
                if givingItemId > ItemID.NONE and givingItemId < ItemID.MAX then
                    local givingNum = ItemWork_Num_field:get_data(ItemFromPlayer);
                    local boxNum = getItemNum_method:call(nil, givingItemId, STOCK_TYPE.BOX);
                    if boxNum >= givingNum then
                        payItem_method:call(nil, givingItemId, givingNum, STOCK_TYPE.BOX);
                        getItemFromMoriver(MoriverInfo, completedSWOP);
                    else
                        local pouchNum = getItemNum_method:call(nil, giveItemId, STOCK_TYPE.POUCH);
                        if boxNum > 0 then
                            if (boxNum + pouchNum) >= givingNum then
                                payItem_method:call(nil, givingItemId, boxNum, STOCK_TYPE.BOX);
                                payItem_method:call(nil, givingItemId, givingNum - boxNum, STOCK_TYPE.POUCH);
                                getItemFromMoriver(MoriverInfo, completedSWOP);
                            end
                        elseif pouchNum >= givingNum then
                            payItem_method:call(nil, givingItemId, givingNum, STOCK_TYPE.POUCH);
                            getItemFromMoriver(MoriverInfo, completedSWOP);
                        end
                    end
                end
            end
        end
        if #completedSharing > 0 then
            for _, completedSharing in ipairs(completedSharing) do
                executedSharing_method:call(facilityMoriver, completedSharing);
            end
        end
        local completedSWOPcounts = #completedSWOP;
        if completedSWOPcounts > 0 then
            for _, completedSWOP in ipairs(completedSWOP) do
                Moriver_Remove_method:call(MoriverInfos, completedSWOP);
            end
        end
        local BasicParam = get_BasicData_method:call(Constants.UserSaveData);
        setMoriverNum_method:call(BasicParam, getMoriverNum_method:call(BasicParam) - completedSWOPcounts);
    end
end

sdk.hook(sdk.find_type_definition("app.IngameState"):get_method("enter"), init, function()
    local FacilityMoriver = get_Moriver_method:call(Constants.FacilityManager);
    if get__HavingCampfire_method:call(FacilityMoriver) == true then
        execMoriver(FacilityMoriver);
    end
end);

sdk.hook(FacilityMoriver_type_def:get_method("startCampfire(System.Boolean)"), getThisPtr, function()
    execMoriver(thread.get_hook_storage()["this_ptr"]);
end);

sdk.hook(FacilityRallus_type_def:get_method("supplyTimerGoal(app.cFacilityTimer)"), getThisPtr, function()
    local FacilityRallus_ptr = thread.get_hook_storage()["this_ptr"];
    local SupplyNum = get_SupplyNum_method:call(FacilityRallus_ptr);
    local SendItemInfo_List = getRewardItemData_method:call(nil, GM262_000_00, ST502, true, 1 - SupplyNum);
    for i = 0, SupplyNum - 1 do
        getReward_method:call(SendItemInfo_get_Item_method:call(SendItemInfo_List, i), true, true);
    end
    execute_method:call(Event_field:get_data(FacilityRallus_ptr));
    resetSupplyNum_method:call(FacilityRallus_ptr);
end);

local isSupplyOnlyItem = nil;
sdk.hook(sdk.find_type_definition("app.FacilitySupplyItems"):get_method("addItem(System.Collections.Generic.List`1<app.cSupplyInfo>, app.ItemDef.ID, System.Int16)"), function(args)
    local ItemId = sdk.to_int64(args[3]) & 0xFFFFFFFF;
    isSupplyOnlyItem = get_Shikyu_method:call(getItemData_method:call(nil, ItemId));
    if isSupplyOnlyItem == false then
        local storage = thread.get_hook_storage();
        storage.List_ptr = args[2];
        storage.ItemId = ItemId;
        storage.ItemNum = sdk.to_int64(args[4]) & 0xFFFF;
    end
end, function()
    if isSupplyOnlyItem == false then
        isSupplyOnlyItem = nil;
        local storage = thread.get_hook_storage();
        local List_ptr = storage.List_ptr;
        local ItemId = storage.ItemId;
        local ItemNum = storage.ItemNum;
        for i = 0, GenericList_get_Count_method:call(List_ptr) - 1 do
            local SupplyInfo = SupplyInfo_get_Item_method:call(List_ptr, i);
            if SupplyInfo_ItemId_field:get_data(SupplyInfo) == ItemId then
                local Count = SupplyInfo_Count_field:get_data(SupplyInfo)
                if Count >= ItemNum then
                getSellItem_method:call(nil, ItemId, Count, STOCK_TYPE.BOX);
                SupplyInfo_RemoveAt_method:call(List_ptr, i);
                return;
            end
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.savedata.cShipParam"):get_method("setItems(System.Collections.Generic.List`1<app.user_data.SupportShipData.cData>)"), function(args)
    local dataList_ptr = args[3];
    for i = 0, GenericList_get_Count_method:call(dataList_ptr) - 1 do
        local ShipData = SupportShipData_get_Item_method:call(dataList_ptr, i);
        local StockNum = SupportShipData_get_StockNum_method:call(ShipData);
        if StockNum > 0 then
            local cost = SupportShipData_get_Point_method:call(ShipData);
            for j = StockNum, 1, -1 do
                local totalCost = cost * j;
                if isEnoughPoint_method:call(nil, totalCost) == true then
                    local ItemId = SupportShipData_get_ItemId_method:call(ShipData);
                    if ItemId > ItemID.NONE and ItemId < ItemID.MAX then
                        getSellItem_method:call(nil, ItemId, j, STOCK_TYPE.BOX);
                        payPoint_method:call(nil, totalCost);
                        sdk.set_native_field(ShipData, SupportShipData_type_def, "_StockNum", StockNum - j);
                        break;
                    else
                        local weaponType = SupportShipData_get_WeaponType_method:call(ShipData);
                        if weaponType > WeaponType.INVALID and weaponType < WeaponType.MAX then
                            addEquipBoxWeapon_method:call(get_Equip_method:call(Constants.UserSaveData), getWeaponData_method:call(nil, weaponType, getWeaponEnumId_method:call(nil, weaponType, SupportShipData_get_ParamId_method:call(ShipData))), nil);
                            payPoint_method:call(nil, totalCost);
                            sdk.set_native_field(ShipData, SupportShipData_type_def, "_StockNum", StockNum - j);
                            break;
                        end
                    end
                end
            end
        end
    end
end);