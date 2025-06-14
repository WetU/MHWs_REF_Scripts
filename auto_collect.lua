local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local ipairs = Constants.ipairs;
local table = Constants.table;

local payItem_method = sdk.find_type_definition("app.FacilityUtil"):get_method("payItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local getItemNum_method = Constants.ItemUtil_type_def:get_method("getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static
local changeItemNum_method = Constants.ItemUtil_type_def:get_method("changeItemNum(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local addItemLog_method = sdk.find_type_definition("app.ChatLogUtil"):get_method("addItemLog(app.ItemDef.ID, System.Int16, System.Boolean, System.Boolean, app.EnemyDef.ID)"); -- static

local CollectionNPCParam_type_def = sdk.find_type_definition("app.savedata.cCollectionNPCParam");
local get_CollectionItem_method = CollectionNPCParam_type_def:get_method("get_CollectionItem");
local clearCollectionItem_method = CollectionNPCParam_type_def:get_method("clearCollectionItem(System.Int32)");
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

local EnemyID_INVALID = sdk.find_type_definition("app.EnemyDef.ID"):get_field("INVALID"):get_data(nil); -- static

local completedMoriver = nil;

local function getItems(itemId, itemNum)
    changeItemNum_method:call(nil, itemId, getItemNum_method:call(nil, itemId, STOCK_TYPE.BOX) + itemNum, STOCK_TYPE.BOX);
    addItemLog_method:call(nil, itemId, itemNum, false, false, EnemyID_INVALID);
end

local function getFacilityItems(obj, facilityType)
    if facilityType == 1 then
        local ItemWorks_array = get_CollectionItem_method:call(obj);
        for i = 0, Collection_MAX_ITEM_NUM - 1 do
            local ItemWork = ItemWorks_array:get_element(i);
            local ItemId = get_ItemId_method:call(ItemWork);
            if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
                local ItemNum = Num_field:get_data(ItemWork);
                if ItemNum > 0 then
                    getItems(ItemId, ItemNum);
                    clearCollectionItem_method:call(obj, i);
                else
                    break;
                end
            else
                break;
            end
        end
    elseif facilityType == 2 then
        local ItemWorks_array = get_Rewards_method:call(obj);
        for i = 0, LargeWorkshop_MAX_ITEM_NUM - 1 do
            local ItemWork = ItemWorks_array:get_element(i);
            local ItemId = get_ItemId_method:call(ItemWork);
            if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
                local ItemNum = Num_field:get_data(ItemWork);
                if ItemNum > 0 then
                    getItems(ItemId, ItemNum);
                    clearRewardItem_method:call(obj, i);
                else
                    break;
                end
            else
                break;
            end
        end
    end
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
    getFacilityItems(thread.get_hook_storage()["this"], 1);
end);

sdk.hook(LargeWorkshopParam_type_def:get_method("addRewardItem(app.ItemDef.ID, System.Int16)"), Constants.getObject, function()
    getFacilityItems(thread.get_hook_storage()["this"], 2);
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