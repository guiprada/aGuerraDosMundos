-- Guilherme Cunha Prada 2020
local grid = {}

local utils = require "qpd.utils"

-----------------------------------------------------------------------
function grid._is_collision(self, n)
	return self.collisions[n] or false
end

-----------------------------------------------------------------------
function grid.get_valid_pos(self)
	local pos = {}
	pos = self.array_grid_valid_pos[love.math.random(#self.array_grid_valid_pos)]
	return pos
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
	local grid_y = math.floor(y/tilesize) + 1
	local grid_x = math.floor(x/tilesize) + 1
	return self:is_colliding_grid(grid_x, grid_y)
end

function grid.is_colliding_grid(self, grid_x, grid_y)
	local grid_value = self.matrix[grid_y][grid_x]
	return self.collisions[grid_value] or false
end

function grid.check_unobstructed(self, origin, angle, distance, tilesize, maybe_step)
    -- we go tile by tile
    local step = maybe_step or tilesize
    local step_x = math.cos( angle ) * step
    local step_y = math.sin( angle ) * step

    local acc_distance = 0

    local current_cell = {}
    local x, y = origin.x, origin.y
    while acc_distance < distance do
        current_cell.x, current_cell.y = grid.point_to_grid(x, y, tilesize)
        if self:is_colliding_grid(current_cell.x, current_cell.y) then
            return false
        end
        acc_distance = acc_distance + math.sqrt(step_x^2 + step_y^2)
        x, y = x + step_x, y + step_y
    end
    return true
end


function grid.point_to_grid(x, y, tilesize)		
	grid_x = math.floor(x / tilesize) + 1--lua arrays start at 1
	grid_y = math.floor(y / tilesize) + 1 --lua arrays start at 1
	return grid_x, grid_y
end

function grid.to_center_point(x, y, tilesize)
	center_x = (x-1)*tilesize + math.ceil(tilesize/2)
	center_y = (y-1)*tilesize + math.ceil(tilesize/2)
	return center_x, center_y
end

return grid