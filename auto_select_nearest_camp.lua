local Constants = _G.require("Constants/Constants");

local type = Constants.type;

local sdk = Constants.sdk;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

local config = json.load_file("auto_select_nearest_camp.json") or {isEnabled = true};
if config.isEnabled == nil or type(config.isEnabled) ~= "boolean" then
    config.isEnabled = true;
end

local function save_config()
    json.dump_file("auto_select_nearest_camp.json", config);
end

local distance_method = sdk.find_type_definition("via.MathEx"):get_method("distance(via.vec3, via.vec3)"); -- static

local get_MAP3D_method = Constants.GUIManager_type_def:get_method("get_MAP3D");

local get_MapStageDrawData_method = get_MAP3D_method:get_return_type():get_method("get_MapStageDrawData");

local getDrawData_method = get_MapStageDrawData_method:get_return_type():get_method("getDrawData(app.FieldDef.STAGE)");

local get_AreaIconPosList_method = getDrawData_method:get_return_type():get_method("get_AreaIconPosList");

local AreaIconPosList_type_def = get_AreaIconPosList_method:get_return_type();
local AreaIconPosList_get_Count_method = AreaIconPosList_type_def:get_method("get_Count");
local AreaIconPosList_get_Item_method = AreaIconPosList_type_def:get_method("get_Item(System.Int32)");

local AreaIconData_type_def = AreaIconPosList_get_Item_method:get_return_type();
local get_AreaIconPos_method = AreaIconData_type_def:get_method("get_AreaIconPos");
local get_AreaNum_method = AreaIconData_type_def:get_method("get_AreaNum");

local Int32_value_field = get_AreaNum_method:get_return_type():get_field("m_value");

local GUI050001_type_def = sdk.find_type_definition("app.GUI050001");
local get_CurrentStartPointList_method = GUI050001_type_def:get_method("get_CurrentStartPointList");
local get_QuestOrderParam_method = GUI050001_type_def:get_method("get_QuestOrderParam");
local setCurrentSelectStartPointIndex_method = GUI050001_type_def:get_method("setCurrentSelectStartPointIndex(System.Int32)");
local StartPointList_field = GUI050001_type_def:get_field("_StartPointList");

local StartPointInfoList_type_def = get_CurrentStartPointList_method:get_return_type();
local StartPointInfoList_get_Count_method = StartPointInfoList_type_def:get_method("get_Count");
local StartPointInfoList_get_Item_method = StartPointInfoList_type_def:get_method("get_Item(System.Int32)");

local get_BeaconGimmick_method = StartPointInfoList_get_Item_method:get_return_type():get_method("get_BeaconGimmick");

local getPos_method = get_BeaconGimmick_method:get_return_type():get_method("getPos");

local QuestViewData_field = get_QuestOrderParam_method:get_return_type():get_field("QuestViewData");

local GUIQuestViewData_type_def = QuestViewData_field:get_type();
local get_TargetEmStartArea_method = GUIQuestViewData_type_def:get_method("get_TargetEmStartArea");
local get_Stage_method = GUIQuestViewData_type_def:get_method("get_Stage");

local InputCtrl_field = StartPointList_field:get_type():get_field("_InputCtrl");

local FluentScrollList_type_def = sdk.find_type_definition("ace.cGUIInputCtrl_FluentScrollList`2<app.GUIID.ID,app.GUIFunc.TYPE>");
local getSelectedIndex_method = FluentScrollList_type_def:get_method("getSelectedIndex");
local selectPrevItem_method = FluentScrollList_type_def:get_method("selectPrevItem");
local selectNextItem_method = FluentScrollList_type_def:get_method("selectNextItem");

local hook_datas = {
    hasData = false,
    GUI050001 = nil,
    inputCtrl = nil,
    targetCampIdx = nil,
    selectMethod = nil
};

local function clear_datas()
    hook_datas = {
        hasData = false,
        GUI050001 = nil,
        inputCtrl = nil,
        targetCampIdx = nil,
        selectMethod = nil
    };
end

sdk.hook(GUI050001_type_def:get_method("initStartPoint"), function(args)
    if config.isEnabled == true then
        hook_datas.GUI050001 = sdk.to_managed_object(args[2]);
    end
end, function()
    if config.isEnabled == true then
        local GUI050001 = hook_datas.GUI050001;
        local startPoint_list = get_CurrentStartPointList_method:call(GUI050001);
        local list_size = StartPointInfoList_get_Count_method:call(startPoint_list);
        if list_size > 1 then
            local QuestViewData = QuestViewData_field:get_data(get_QuestOrderParam_method:call(GUI050001));
            local targetEmStartArea = Int32_value_field:get_data(get_TargetEmStartArea_method:call(QuestViewData):get_element(0));
            local areaIconPosList = get_AreaIconPosList_method:call(getDrawData_method:call(get_MapStageDrawData_method:call(get_MAP3D_method:call(Constants.GUIManager)), get_Stage_method:call(QuestViewData)));
            for i = 0, AreaIconPosList_get_Count_method:call(areaIconPosList) - 1 do
                local AreaIconData = AreaIconPosList_get_Item_method:call(areaIconPosList, i);
                if get_AreaNum_method:call(AreaIconData) == targetEmStartArea then
                    local shortest_distance = nil;
                    for j = 0, list_size - 1 do
                        local distance = distance_method:call(nil, get_AreaIconPos_method:call(AreaIconData), getPos_method:call(get_BeaconGimmick_method:call(StartPointInfoList_get_Item_method:call(startPoint_list, j))));
                        if j == 0 or distance < shortest_distance then
                            shortest_distance = distance;
                            hook_datas.targetCampIdx = j;
                        end
                    end
                    if hook_datas.targetCampIdx > 0 then
                        setCurrentSelectStartPointIndex_method:call(hook_datas.GUI050001, hook_datas.targetCampIdx);
                        hook_datas.inputCtrl = InputCtrl_field:get_data(StartPointList_field:get_data(hook_datas.GUI050001));
                        hook_datas.selectMethod = hook_datas.targetCampIdx + 1 <= list_size / 2 and selectPrevItem_method or selectNextItem_method;
                        hook_datas.hasData = true;
                    else
                        clear_datas();
                    end
                    break;
                end
            end
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI050001_AcceptList"):get_method("onVisibleUpdate"), nil, function()
    if config.isEnabled == true and hook_datas.hasData == true then
        local inputCtrl = hook_datas.inputCtrl;
        if getSelectedIndex_method:call(inputCtrl) ~= hook_datas.targetCampIdx then
            hook_datas.selectMethod:call(inputCtrl);
        else
            clear_datas();
        end
    end
end);

sdk.hook(GUI050001_type_def:get_method("onClose"), function(args)
    if config.isEnabled == true then
        clear_datas();
    end
end);

re.on_config_save(save_config);

re.on_draw_ui(function()
    if imgui.tree_node("Auto-Select Nearest Camp") == true then
        local changed = false;
        changed, config.isEnabled = imgui.checkbox("Enabled", config.isEnabled);
        if changed == true then
            save_config();
        end
        imgui.tree_pop();
    end
end);