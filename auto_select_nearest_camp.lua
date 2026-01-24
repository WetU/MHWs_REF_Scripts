local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local find_type_definition = Constants.find_type_definition;
local create_int32 = Constants.create_int32;
local hook = Constants.hook;
local to_ptr = Constants.to_ptr;

local get_hook_storage = Constants.get_hook_storage;

local getThisPtr = Constants.getThisPtr;

local GenericList_get_Count_method = Constants.GenericList_get_Count_method;
local GenericList_get_Item_method = Constants.GenericList_get_Item_method;

local distance_method = find_type_definition("via.MathEx"):get_method("distance(via.vec3, via.vec3)"); -- static

local getFloorNumFromAreaNum_method = find_type_definition("app.GUIUtilApp.MapUtil"):get_method("getFloorNumFromAreaNum(app.FieldDef.STAGE, System.Int32)"); -- static

local AreaIconData_type_def = find_type_definition("app.user_data.MapStageDrawData.cAreaIconData");
local get_AreaIconPos_method = AreaIconData_type_def:get_method("get_AreaIconPos");
local get_AreaNum_method = AreaIconData_type_def:get_method("get_AreaNum");

local Int32_value_field = get_AreaNum_method:get_return_type():get_field("m_value");

local GUI050001_type_def = find_type_definition("app.GUI050001");
local get_CurrentStartPointList_method = GUI050001_type_def:get_method("get_CurrentStartPointList");
local get_QuestOrderParam_method = GUI050001_type_def:get_method("get_QuestOrderParam");
local setCurrentSelectStartPointIndex_method = GUI050001_type_def:get_method("setCurrentSelectStartPointIndex(System.Int32)");
local StartPointList_field = GUI050001_type_def:get_field("_StartPointList");

local get_BeaconGimmick_method = find_type_definition("app.cStartPointInfo"):get_method("get_BeaconGimmick");

local GUIBeaconGimmick_type_def = get_BeaconGimmick_method:get_return_type();
local getPos_method = GUIBeaconGimmick_type_def:get_method("getPos");
local getExistAreaInfo_method = GUIBeaconGimmick_type_def:get_method("getExistAreaInfo");

local FieldAreaInfo_type_def = getExistAreaInfo_method:get_return_type();
local get_MapAreaNumSafety_method = FieldAreaInfo_type_def:get_method("get_MapAreaNumSafety");
local get_MapFloorNumSafety_method = FieldAreaInfo_type_def:get_method("get_MapFloorNumSafety");

local QuestOrderParam_type_def = get_QuestOrderParam_method:get_return_type();
local get_IsSameStageDeclaration_method = QuestOrderParam_type_def:get_method("get_IsSameStageDeclaration");
local QuestViewData_field = QuestOrderParam_type_def:get_field("QuestViewData");

local GUIQuestViewData_type_def = QuestViewData_field:get_type();
local get_TargetEmStartArea_method = GUIQuestViewData_type_def:get_method("get_TargetEmStartArea");
local get_Stage_method = GUIQuestViewData_type_def:get_method("get_Stage");

local InputCtrl_field = StartPointList_field:get_type():get_field("_InputCtrl");

local requestSelectIndexCore_method = find_type_definition("ace.cGUIInputCtrl_FluentScrollList`2<app.GUIID.ID,app.GUIFunc.TYPE>"):get_method("requestSelectIndexCore(System.Int32, System.Int32)");

local STAGES = Constants.STAGES;

local DrawDatas = {};

local function setVars(GUI050001, startPointIdx)
    setCurrentSelectStartPointIndex_method:call(GUI050001, startPointIdx);
    requestSelectIndexCore_method:call(InputCtrl_field:get_data(StartPointList_field:get_data(GUI050001)), startPointIdx, 0);
end

