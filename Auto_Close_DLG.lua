local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;
local json = Constants.json;
local re = Constants.re;

local getThisPtr = Constants.getThisPtr;

local config = json.load_file("auto_close_DLG.json") or {};

local function saveConfig()
    json.dump_file("auto_close_DLG.json", config);
end

local GUI000002_type_def = sdk.find_type_definition("app.GUI000002");
local GUI000002_NotifyWindowApp_field = GUI000002_type_def:get_field("_NotifyWindowApp");

local GUISystemModuleNotifyWindowApp_type_def = GUI000002_NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");

local GUINotifyWindowInfoApp_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfoApp_type_def:get_method("get_NotifyWindowId");
local isExistWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("isExistWindowEndFunc");
local endWindow_method = GUINotifyWindowInfoApp_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("executeWindowEndFunc");

local NotifyWindowID_type_def = get_NotifyWindowId_method:get_return_type();

local function Contains(tbl, value)
    for _, v in pairs(tbl) do
        if value == v then
            return true;
        end
    end
    return false;
end

local GUI000002_auto_close_IDs = {
    NotifyWindowID_type_def:get_field("GUI000002_0000"):get_data(nil)
};

sdk.hook(GUI000002_type_def:get_method("onOpen"), getThisPtr, function()
    local NotifyWindowApp = GUI000002_NotifyWindowApp_field:get_data(thread.get_hook_storage()["this_ptr"]);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil then
        local Id = get_NotifyWindowId_method:call(CurInfoApp);
        if Contains(GUI000002_auto_close_IDs, Id) == true then
            endWindow_method:call(CurInfoApp, 0);
            if config[Id] == nil then
                config[Id] = isExistWindowEndFunc_method:call(CurInfoApp);
                saveConfig();
            end
            if config[Id] == true then
                executeWindowEndFunc_method:call(CurInfoApp);
            end
            closeGUI_method:call(NotifyWindowApp);
        end
    end
end);

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");
local GUI000003_NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUI000003_auto_close_IDs = {
    NotifyWindowID_type_def:get_field("GUI040502_0301"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI070000_DLG02"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI080301_0005_DLG"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI080301_0006_DLG"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI090700_DLG_006"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI090700_DLG_010"):get_data(nil),
    NotifyWindowID_type_def:get_field("MsgGUI090700_DLG_012"):get_data(nil)
};

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), getThisPtr, function()
    local NotifyWindowApp = GUI000003_NotifyWindowApp_field:get_data(thread.get_hook_storage()["this_ptr"]);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil then
        local Id = get_NotifyWindowId_method:call(CurInfoApp);
        if Contains(GUI000003_auto_close_IDs, Id) == true then
            endWindow_method:call(CurInfoApp, 0);
            if config[Id] == nil then
                config[Id] = isExistWindowEndFunc_method:call(CurInfoApp);
                saveConfig();
            end
            if config[Id] == true then
                executeWindowEndFunc_method:call(CurInfoApp);
            end
            closeGUI_method:call(NotifyWindowApp);
        end
    end
end);

local GUI000004_type_def = sdk.find_type_definition("app.GUI000004");
local GUI000004_NotifyWindowApp_field = GUI000004_type_def:get_field("_NotifyWindowApp");
local ListCtrl_field = GUI000004_type_def:get_field("_ListCtrl");

local requestSelectIndexCore_method = sdk.find_type_definition("ace.cGUIInputCtrl_ScrollList`2<app.GUIID.ID,app.GUIFunc.TYPE>"):get_method("requestSelectIndexCore(System.Int32, System.Int32)");

local EQUIP_003 = NotifyWindowID_type_def:get_field("EQUIP_003"):get_data(nil);

sdk.hook(GUI000004_type_def:get_method("onOpen"), getThisPtr, function()
    local this_ptr = thread.get_hook_storage()["this_ptr"];
    if get_NotifyWindowId_method:call(get__CurInfoApp_method:call(GUI000004_NotifyWindowApp_field:get_data(this_ptr))) == EQUIP_003 then
        requestSelectIndexCore_method:call(ListCtrl_field:get_data(this_ptr), 2, 2);
    end
end);

re.on_config_save(saveConfig);