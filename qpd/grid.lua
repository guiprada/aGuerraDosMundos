-- Guilherme Cunha Prada 2020
local grid = {}

local utils = require "qpd.utils"

-----------------------------------------------------------------------
function grid._is_collision(self, n)
	for key, item in ipairs(self.collisions) do
		if item == n then
			return true
		end
	end
	return false
end

-----------------------------------------------------------------------
function grid.get_valid_pos(self)
	return self.array_grid_valid_pos[love.math.random(#self.array_grid_valid_pos)]
end

function grid.new(matrix, collisions)
	local o = {}
	o.matrix = matrix
	o.collisions = collisions
	
	o.width = #o.matrix[1]
	o.height = #o.matrix

	utils.assign_methods(o, grid)

	o.array_grid_valid_pos = {}
	for i=1, o.width do
		for j=1, o.height do
			if ( not o:_is_collision(o.matrix[j][i]) ) then
				local value = {}
				value.x = i
				value.y = j
				table.insert(o.array_grid_valid_pos, value)
			end
		end
	end

	return o
end

function grid.is_colliding(self, x, y, tilesize)
	local grid_y = math.ceil(y/tilesize) + 1
	local grid_x = math.ceil(x/tilesize) + 1

	local grid_value = self.matrix[grid_y][grid_x]
	return self.collisions[grid_value] or false
end

function grid.is_colliding_grid(self, grid_x, grid_y, tilesize)
	local grid_value = self.matrix[grid_y][grid_x]
	return self.collisions[grid_value] or false
end

return grid