hook(GUI050001_type_def:get_method("mapForceSelectFloor"), getThisPtr, function(retval)
    local this_ptr = get_hook_storage().this_ptr;
    local QuestOrderParam = get_QuestOrderParam_method:call(this_ptr);
    if get_IsSameStageDeclaration_method:call(QuestOrderParam) == false then
        local startPointlist = get_CurrentStartPointList_method:call(this_ptr);
        local startPointlist_size = GenericList_get_Count_method:call(startPointlist);
        if startPointlist_size > 1 then
            local QuestViewData = QuestViewData_field:get_data(QuestOrderParam);
            local TargetEmStartArea_array = get_TargetEmStartArea_method:call(QuestViewData);
            local Stage = get_Stage_method:call(QuestViewData);
            local areaIconPosList = nil;
            local sameFloor_shortest_distance, sameFloor_idx, sameFloor_FloorNum = nil, nil, nil;
            local diffFloor_shortest_distance, diffFloor_idx, diffFloor_FloorNum = nil, nil, nil;
            for i = 0, TargetEmStartArea_array:get_size() - 1 do
                local targetEmAreaNum = Int32_value_field:get_data(TargetEmStartArea_array:get_element(i));
                if targetEmAreaNum ~= nil then
                    local areaIconPos, targetEmFloorNum = nil, nil;
                    for j = 0, startPointlist_size - 1 do
                        local BeaconGimmick = get_BeaconGimmick_method:call(GenericList_get_Item_method:call(startPointlist, j));
                        local FieldAreaInfo = getExistAreaInfo_method:call(BeaconGimmick);
                        if targetEmAreaNum == get_MapAreaNumSafety_method:call(FieldAreaInfo) then
                            if j > 0 then
                                setVars(this_ptr, j);
                                return to_ptr(create_int32(get_MapFloorNumSafety_method:call(FieldAreaInfo)));
                            end
                            return retval;
                        end
                        if areaIconPos == nil then
                            if areaIconPosList == nil then
                                areaIconPosList = DrawDatas[Stage];
                            end
                            areaIconPos = areaIconPosList[targetEmAreaNum];
                        end
                        if areaIconPos ~= nil then
                            if targetEmFloorNum == nil then
                                targetEmFloorNum = getFloorNumFromAreaNum_method:call(nil, Stage, targetEmAreaNum);
                            end
                            local distance = distance_method:call(nil, areaIconPos, getPos_method:call(BeaconGimmick));
                            local Beacon_FloorNum = get_MapFloorNumSafety_method:call(FieldAreaInfo);
                            if Beacon_FloorNum == targetEmFloorNum then
                                if sameFloor_idx == nil or distance < sameFloor_shortest_distance then
                                    sameFloor_shortest_distance, sameFloor_idx, sameFloor_FloorNum = distance, j, Beacon_FloorNum;
                                end
                            elseif diffFloor_idx == nil or distance < diffFloor_shortest_distance then
                                diffFloor_shortest_distance, diffFloor_idx, diffFloor_FloorNum = distance, j, Beacon_FloorNum;
                            end
                        end
                    end
                end
            end
            if sameFloor_shortest_distance ~= nil and diffFloor_shortest_distance ~= nil and diffFloor_shortest_distance < (sameFloor_shortest_distance * 0.45) then
                if diffFloor_idx > 0 then
                    setVars(this_ptr, diffFloor_idx);
                    return to_ptr(create_int32(diffFloor_FloorNum));
                end
            elseif sameFloor_idx ~= nil and sameFloor_idx > 0 then
                setVars(this_ptr, sameFloor_idx);
                return to_ptr(create_int32(sameFloor_FloorNum));
            elseif diffFloor_idx ~= nil and diffFloor_idx > 0 then
                setVars(this_ptr, diffFloor_idx);
                return to_ptr(create_int32(diffFloor_FloorNum));
            end
        end
    end
    return retval;
end);

do
    local MapStageDrawData = Constants.call_object_func(Constants.call_native_func(Constants.GUIManager, Constants.GUIManager_type_def, "get_MAP3D"), "get_MapStageDrawData");
    if MapStageDrawData ~= nil then
        local getDrawData_method = MapStageDrawData:get_type_definition():get_method("getDrawData(app.FieldDef.STAGE)");
        local get_AreaIconPosList_method = getDrawData_method:get_return_type():get_method("get_AreaIconPosList");
        for _, stageID in pairs(STAGES) do
            local DrawData = getDrawData_method:call(MapStageDrawData, stageID);
            if DrawData ~= nil then
                local AreaIconPosList = get_AreaIconPosList_method:call(DrawData);
                if AreaIconPosList ~= nil then
                    DrawDatas[stageID] = {};
                    local thisStage = DrawDatas[stageID];
                    for i = 0, GenericList_get_Count_method:call(AreaIconPosList) - 1 do
                        local AreaIconData = GenericList_get_Item_method:call(AreaIconPosList, i);
                        if AreaIconData ~= nil then
                            thisStage[get_AreaNum_method:call(AreaIconData)] = get_AreaIconPos_method:call(AreaIconData);
                        end
                    end
                end
            end
        end
    end
end