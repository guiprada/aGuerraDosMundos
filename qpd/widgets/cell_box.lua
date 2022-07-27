local cell_box = {}

local qpd_table = require "qpd.table"
local qpd_grid_selector = require "qpd.widgets.grid_selector"

function cell_box.new(x, y, width, tilesize, cell_set)
	local o = {}

	o.x = x
	o.y = y
	o.width = width
	o.tilesize = tilesize
	o.cell_set = cell_set

	local w_cells = math.floor(width/tilesize) -- how many cell we can fit
	if w_cells > #cell_set then w_cells = #cell_set end -- if we need less
	local h_cells = math.ceil(#cell_set/w_cells)
	o.selector = qpd_grid_selector.new(x, y, 1, 1, w_cells, h_cells, tilesize)

	qpd_table.assign_methods(o, cell_box)
	return o
end

--------------------------------------------------------------------------------

function cell_box.resize(self, width, tilesize)
	self.width = width
	self.tilesize = tilesize
	self.selector:resize(tilesize)
end

function cell_box.set_selector_color(self, color)
	self.selector.color = color
end

function cell_box.get_selected(self)
	return self.selector.grid_x
end

function cell_box.left(self)
	self.selector:left()
end

function cell_box.right(self)
	self.selector:right()
end

function cell_box.draw(self)
	-- draw frame
	love.graphics.rectangle(
		"fill",
		self.x,
		self.y,
		self.width,
		self.tilesize)

	local column = 1
	local line = 1
	local w_cells = math.floor(self.width/ self.tilesize) -- width in cells
	for index, value in ipairs(self.cell_set) do
		local func = self.cell_set[index]
		column = index%w_cells
		line = math.floor(index/w_cells)
		func(
			(column - 1)*self.tilesize + self.x,
			(line)*self.tilesize + self.y,
			self.tilesize)
	end
	self.selector:draw()
end

return cell_box