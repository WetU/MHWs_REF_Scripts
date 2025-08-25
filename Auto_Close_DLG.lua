local Constants = _G.require("Constants/Constants");

local pairs = Constants.pairs;

local sdk = Constants.sdk;
local thread = Constants.thread;

local getThisPtr = Constants.getThisPtr;

local GUI000003_type_def = sdk.find_type_definition("app.GUI000003");
local GUI000009_NotifyWindowApp_field = GUI000003_type_def:get_field("_NotifyWindowApp");

local GUISystemModuleNotifyWindowApp_type_def = GUI000009_NotifyWindowApp_field:get_type();
local get__CurInfoApp_method = GUISystemModuleNotifyWindowApp_type_def:get_method("get__CurInfoApp");
local closeGUI_method = GUISystemModuleNotifyWindowApp_type_def:get_method("closeGUI");
local isExistCurrentInfo_method = GUISystemModuleNotifyWindowApp_type_def:get_method("isExistCurrentInfo");

local GUINotifyWindowInfoApp_type_def = get__CurInfoApp_method:get_return_type();
local get_NotifyWindowId_method = GUINotifyWindowInfoApp_type_def:get_method("get_NotifyWindowId");
local set_DefaultIndex_method = GUINotifyWindowInfoApp_type_def:get_method("set_DefaultIndex(System.Int32)");
local isExistWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("isExistWindowEndFunc");
local endWindow_method = GUINotifyWindowInfoApp_type_def:get_method("endWindow(System.Int32)");
local executeWindowEndFunc_method = GUINotifyWindowInfoApp_type_def:get_method("executeWindowEndFunc");

local NotifyWindowID_type_def = get_NotifyWindowId_method:get_return_type();
local NotifyWindowID = {
    NotifyWindowID_type_def:get_field("GUI000002_0000"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI070000_DLG02"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI080301_0005_DLG"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI080301_0006_DLG"):get_data(nil),
    NotifyWindowID_type_def:get_field("GUI090700_DLG_006"):get_data(nil)
};

local function Contains(value)
    for _, v in pairs(NotifyWindowID) do
        if value == v then
            return true;
        end
    end
    return false;
end

sdk.hook(GUI000003_type_def:get_method("guiOpenUpdate"), getThisPtr, function()
    local NotifyWindowApp = GUI000009_NotifyWindowApp_field:get_data(thread.get_hook_storage()["this_ptr"]);
    local CurInfoApp = get__CurInfoApp_method:call(NotifyWindowApp);
    if CurInfoApp ~= nil and Contains(get_NotifyWindowId_method:call(CurInfoApp)) == true then
        endWindow_method:call(CurInfoApp, 0);
        if isExistWindowEndFunc_method:call(CurInfoApp) == true then
            executeWindowEndFunc_method:call(CurInfoApp);
        end
        closeGUI_method:call(NotifyWindowApp);
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