local Constants = _G.require("Constants/Constants");
local sdk = Constants.sdk;
local thread = Constants.thread;

local ipairs = Constants.ipairs;
local table = Constants.table;

local payItem_method = sdk.find_type_definition("app.FacilityUtil"):get_method("payItem(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE)"); -- static

local changeItemNumFromDialogue_method = Constants.ItemUtil_type_def:get_method("changeItemNumFromDialogue(app.ItemDef.ID, System.Int16, app.ItemUtil.STOCK_TYPE, System.Boolean)"); -- static
local getItemNum_method = Constants.ItemUtil_type_def:get_method("getItemNum(app.ItemDef.ID, app.ItemUtil.STOCK_TYPE)"); -- static

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

local FacilityManager_type_def = sdk.find_type_definition("app.FacilityManager");
local get_Moriver_method = FacilityManager_type_def:get_method("get_Moriver");
local get_Pugee_method = FacilityManager_type_def:get_method("get_Pugee");

local FacilityMoriver_type_def = get_Moriver_method:get_return_type();
local get__HavingCampfire_method = FacilityMoriver_type_def:get_method("get__HavingCampfire");
local isEnableMoriverFacility_method = FacilityMoriver_type_def:get_method("isEnableMoriverFacility(app.NpcDef.ID)");
local executedSharing_method = FacilityMoriver_type_def:get_method("executedSharing(app.FacilityMoriver.MoriverInfo)");
local MoriverInfos_field = FacilityMoriver_type_def:get_field("_MoriverInfos");

local MoriverInfos_type_def = MoriverInfos_field:get_type();
local Moriver_get_Count_method = MoriverInfos_type_def:get_method("get_Count");
local Moriver_get_Item_method = MoriverInfos_type_def:get_method("get_Item(System.Int32)");
local Moriver_Remove_method = MoriverInfos_type_def:get_method("Remove(app.FacilityMoriver.MoriverInfo)");

local MoriverInfo_type_def = Moriver_get_Item_method:get_return_type();
local NpcId_field = MoriverInfo_type_def:get_field("_NpcId");
local FacilityId_field = MoriverInfo_type_def:get_field("_FacilityId");
local ItemFromMoriver_field = MoriverInfo_type_def:get_field("ItemFromMoriver");
local ItemFromPlayer_field = MoriverInfo_type_def:get_field("ItemFromPlayer");

local ItemWork_type_def = ItemFromMoriver_field:get_type();
local get_ItemId_method = ItemWork_type_def:get_method("get_ItemId");
local ItemWork_Num_field = ItemWork_type_def:get_field("Num");

local getCurrentUserSaveData_method = sdk.find_type_definition("app.SaveDataManager"):get_method("getCurrentUserSaveData");

local get_BasicData_method = getCurrentUserSaveData_method:get_return_type():get_method("get_BasicData");

local BasicParam_type_def = get_BasicData_method:get_return_type();
local setMoriverNum_method = BasicParam_type_def:get_method("setMoriverNum(System.Int32)");
local getMoriverNum_method = BasicParam_type_def:get_method("getMoriverNum");

local FacilityPugee_type_def = get_Pugee_method:get_return_type();
local isEnableCoolTimer_method = FacilityPugee_type_def:get_method("isEnableCoolTimer");
local stroke_method = FacilityPugee_type_def:get_method("stroke(System.Boolean)");

local FacilityRallus_type_def = sdk.find_type_definition("app.FacilityRallus");
local get_SupplyNum_method = FacilityRallus_type_def:get_method("get_SupplyNum");
local resetSupplyNum_method = FacilityRallus_type_def:get_method("resetSupplyNum");
local Event_field = FacilityRallus_type_def:get_field("_Event");

local execute_method = Event_field:get_type():get_method("execute");

local getRewardItemData_method = sdk.find_type_definition("app.GimmickRewardUtil"):get_method("getRewardItemData(app.GimmickDef.ID, app.FieldDef.STAGE, System.Boolean, System.Int32)");

local SendItemInfoList_type_def = getRewardItemData_method:get_return_type();
local SendItemInfo_get_Count_method = SendItemInfoList_type_def:get_method("get_Count");
local SendItemInfo_get_Item_method = SendItemInfoList_type_def:get_method("get_Item(System.Int32)");
local SendItemInfo_Clear_method = SendItemInfoList_type_def:get_method("Clear");

local SendItemInfo_type_def = SendItemInfo_get_Item_method:get_return_type();
local ItemId_field = SendItemInfo_type_def:get_field("<ItemId>k__BackingField");
local SendItemInfo_Num_field = SendItemInfo_type_def:get_field("<Num>k__BackingField");

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

local GM262_000_00 = sdk.find_type_definition("app.GimmickDef.ID"):get_field("GM262_000_00"):get_data(nil);
local ST502 = sdk.find_type_definition("app.FieldDef.STAGE"):get_field("ST502"):get_data(nil);

local RallusItemCount = {
    [1] = 0,
    [2] = -1,
    [3] = -2,
    [4] = -3,
    [5] = -4
};

local completedMorivers = {
    Sharing = nil,
    SWOP = nil
};

