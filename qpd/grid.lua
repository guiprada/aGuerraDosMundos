-- Guilherme Cunha Prada 2020
local grid = {}

local utils = require "qpd.utils"

function grid.new(matrix, collisions, tilesize)
	local o = {}
	o.matrix = matrix
	o.collisions = collisions
	o.tilesize = tilesize

	o.width = #o.matrix[1]
	o.height = #o.matrix

	utils.assign_methods(o, grid)

	return o
end

function grid.is_colliding(self, x, y)
	local grid_x = math.ceil(y/self.tilesize) + 1
	local grid_y = math.ceil(x/self.tilesize) + 1

	local grid_value = self.matrix[grid_x][grid_y]
	return self.collisions[grid_value] or false
end

function grid.get_grid_pos(self, x, y, tilesize)
	this_tilesize = tilesize or self.tilesize
	local grid_x, grid_y = -1, -1
	grid_x = math.floor(x / this_tilesize) + 1--lua arrays start at 1
	grid_y = math.floor(y / this_tilesize) + 1 --lua arrays start at 1
	return grid_x, grid_y
end

return grid