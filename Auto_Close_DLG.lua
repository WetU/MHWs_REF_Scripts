local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;
local tonumber = Constants.tonumber;
local tostring = Constants.tostring;
local string = Constants.string;

local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;

local getThisPtr = Constants.getThisPtr;

local config = json.load_file("auto_close_DLG.json") or {};

local function saveConfig()
    json.dump_file("auto_close_DLG.json", config);
end

local addSystemLog_method = Constants.addSystemLog_method;

local guid2str_method = sdk.find_type_definition("via.gui.message"):get_method("get(System.Guid)"); -- static

local GUI000002_type_def = sdk.find_type_definition("app.GUI000002");

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");

local GUISystemModuleNotifyWindowApp_type_def = sdk.find_type_definition("app.cGUISystemModuleNotifyWindowApp");
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");

local GUINotifyWindowInfoApp_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfoApp_type_def:get_method("get_NotifyWindowId");
local get_Caller_method = GUINotifyWindowInfoApp_type_def:get_method("get_Caller");
local get_TextInfo_method = GUINotifyWindowInfoApp_type_def:get_method("get_TextInfo");
local isExistWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("isExistWindowEndFunc");
local endWindow_method = GUINotifyWindowInfoApp_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("executeWindowEndFunc");

local NotifyWindowID_type_def = get_NotifyWindowId_method:get_return_type();

local GUIMessageInfo_type_def = get_TextInfo_method:get_return_type();
local get_MsgID_method = GUIMessageInfo_type_def:get_method("get_MsgID");
local get_Params_method = GUIMessageInfo_type_def:get_method("get_Params");

local get_Item_method = get_Params_method:get_return_type():get_method("get_Item(System.Int32)");

local ParamData_type_def = get_Item_method:get_return_type();

local ParamType_type_def = sdk.find_type_definition("ace.cGUIMessageInfo.ParamType");
local ParamType = {
    GUID = ParamType_type_def:get_field("GUID"):get_data(nil),
    STRING = ParamType_type_def:get_field("STRING"):get_data(nil),
    INT = ParamType_type_def:get_field("INT"):get_data(nil),
    LONG = ParamType_type_def:get_field("LONG"):get_data(nil)
};

local ParamValue_type_def = sdk.find_type_definition("ace.cGUIMessageInfo.ParamUnion");

local getSetting_method = sdk.find_type_definition("app.user_data.GUINotifyWindowData"):get_method("getSetting(app.GUINotifyWindowDef.ID)");

local Setting_type_def = getSetting_method:get_return_type();
local get_DefaultIndex_method = Setting_type_def:get_method("get_DefaultIndex");

local function Contains(tbl, value)
    for _, v in pairs(tbl) do
        if value == v then
            return true;
        end
    end
    return false;
end

local INVALID = NotifyWindowID_type_def:get_field("INVALID"):get_data(nil);
local GUI000002_0000 = NotifyWindowID_type_def:get_field("GUI000002_0000"):get_data(nil);
local change_default_index_IDs = {
    [NotifyWindowID_type_def:get_field("EQUIP_003"):get_data(nil)] = 2,
    [NotifyWindowID_type_def:get_field("GUI080301_0004_DLG"):get_data(nil)] = 0
};
local auto_close_IDs = {
    NotifyWindowID_type_def:get_field("GUI040502_0301"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI070000_DLG02"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI080301_0005_DLG"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI080301_0006_DLG"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI090700_DLG_005"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI090700_DLG_006"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI090700_DLG_010"):get_data(nil),
    NotifyWindowID_type_def:get_field("MsgGUI090700_DLG_012"):get_data(nil)
};