local function execMoriver(facilityMoriver)
    local MoriverInfos = MoriverInfos_field:get_data(facilityMoriver);
    local Count = Moriver_get_Count_method:call(MoriverInfos);
    if Count > 0 then
        completedMorivers.Sharing = {};
        completedMorivers.SWOP = {};
        for i = 0, Count - 1 do
            local MoriverInfo = Moriver_get_Item_method:call(MoriverInfos, i);
            if isEnableMoriverFacility_method:call(facilityMoriver, NpcId_field:get_data(MoriverInfo)) == true then
                local FacilityId = FacilityId_field:get_data(MoriverInfo);
                if FacilityId == FacilityID.SHARING then
                    local ItemFromMoriver = ItemFromMoriver_field:get_data(MoriverInfo);
                    local gettingItemId = get_ItemId_method:call(ItemFromMoriver);
                    if gettingItemId ~= ItemID.NONE and gettingItemId < ItemID.MAX then
                        local gettingNum = ItemWork_Num_field:get_data(ItemFromMoriver);
                        if gettingNum > 0 then
                            changeItemNumFromDialogue_method:call(nil, gettingItemId, gettingNum, STOCK_TYPE.BOX, true);
                        end
                    end
                    table.insert(completedMorivers.Sharing, MoriverInfo);
                elseif FacilityId == FacilityID.SWOP then
                    local ItemFromPlayer = ItemFromPlayer_field:get_data(MoriverInfo);
                    local givingItemId = get_ItemId_method:call(ItemFromPlayer);
                    if givingItemId ~= ItemID.NONE and givingItemId < ItemID.MAX then
                        local isSuccessSWOP = true;
                        local givingNum = ItemWork_Num_field:get_data(ItemFromPlayer);
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
                            local ItemFromMoriver = ItemFromMoriver_field:get_data(MoriverInfo);
                            local gettingItemId = get_ItemId_method:call(ItemFromMoriver);
                            if gettingItemId ~= ItemID.NONE and gettingItemId < ItemID.MAX then
                                local gettingNum = ItemWork_Num_field:get_data(ItemFromMoriver);
                                if gettingNum > 0 then
                                    changeItemNumFromDialogue_method:call(nil, gettingItemId, gettingNum, STOCK_TYPE.BOX, true);
                                end
                            end
                            table.insert(completedMorivers.SWOP, MoriverInfo);
                        end
                    end
                end
            end
        end
        if #completedMorivers.Sharing > 0 then
            for _, completedSharing in ipairs(completedMorivers.Sharing) do
                executedSharing_method:call(facilityMoriver, completedSharing);
            end
        end
        completedMorivers.Sharing = nil;
        local completedSWOPcounts = #completedMorivers.SWOP;
        if completedSWOPcounts > 0 then
            for _, completedSWOP in ipairs(completedMorivers.SWOP) do
                Moriver_Remove_method:call(MoriverInfos, completedSWOP);
            end
        end
        completedMorivers.SWOP = nil;
        local BasicData = get_BasicData_method:call(getCurrentUserSaveData_method:call(sdk.get_managed_singleton("app.SaveDataManager")));
        setMoriverNum_method:call(BasicData, getMoriverNum_method:call(BasicData) - completedSWOPcounts);
    end
end

sdk.hook(CollectionNPCParam_type_def:get_method("addCollectionItem(app.ItemDef.ID, System.Int16)"), Constants.getObject, function()
    local CollectionNPCParam = thread.get_hook_storage()["this"];
    local ItemWorks_array = get_CollectionItem_method:call(CollectionNPCParam);
    for i = 0, Collection_MAX_ITEM_NUM - 1 do
        local ItemWork = ItemWorks_array:get_element(i);
        local ItemId = get_ItemId_method:call(ItemWork);
        if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
            local ItemNum = ItemWork_Num_field:get_data(ItemWork);
            if ItemNum > 0 then
                changeItemNumFromDialogue_method:call(nil, ItemId, ItemNum, STOCK_TYPE.BOX, true);
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
            local ItemNum = ItemWork_Num_field:get_data(ItemWork);
            if ItemNum > 0 then
                changeItemNumFromDialogue_method:call(nil, ItemId, ItemNum, STOCK_TYPE.BOX, true);
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

sdk.hook(sdk.find_type_definition("app.IngameState"):get_method("enter"), nil, function()
    local FacilityMoriver = get_Moriver_method:call(sdk.get_managed_singleton("app.FacilityManager"));
    if get__HavingCampfire_method:call(FacilityMoriver) == true then
        execMoriver(FacilityMoriver);
    end
end);

sdk.hook(FacilityMoriver_type_def:get_method("startCampfire(System.Boolean)"), Constants.getObject, function()
    execMoriver(thread.get_hook_storage()["this"]);
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
    local SendItemInfo_List = getRewardItemData_method:call(nil, GM262_000_00, ST502, true, RallusItemCount[get_SupplyNum_method:call(FacilityRallus)]);
    for i = 0, SendItemInfo_get_Count_method:call(SendItemInfo_List) - 1 do
        local SendItemInfo = SendItemInfo_get_Item_method:call(SendItemInfo_List, i);
        local ItemId = ItemId_field:get_data(SendItemInfo);
        if ItemId ~= ItemID.NONE and ItemId < ItemID.MAX then
            local Num = SendItemInfo_Num_field:get_data(SendItemInfo);
            if Num > 0 then
                changeItemNumFromDialogue_method:call(nil, ItemId, Num, STOCK_TYPE.BOX, true);
            end
        end
    end
    execute_method:call(Event_field:get_data(FacilityRallus));
    SendItemInfo_Clear_method:call(SendItemInfo_List);
    resetSupplyNum_method:call(FacilityRallus);
end);