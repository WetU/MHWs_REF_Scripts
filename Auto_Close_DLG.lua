local Constants = _G.require("Constants/Constants");

local ipairs = Constants.ipairs;
local pairs = Constants.pairs;
local tonumber = Constants.tonumber;
local tostring = Constants.tostring;
local strgsub = Constants.strgsub;
local tinsert = Constants.tinsert;

local hook = Constants.hook;
local find_type_definition = Constants.find_type_definition;
local set_native_field = Constants.set_native_field;

local get_hook_storage = Constants.get_hook_storage;

local addSystemLog_method = Constants.addSystemLog_method;
local getThisPtr = Constants.getThisPtr;
local requestClose = Constants.requestClose;
local isContain = Constants.isContain;

local guid2str_method = find_type_definition("via.gui.message"):get_method("get(System.Guid)"); -- static

local isVisibleGUI_method = Constants.GUIManager_type_def:get_parent_type():get_method("isVisibleGUI(app.GUIID.ID)");
local UI020100 = Constants.GUIID_type_def:get_field("UI020100"):get_data(nil);

local GUIVariousData_type_def = find_type_definition("app.user_data.GUIVariousData");

local GUI000002_type_def = Constants.GUI000002_type_def;
local GUI000002_NotifyWindowApp_field = GUI000002_type_def:get_field("_NotifyWindowApp");

local GUI000003_type_def = find_type_definition("app.GUI000003");
local GUI000003_NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUI000004_type_def = find_type_definition("app.GUI000004");

local GUISystemModuleNotifyWindowApp_type_def = GUI000003_NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");

local GUINotifyWindowInfoApp_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfoApp_type_def:get_method("get_NotifyWindowId");

local GUINotifyWindowInfo_type_def = GUINotifyWindowInfoApp_type_def:get_parent_type();
local get_Caller_method = GUINotifyWindowInfo_type_def:get_method("get_Caller");
local get_TextInfo_method = GUINotifyWindowInfo_type_def:get_method("get_TextInfo");
local isExistWindowEndFunc_method = GUINotifyWindowInfo_type_def:get_method("isExistWindowEndFunc");
local endWindow_method = GUINotifyWindowInfo_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfo_type_def:get_method("executeWindowEndFunc");

local GUIMessageInfo_type_def = get_TextInfo_method:get_return_type();
local get_MsgID_method = GUIMessageInfo_type_def:get_method("get_MsgID");
local get_Params_method = GUIMessageInfo_type_def:get_method("get_Params");

local get_Item_method = get_Params_method:get_return_type():get_method("get_Item(System.Int32)");

local ParamData_type_def = get_Item_method:get_return_type();
local ParamType_field = ParamData_type_def:get_field("ParamType");
local ParamGuid_field = ParamData_type_def:get_field("ParamGuid");
local ParamString_field = ParamData_type_def:get_field("ParamString");
local ParamValue_field = ParamData_type_def:get_field("ParamValue");

local ParamType_type_def = ParamType_field:get_type();
local GUID = ParamType_type_def:get_field("GUID"):get_data(nil);
local STRING = ParamType_type_def:get_field("STRING"):get_data(nil);
local INT = ParamType_type_def:get_field("INT"):get_data(nil);
local LONG = ParamType_type_def:get_field("LONG"):get_data(nil);

local ParamValue_type_def = ParamValue_field:get_type();
local ParamInt_field = ParamValue_type_def:get_field("ParamInt");
local ParamLong_field = ParamValue_type_def:get_field("ParamLong");
local ParamFloat_field = ParamValue_type_def:get_field("ParamFloat");

local INVALID = nil;
local GUI000002_0000 = nil;
local auto_close_IDs = {};
local auto_close_ID_names = {
    "GUI040502_0301",
    "GUI070000_DLG01",
    "GUI070000_DLG02",
    "GUI080004_0002",
    "GUI080004_008",
    "GUI080301_0005_DLG",
    "GUI080301_0006_DLG",
    "GUI090002_DLG_02",
    "GUI090700_DLG_005",
    "GUI090700_DLG_006",
    "GUI090700_DLG_010",
    "MsgGUI090700_DLG_012",
    "Net_Session_012",
    "SAVE_0005"
};

local function closeWindow(notifyWindowApp, infoApp)
    endWindow_method:call(infoApp, 0);
    if isExistWindowEndFunc_method:call(infoApp) then
        executeWindowEndFunc_method:call(infoApp);
    end
    closeGUI_method:call(notifyWindowApp);
end

