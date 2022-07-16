local color_cell = {}

local color = require "qpd.color"

function color_cell.make_func(pColor)
	return
		function (x, y, tilesize)
			local r, g, b, a = love.graphics.getColor()
			love.graphics.setColor(color.unpack(pColor))
			love.graphics.rectangle(
				"fill",
				x,
				y,
				tilesize,
				tilesize)
			love.graphics.setColor(r, g, b, a)
		end
end

function color_cell.new(pColor)
	return color_cell.make_func(pColor)
end

return color_cell