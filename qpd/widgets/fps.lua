local fps = {}

local qpd_table = require "qpd.table"
local qpd_color = require "qpd.color"

function fps.draw(self)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(qpd_color.unpack(self.color))
	love.graphics.print(
		love.timer.getFPS(),
		self.x,
		self.y)
	love.graphics.setColor(r, g, b, a)
end

--------------------------------------------------------------------------------

function fps.new(x, y, color)
	local o = {}
	o.x = x or 0
	o.y = y or 0
	o.color = color or {0, 1, 1}

	-- methods
	qpd_table.assign_methods(o, fps)

	return o
end

return fps
