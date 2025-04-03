local _G = _G;
local require = _G.require;

local Constants = require("Constants\\Constants");
local sdk = Constants.sdk;
local ipairs = Constants.ipairs;
local pairs = Constants.pairs;

local Statics = {}

function Statics.generate(typename, double_ended)
    local double_ended = double_ended or false;

    local t = sdk.find_type_definition(typename)
    if not t then return {} end

    local fields = t:get_fields();
    local enum = {};

    for i, field in ipairs(fields) do
        if field:is_static() then
            local name = field:get_name();
            local raw_value = field:get_data(nil);

            enum[name] = raw_value;

            if double_ended then
                enum[raw_value] = name;
            end
        end
    end

    return enum;
end

function Statics.generate_global(typename)
    local parts = {}

    for part in typename:gmatch("[^%.]+") do
        table.insert(parts, part);
    end

    local global = _G;
    for i, part in ipairs(parts) do
        if not global[part] then
            global[part] = {};
        end

        global = global[part];
    end

    if global ~= _G then
        local static_class = Statics.generate(typename);

        for k, v in pairs(static_class) do
            global[k] = v;
            global[v] = k;
        end
    end

    return global;
end

return Statics;