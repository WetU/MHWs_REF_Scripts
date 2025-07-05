local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local ipairs = Constants.ipairs;
local table = Constants.table;

local payItem_method = sdk.find_type_definition("app.FacilityUtil"):get_method("payItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local changeItemNumFromDialogue_method = Constants.ItemUtil_type_def:get_method("changeItemNumFromDialogue(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE, System.Boolean)"); -- static
local getItemNum_method = Constants.ItemUtil_type_def:get_method("getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static
local changeItemNum_method = Constants.ItemUtil_type_def:get_method("changeItemNum(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static
local sendItemToBox_method = Constants.ItemUtil_type_def:get_method("sendItemToBox(app.ItemDef.LOG_CATEGORY, app.cSendItemInfo, System.Boolean, app.EnemyDef.ID, System.Boolean)"); -- static
local sellItem_method = Constants.ItemUtil_type_def:get_method("sellItem(app.ItemDef.ID, System.Int16)"); -- static
local getItemCapacity_method = Constants.ItemUtil_type_def:get_method("getItemCapacity(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static

local addItemLog_method = sdk.find_type_definition("app.ChatLogUtil"):get_method("addItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID)"); -- static

local CollectionNPCParam_type_def = sdk.find_type_definition("app.savedata.cCollectionNPCParam");
local get_CollectionItem_method = CollectionNPCParam_type_def:get_method("get_CollectionItem");
local clearAllCollectionItem_method = CollectionNPCParam_type_def:get_method("clearAllCollectionItem");
local Collection_MAX_ITEM_NUM = CollectionNPCParam_type_def:get_field("MAX_ITEM_NUM"):get_data(nil); -- static

local LargeWorkshopParam_type_def = sdk.find_type_definition("app.savedata.cLargeWorkshopParam");
local get_Rewards_method = LargeWorkshopParam_type_def:get_method("get_Rewards");
local clearRewardItem_method = LargeWorkshopParam_type_def:get_method("clearRewardItem(System.Int32)");
local LargeWorkshop_MAX_ITEM_NUM = LargeWorkshopParam_type_def:get_field("MAX_ITEM_NUM"):get_data(nil); -- static

local FacilityDining_type_def = sdk.find_type_definition("app.FacilityDining");
local supplyFood_method = FacilityDining_type_def:get_method("supplyFood");

local FacilityMoriver_type_def = sdk.find_type_definition("app.FacilityMoriver");
local get__HavingCampfire_method = FacilityMoriver_type_def:get_method("get__HavingCampfire");
local isEnableMoriverFacility_method = FacilityMoriver_type_def:get_method("isEnableMoriverFacility(app.NpcDef.ID)");
local executedSharing_method = FacilityMoriver_type_def:get_method("executedSharing(app.FacilityMoriver.MoriverInfo)");
local MoriverInfos_field = FacilityMoriver_type_def:get_field("_MoriverInfos");

local MoriverInfos_type_def = MoriverInfos_field:get_type();
local get_Count_method = MoriverInfos_type_def:get_method("get_Count");
local get_Item_method = MoriverInfos_type_def:get_method("get_Item(System.Int32)");

local MoriverInfo_type_def = get_Item_method:get_return_type();
local NpcId_field = MoriverInfo_type_def:get_field("_NpcId");
local FacilityId_field = MoriverInfo_type_def:get_field("_FacilityId");
local ItemFromMoriver_field = MoriverInfo_type_def:get_field("ItemFromMoriver");
local ItemFromPlayer_field = MoriverInfo_type_def:get_field("ItemFromPlayer");

local ItemWork_type_def = ItemFromMoriver_field:get_type();
local get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
local Num_field = ItemWork_type_def:get_field("Num");

local FacilityManager_type_def = sdk.find_type_definition("app.FacilityManager");
local get_Pugee_method = FacilityManager_type_def:get_method("get_Pugee");

local FacilityPugee_type_def = get_Pugee_method:get_return_type();
local isEnableCoolTimer_method = FacilityPugee_type_def:get_method("isEnableCoolTimer");
local stroke_method = FacilityPugee_type_def:get_method("stroke(System.Boolean)");

local FacilityRallus_type_def = sdk.find_type_definition("app.FacilityRallus");
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local resetSupplyNum_method = FacilityRallus_type_def:get_method("resetSupplyNum");
local Event_field = FacilityRallus_type_def:get_field("_Event");

local execute_method = Event_field:get_type():get_method("execute");

local getRewardItemData_method = sdk.find_type_definition("app.GimmickRewardUtil"):get_method("getRewardItemData(app.GimmickDef.ID, app.FieldDef.STAGE, System.Boolean, System.Int32)");

local get_Item_method = getRewardItemData_method:get_return_type():get_method("get_Item(System.Int32)");

local SendItemInfo_type_def = get_Item_method:get_return_type();
local get_LogType_method = SendItemInfo_type_def:get_method("get_LogType");
local ItemId_field = SendItemInfo_type_def:get_field("<ItemId>k__BackingField");
local Num_field = SendItemInfo_type_def:get_field("<Num>k__BackingField");

local ItemID_type_def = get_ItemId_method:get_return_type();
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

local EnemyID_INVALID = sdk.find_type_definition("app.EnemyDef.ID"):get_field("INVALID"):get_data(nil);
local GM262_000_00 = sdk.find_type_definition("app.GimmickDef.ID"):get_field("GM262_000_00"):get_data(nil);
local ST502 = sdk.find_type_definition("app.FieldDef.STAGE"):get_field("ST502"):get_data(nil);

local completedMoriver = nil;

local function getItems(itemId, itemNum)
    changeItemNum_method:call(nil, itemId, getItemNum_method:call(nil, itemId, STOCK_TYPE.BOX) + itemNum, STOCK_TYPE.BOX);
    addItemLog_method:call(nil, itemId, itemNum, false, false, EnemyID_INVALID);
end

local function getMoriverItems(moriverInfo)
    local ItemFromMoriver = ItemFromMoriver_field:get_data(moriverInfo);
    local gettingItemId = get_ItemId_method:call(ItemFromMoriver);
    if gettingItemId ~= ItemID.NONE and gettingItemId < ItemID.MAX then
        local gettingNum = Num_field:get_data(ItemFromMoriver);
        if gettingNum > 0 then
            getItems(gettingItemId, gettingNum);
            table.insert(completedMoriver, moriverInfo);
        end
    end
end

sdk.hook(CollectionNPCParam_type_def:get_method("addCollectionItem(app.ItemDef.ID, System.Int16)"), Constants.getObject, function()
    local CollectionNPCParam = thread.get_hook_storage()["this"];
    local ItemWorks_array = get_CollectionItem_method:call(CollectionNPCParam);
    for i = 0, Collection_MAX_ITEM_NUM - 1 do
        local ItemWork = ItemWorks_array:get_element(i);
        local ItemId = get_ItemId_method:call(ItemWork);
        if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
            local ItemNum = Num_field:get_data(ItemWork);
            if ItemNum > 0 then
                getItems(ItemId, ItemNum);
            else
                break;
            end
        else
            break;
        end
    end
    clearAllCollectionItem_method:call(CollectionNPCParam);
end);

sdk.hook(LargeWorkshopParam_type_def:get_method("addRewardItem(app.ItemDef.ID, System.Int16)"), Constants.getObject, function()
    local LargeWorkshopParam = thread.get_hook_storage()["this"];
    local ItemWorks_array = get_Rewards_method:call(LargeWorkshopParam);
    for i = 0, LargeWorkshop_MAX_ITEM_NUM - 1 do
        local ItemWork = ItemWorks_array:get_element(i);
        local ItemId = get_ItemId_method:call(ItemWork);
        if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
            local ItemNum = Num_field:get_data(ItemWork);
            if ItemNum > 0 then
                getItems(ItemId, ItemNum);
                clearRewardItem_method:call(LargeWorkshopParam, i);
            else
                break;
            end
        else
            break;
        end
    end
end);

sdk.hook(FacilityDining_type_def:get_method("addSuplyNum"), Constants.getObject, function()
    supplyFood_method:call(thread.get_hook_storage()["this"]);
end);

local FacilityMoriver = nil;
sdk.hook(FacilityMoriver_type_def:get_method("update"), function(args)
    if FacilityMoriver == nil then
        FacilityMoriver = sdk.to_managed_object(args[2]);
    end
end, function()
    if get__HavingCampfire_method:call(FacilityMoriver) == true then
        local MoriverInfos = MoriverInfos_field:get_data(FacilityMoriver);
        local Count = get_Count_method:call(MoriverInfos);
        if Count > 0 then
            completedMoriver = {};
            for i = 0, Count - 1 do
                local MoriverInfo = get_Item_method:call(MoriverInfos, i);
                if isEnableMoriverFacility_method:call(FacilityMoriver, NpcId_field:get_data(MoriverInfo)) == true then
                    local FacilityId = FacilityId_field:get_data(MoriverInfo);
                    if FacilityId == FacilityID.SHARING then
                        getMoriverItems(MoriverInfo);
                    elseif FacilityId == FacilityID.SWOP then
                        local ItemFromPlayer = ItemFromPlayer_field:get_data(MoriverInfo);
                        local givingItemId = get_ItemId_method:call(ItemFromPlayer);
                        if givingItemId ~= ItemID.NONE and givingItemId < ItemID.MAX then
                            local isSuccessSWOP = true;
                            local givingNum = Num_field:get_data(ItemFromPlayer);
                            local pouchNum = getItemNum_method:call(nil, giveItemId, STOCK_TYPE.POUCH);
                            if pouchNum >= givingNum then
                                payItem_method:call(nil, givingItemId, givingNum, STOCK_TYPE.POUCH);
                            else
                                local boxNum = getItemNum_method:call(nil, givingItemId, STOCK_TYPE.BOX);
                                if (pouchNum + boxNum) >= givingNum then
                                    payItem_method:call(nil, givingItemId, pouchNum, STOCK_TYPE.POUCH);
                                    payItem_method:call(nil, givingItemId, givingNum - pouchNum, STOCK_TYPE.BOX);
                                elseif boxNum >= givingNum then
                                    payItem_method:call(nil, givingItemId, givingNum, STOCK_TYPE.BOX);
                                else
                                    isSuccessSWOP = false;
                                end
                            end
                            if isSuccessSWOP == true then
                                getMoriverItems(MoriverInfo);
                            end
                        end
                    end
                end
            end
            for _, completed in ipairs(completedMoriver) do
                executedSharing_method:call(FacilityMoriver, completed);
            end
            completedMoriver = nil;
        end
    end
end);

sdk.hook(FacilityManager_type_def:get_method("update"), function(args)
    if Constants.FacilityManager == nil then
        Constants.FacilityManager = sdk.to_managed_object(args[2]);
    end
end, function()
    local FacilityPugee = get_Pugee_method:call(Constants.FacilityManager);
    if isEnableCoolTimer_method:call(FacilityPugee) == false then
        stroke_method:call(FacilityPugee, true);
    end
end);

sdk.hook(FacilityRallus_type_def:get_method("supplyTimerGoal(app.cFacilityTimer)"), Constants.getObject, function()
    local FacilityRallus = thread.get_hook_storage()["this"];
    local SupplyNum = get_SupplyNum_method:call(FacilityRallus);
    while SupplyNum > 0 do
        SupplyNum = SupplyNum - 1;
        local SendItemInfo = get_Item_method:call(getRewardItemData_method:call(nil, GM262_000_00, ST502, nil, nil), 0);
        local ItemId = ItemId_field:get_data(SendItemInfo);
        if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
            local Num = Num_field:get_data(SendItemInfo);
            if Num > 0 then
                local newItemNum = Num + getItemNum_method:call(nil, ItemId, STOCK_TYPE.BOX);
                local capacity = getItemCapacity_method:call(nil, ItemId, STOCK_TYPE.BOX);
                if newItemNum > capacity then
                    sendItemToBox_method:call(nil, get_LogType_method:call(SendItemInfo), SendItemInfo, true, EnemyID_INVALID, false);
                    changeItemNumFromDialogue_method:call(nil, ItemId, Num, STOCK_TYPE.BOX, true);
                    sellItem_method:call(nil, ItemId, newItemNum - capacity);
                else
                    sendItemToBox_method:call(nil, get_LogType_method:call(SendItemInfo), SendItemInfo, true, EnemyID_INVALID, true);
                end
            end
        end
    end
    execute_method:call(Event_field:get_data(FacilityRallus));
    resetSupplyNum_method:call(FacilityRallus);
end);