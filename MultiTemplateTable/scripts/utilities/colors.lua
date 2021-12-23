---------------------------------------------------------------------------------
--
--                  Sample Colors Utility Module

-- Requirements
local dkjson = require('utilities.dkjson')

-- Local color data
local color_data = {
    SlateGrey = 0x2F4F4F,
    Turquoise = 0x00CED1,
    Violet = 0x9400D3,
    DeepPink = 0xFF1493,
    SkyBlue = 0x00BFFF,
    Aqua = 0x00ffff,
    Aquamarine = 0x7fffd4,
    Blue = 0x0000ff,
    Blueviolet = 0x8a2be2,
    Brown = 0xa52a2a,
    PowderBlue = 0xB0E0E6,
    Purple = 0x800080,
    Red = 0xFF0000,
    RosyBrown = 0xBC8F8F,
    RoyalBlue = 0x4169E1,
    Orange = 0xFFA500,
    OrangeRed = 0xFF4500,
    Orchid = 0xDA70D6,
    GoldenRod = 0xEEE8AA
}

-- Basic colors module instance
local colors = {}

--- Get the color data as a json string
-- @function colors:get_data
-- @return @string json_data The color_data table encoded as a json string
function colors:get_data()
    local json_data = dkjson.encode(color_data)
    return json_data
end

return colors
