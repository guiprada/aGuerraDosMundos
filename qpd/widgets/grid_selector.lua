local grid_selector = {}

local qpd_table = require "qpd.table"
local qpd_value = require "qpd.value"
local qpd_color = require "qpd.color"

function grid_selector.new(
	offset_x,
	offset_y,
	min_grid_x,
	min_grid_y,
	max_grid_x,
	max_grid_y,
	tilesize,
	color,
	grid_start_x,
	grid_start_y)

	local o = {}

	o.offset_x = offset_x
	o.offset_y = offset_y
	o.min_grid_x = min_grid_x
	o.min_grid_y = min_grid_y
	o.max_grid_x = max_grid_x
	o.max_grid_y = max_grid_y

	o.grid_x = grid_start_x or math.floor((min_grid_x + max_grid_x)/2)
	o.grid_y = grid_start_y or math.floor((min_grid_y + max_grid_y)/2)

	o.tilesize = tilesize
	o.color = color or {1, 0, 0}

	qpd_table.assign_methods(o, grid_selector)

	return o
end

--------------------------------------------------------------------------------

function grid_selector.resize(self, tilesize)
	self.tilesize = tilesize
end

function grid_selector.draw(self)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(qpd_color.unpack(self.color))

	love.graphics.rectangle(
		"line",
		self.offset_x + (self.grid_x - 1) * self.tilesize,
		self.offset_y + (self.grid_y - 1) * self.tilesize,
		self.tilesize,
		self.tilesize)

	love.graphics.setColor(r, g, b, a)
end

function grid_selector.up(self)
	self.grid_y = qpd_value.clamp(
		self.grid_y - 1,
		self.min_grid_y, self.max_grid_y)
end

function grid_selector.down(self)
	self.grid_y = qpd_value.clamp(
		self.grid_y + 1,
		self.min_grid_y, self.max_grid_y)
end

function grid_selector.right(self)
	self.grid_x = qpd_value.clamp(
		self.grid_x + 1,
		self.min_grid_x, self.max_grid_x)
end

function grid_selector.left(self)
	self.grid_x = qpd_value.clamp(
		self.grid_x - 1,
		self.min_grid_x, self.max_grid_x)
end

function grid_selector.add_line(self)
	self.max_grid_y = self.max_grid_y + 1
end

function grid_selector.add_row(self)
	self.max_grid_x = self.max_grid_x + 1
end

function grid_selector.get_center(self)
		return
			self.offset_x + (self.grid_x - 1) * self.tilesize + self.tilesize/2,
			self.offset_y + (self.grid_y - 1) * self.tilesize + self.tilesize/2
end

return grid_selector