local utils = require "game.qpd.utils"

local color2 = {}

-- those colors are from raylib
color2.lightgray  = { 200, 200, 200}
color2.gray       = { 130, 130, 130}
color2.darkgray   = { 80, 80, 80}
color2.yellow     = { 253, 249, 0}
color2.gold       = { 255, 203, 0}
color2.orange     = { 255, 161, 0}
color2.pink       = { 255, 109, 194}
color2.red        = { 230, 41, 55}
color2.maroon     = { 190, 33, 55}
color2.green      = { 0, 228, 48}
color2.lime       = { 0, 158, 47}
color2.darkgreen  = { 0, 117, 44}
color2.skyblue    = { 102, 191, 255}
color2.blue       = { 0, 121, 241}
color2.darkblue   = { 0, 82, 172}
color2.purple     = { 200, 122, 255}
color2.violet     = { 135, 60, 190}
color2.darkpurple = { 112, 31, 126}
color2.beige      = { 211, 176, 131}
color2.brown      = { 127, 106, 79}
color2.darkbrown  = { 76, 63, 47}
color2.white      = { 255, 255, 255}
color2.black      = { 0, 0, 0}
color2.blank      = { 0, 0, 0}
color2.magenta    = { 255, 0, 255}
color2.offwhite   = { 245, 245, 245}

local color = {}

for key, value in pairs(color2)do
	color[key] = "{" .. tostring(value[1]/255) .. ", " ..
						tostring(value[2]/255) .. ", " ..
						tostring(value[3]/255) .. "}"
end

utils.table_write_to_file(color, "converted_colors", "=")
