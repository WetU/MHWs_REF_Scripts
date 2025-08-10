local Constants = _G.require("Constants/Constants");

local type = Constants.type;

local sdk = Constants.sdk;
local json = Constants.json;
local re = Constants.re;
local imgui = Constants.imgui;

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

local ActiveQuestData_field = get_QuestOrderParam_method:get_return_type():get_field("ActiveQuestData");

local ActiveQuestData_type_def = ActiveQuestData_field:get_type();
local getTargetEmSetAreaNo_method = ActiveQuestData_type_def:get_method("getTargetEmSetAreaNo");
local getStage_method = ActiveQuestData_type_def:get_method("getStage");

local InputCtrl_field = StartPointList_field:get_type():get_field("_InputCtrl");

local FluentScrollList_type_def = sdk.find_type_definition("ace.cGUIInputCtrl_FluentScrollList`2<app.GUIID.ID,app.GUIFunc.TYPE>");
local getSelectedIndex_method = FluentScrollList_type_def:get_method("getSelectedIndex");
local selectNextItem_method = FluentScrollList_type_def:get_method("selectNextItem");

local Int32_value_field = getSelectedIndex_method:get_return_type():get_field("m_value");

local config = json.load_file("auto_select_nearest_camp.json") or {isEnabled = true};
if config.isEnabled == nil or type(config.isEnabled) ~= "boolean" then
    config.isEnabled = true;
end

local function save_config()
    json.dump_file("auto_select_nearest_camp.json", config);
end

local function get_target_pos(GUI050001)
    local ActiveQuestData = ActiveQuestData_field:get_data(get_QuestOrderParam_method:call(GUI050001));
    local target_em_start_area = Int32_value_field:get_data(getTargetEmSetAreaNo_method:call(ActiveQuestData):get_element(0)) or nil;
    if target_em_start_area ~= nil then
        local stage_draw_data = getDrawData_method:call(get_MapStageDrawData_method:call(get_MAP3D_method:call(Constants.GUIManager)), getStage_method:call(ActiveQuestData));
        if stage_draw_data ~= nil then
            local area_icon_pos_list = get_AreaIconPosList_method:call(stage_draw_data);
            for i = 0, AreaIconPosList_get_Count_method:call(area_icon_pos_list) - 1 do
                local AreaIconData = AreaIconPosList_get_Item_method:call(area_icon_pos_list, i);
                if get_AreaNum_method:call(AreaIconData) == target_em_start_area then
                    return get_AreaIconPos_method:call(AreaIconData);
                end
            end
        end
    end
end

local function get_index_of_nearest_start_point(target_pos, start_point_list, list_size)
    local shortest_distance = nil;
    local nearest_index = 0;
    for i = 0, list_size - 1 do
        local distance = distance_method:call(nil, getPos_method:call(get_BeaconGimmick_method:call(StartPointInfoList_get_Item_method:call(start_point_list, i))), target_pos);
        if i == 0 or distance < shortest_distance then
            shortest_distance = distance;
            nearest_index = i;
        end
    end
    return nearest_index;
end

local hook_datas = {
    hasData = false,
    obj = nil,
    nearest_start_point_index = nil
};

local function select_next_camp()
    local InputCtrl = InputCtrl_field:get_data(StartPointList_field:get_data(hook_datas.obj));
    if getSelectedIndex_method:call(InputCtrl) ~= hook_datas.nearest_start_point_index then
        selectNextItem_method:call(InputCtrl);
    end
end

sdk.hook(GUI050001_type_def:get_method("initStartPoint"), function(args)
    if config.isEnabled == true then
        hook_datas.obj = sdk.to_managed_object(args[2]);
    end
end, function()
    if config.isEnabled == true then
        local start_point_list = get_CurrentStartPointList_method:call(hook_datas.obj);
        local list_size = StartPointInfoList_get_Count_method:call(start_point_list);
        if list_size > 1 then
            local target_pos = get_target_pos(hook_datas.obj);
            if target_pos ~= nil then
                hook_datas.nearest_start_point_index = get_index_of_nearest_start_point(target_pos, start_point_list, list_size);
                if hook_datas.nearest_start_point_index > 0 then
                    setCurrentSelectStartPointIndex_method:call(hook_datas.obj, hook_datas.nearest_start_point_index);
                    hook_datas.hasData = true;
                    select_next_camp()
                end
            end
        end
    end
end);

sdk.hook(sdk.find_type_definition("app.GUI050001_AcceptList"):get_method("onVisibleUpdate"), nil, function()
    if config.isEnabled == true and hook_datas.hasData == true then
        select_next_camp()
    end
end);

sdk.hook(GUI050001_type_def:get_method("onClose"), nil, function()
    if config.isEnabled == true then
        hook_datas = {hasData = false, obj = nil, nearest_start_point_index = nil};
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