local VariousDataManager = sdk.get_managed_singleton("app.VariousDataManager");
if VariousDataManager ~= nil then
    local VariousDataManagerSetting = sdk.call_native_func(VariousDataManager, VariousDataManager:get_type_definition(), "get_Setting");
    if VariousDataManagerSetting ~= nil then
        local GUIVariousData = sdk.call_native_func(VariousDataManagerSetting, VariousDataManagerSetting:get_type_definition(), "get_GUIVariousData");
        if GUIVariousData ~= nil then
            local GUINotifyWindowData = sdk.call_native_func(GUIVariousData, GUIVariousData:get_type_definition(), "get_NotifyWindowData");
            if GUINotifyWindowData ~= nil then
                for id, idx in pairs(change_default_index_IDs) do
                    local Setting = getSetting_method:call(GUINotifyWindowData, id);
                    if Setting ~= nil and get_DefaultIndex_method:call(Setting) ~= idx then
                        sdk.set_native_field(Setting, Setting_type_def, "_DefaultIndex", idx);
                    end
                end
            end
        end
    end
end
VariousDataManager = nil;

local function auto_close(notifyWindowApp, infoApp, id)
    endWindow_method:call(infoApp, 0);
    if config[id] == nil then
        config[id] = isExistWindowEndFunc_method:call(infoApp);
        saveConfig();
    end
    if config[id] == true then
        executeWindowEndFunc_method:call(infoApp);
    end
    closeGUI_method:call(notifyWindowApp);
end

sdk.hook(GUI000002_type_def:get_method("onOpen"), getThisPtr, function()
    local NotifyWindowApp = sdk.get_native_field(thread.get_hook_storage()["this_ptr"], GUI000002_type_def, "_NotifyWindowApp");
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil then
        local Id = get_NotifyWindowId_method:call(CurInfoApp);
        if Id == GUI000002_0000 then
            auto_close(NotifyWindowApp, CurInfoApp, Id);
        end
    end
end);

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), getThisPtr, function()
    local NotifyWindowApp = sdk.get_native_field(thread.get_hook_storage()["this_ptr"], GUI000003_type_def, "_NotifyWindowApp");
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil then
        local Id = get_NotifyWindowId_method:call(CurInfoApp);
        if Id == INVALID then
            if get_Caller_method:call(CurInfoApp):get_type_definition():get_full_name() == "app.NetworkErrorManager" then
                local ChatManager = Constants.ChatManager;
                if ChatManager ~= nil then
                    local GUIMessageInfo = get_TextInfo_method:call(CurInfoApp);
                    local Params = get_Params_method:call(GUIMessageInfo);
                    local msg = guid2str_method:call(nil, get_MsgID_method:call(GUIMessageInfo));
                    msg = string.gsub(msg, "{([0-9]+)}", function(i)
                        local Param = get_Item_method:call(Params, tonumber(i));
                        local Type = sdk.get_native_field(Param, ParamData_type_def, "ParamType");
                        if Type == ParamType.GUID then
                            return guid2str_method:call(nil, sdk.get_native_field(Param, ParamData_type_def, "ParamGuid"));
                        elseif Type == ParamType.STRING then
                            return sdk.get_native_field(Param, ParamData_type_def, "ParamString");
                        else
                            local ParamValue = sdk.get_native_field(Param, ParamData_type_def, "ParamValue");
                            return Type == ParamType.INT and tostring(sdk.get_native_field(ParamValue, ParamValue_type_def, "ParamInt")) or Type == ParamType.LONG and tostring(sdk.get_native_field(ParamValue, ParamValue_type_def, "ParamLong")) or tostring(sdk.get_native_field(ParamValue, ParamValue_type_def, "ParamFloat"));
                        end
                    end);
                    addSystemLog_method:call(ChatManager, msg);
                end
                endWindow_method:call(CurInfoApp, 0);
                executeWindowEndFunc_method:call(CurInfoApp);
                closeGUI_method:call(NotifyWindowApp);
            end
        elseif Contains(auto_close_IDs, Id) == true then
            auto_close(NotifyWindowApp, CurInfoApp, Id);
        end
    end
end);

re.on_config_save(saveConfig);