hook(GUI000002_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    local NotifyWindowApp = GUI000002_NotifyWindowApp_field:get_data(this_ptr);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil and get_NotifyWindowId_method:call(CurInfoApp) == GUI000002_0000 then
        closeWindow(NotifyWindowApp, CurInfoApp);
    end
end);

hook(GUI000003_type_def:get_method("guiOpenUpdate"), getThisPtr, function()
    local this_ptr = get_hook_storage().this_ptr;
    local NotifyWindowApp = GUI000003_NotifyWindowApp_field:get_data(this_ptr);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil then
        local Id = get_NotifyWindowId_method:call(CurInfoApp);
        if Id == INVALID then
            if get_Caller_method:call(CurInfoApp):get_type_definition():get_full_name() == "app.NetworkErrorManager" then
                local GUIManager = Constants.GUIManager;
                if GUIManager ~= nil and isVisibleGUI_method:call(GUIManager, UI020100) then
                    local GUIMessageInfo = get_TextInfo_method:call(CurInfoApp);
                    local Params = get_Params_method:call(GUIMessageInfo);
                    local msg = guid2str_method:call(nil, get_MsgID_method:call(GUIMessageInfo));
                    msg = strgsub(msg, "{([0-9]+)}", function(i)
                        local Param = get_Item_method:call(Params, tonumber(i));
                        local Type = ParamType_field:get_data(Param);
                        if Type == GUID then
                            return guid2str_method:call(nil, ParamGuid_field:get_data(Param));
                        elseif Type == STRING then
                            return ParamString_field:get_data(Param);
                        else
                            local ParamValue = ParamValue_field:get_data(Param);
                            if Type == INT then
                                return tostring(ParamInt_field:get_data(ParamValue));
                            elseif Type == LONG then
                                return tostring(ParamLong_field:get_data(ParamValue));
                            else
                                return tostring(ParamFloat_field:get_data(ParamValue));
                            end
                        end
                    end);
                    addSystemLog_method:call(Constants.ChatManager, msg);
                end
                closeWindow(NotifyWindowApp, CurInfoApp);
            end
        else
            for _, v in ipairs(auto_close_IDs) do
                if Id == v then
                    closeWindow(NotifyWindowApp, CurInfoApp);
                    break;
                end
            end
        end
    end
end);

hook(find_type_definition("app.GUI080303"):get_method("onOpen"), getThisPtr, requestClose);

do
    local GUIVariousData = Constants.call_object_func(Constants.get_VariousData_method:call(nil), "get_GUIVariousData");
    if GUIVariousData ~= nil then
        local GUIVariousData_type_def = GUIVariousData:get_type_definition();
        set_native_field(GUIVariousData, GUIVariousData_type_def, "_WaitTimeForJudge", 0.01);
        set_native_field(GUIVariousData, GUIVariousData_type_def, "_WaitTimeForFixQuestResult", 0.01);
        set_native_field(GUIVariousData, GUIVariousData_type_def, "_WaitTimeForSeamlessJudge", 0.01);
        local GUINotifyWindowData = Constants.call_native_func(GUIVariousData, GUIVariousData_type_def, "get_NotifyWindowData");
        if GUINotifyWindowData ~= nil then
            local getSetting_method = GUINotifyWindowData:get_type_definition():get_method("getSetting(app.GUINotifyWindowDef.ID)");
            local Setting_type_def = getSetting_method:get_return_type();
            for _, v in pairs(get_NotifyWindowId_method:get_return_type():get_fields()) do
                if v:is_static() then
                    local name = v:get_name();
                    local value = v:get_data(nil);
                    if name == "INVALID" then
                        INVALID = value;
                    else
                        local Setting = getSetting_method:call(GUINotifyWindowData, value);
                        if Setting ~= nil then
                            set_native_field(Setting, Setting_type_def, "_DispMinTime", 0.0);
                            if name == "GUI000002_0000" then
                                GUI000002_0000 = value;
                            elseif name == "EQUIP_002" then
                                set_native_field(Setting, Setting_type_def, "_DefaultIndex", 1);
                            elseif name == "EQUIP_003" then
                                set_native_field(Setting, Setting_type_def, "_DefaultIndex", 2);
                            elseif name == "GUI030000_04_06_DLG" or name == "GUI080301_0004_DLG" then
                                set_native_field(Setting, Setting_type_def, "_DefaultIndex", 0);
                            elseif isContain(auto_close_ID_names, name) then
                                tinsert(auto_close_IDs, value);
                            end
                        end
                    end
                end
            end
        end
    end
end