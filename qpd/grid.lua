-- Guilherme Cunha Prada 2020
local grid = {}

local qpd_table = require "qpd.table"
local qpd_random = require "qpd.random"

-----------------------------------------------------------------------
function grid._is_collision(self, n)
	return self.collisions[n] or false
end

-----------------------------------------------------------------------
function grid.point_to_cell(x, y, tilesize)
	local cell_x = math.floor(x / tilesize) + 1 --lua arrays start at 1
	local cell_y = math.floor(y / tilesize) + 1 --lua arrays start at 1
	return cell_x, cell_y
end

function grid.cell_to_center_point(cell_x, cell_y, tilesize)
	local center_x = (cell_x-1)*tilesize + math.ceil(tilesize/2)
	local center_y = (cell_y-1)*tilesize + math.ceil(tilesize/2)
	return center_x, center_y
end

-----------------------------------------------------------------------
function grid.new(matrix, collisions)
	local o = {}
	o.matrix = matrix
	o.collisions = collisions

	o.width = #o.matrix[1]
	o.height = #o.matrix

	qpd_table.assign_methods(o, grid)

	o._enabled_directions = {}
	for i = 1, o.height do
		o._enabled_directions[i] = {}
	end

	o.array_cell_valid_pos = {}
	for i = 1, o.width do
		for j = 1, o.height do
			if ( not o:_is_collision(o.matrix[j][i]) ) then
				local value = {}
				value.x = i
				value.y = j
				table.insert(o.array_cell_valid_pos, value)
			end
		end
	end

	o._grid_collisions = {}
	for i = 1, o.height do
		o._grid_collisions[i] = {}
		for j = 1, o.width do
			o._grid_collisions[i][j] = {}
		end
	end

	return o
end

function grid.get_valid_cell(self)
	local cell = {}
	cell = self.array_cell_valid_pos[qpd_random.random(#self.array_cell_valid_pos)]
	return cell
end

function grid.is_colliding_point(self, x, y, tilesize)
	local cell_x, cell_y = grid.point_to_cell(x, y, tilesize)
	return self:is_colliding_cell(cell_x, cell_y)
end

function grid.is_colliding_cell(self, cell_x, cell_y)
	local cell_value = self.matrix[cell_y][cell_x]
	return self.collisions[cell_value] or false
end

function grid.is_valid_cell(self, cell_x, cell_y)
	if 	cell_x >= 1 and cell_x <= self.width and
		cell_y >= 1 and	cell_y <= self.height and
		not self:is_colliding_cell(cell_x, cell_y) then
		return true
	end
	return false
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
		current_cell.x, current_cell.y = grid.point_to_cell(x, y, tilesize)
		if self:is_colliding_cell(current_cell.x, current_cell.y) then
			return false
		end
		acc_distance = acc_distance + math.sqrt(step_x^2 + step_y^2)
		x, y = x + step_x, y + step_y
	end
	return true
end

function grid.get_enabled_directions(self, cell_x, cell_y)
	local enabled_directions = self._enabled_directions[cell_y][cell_x]
	if enabled_directions then
		return enabled_directions
	else
		enabled_directions = {}
		enabled_directions[1] = self:is_valid_cell(cell_x - 1, cell_y) -- up
		enabled_directions[2] = self:is_valid_cell(cell_x + 1, cell_y) -- down
		enabled_directions[3] = self:is_valid_cell(cell_x, cell_y - 1) -- left
		enabled_directions[4] = self:is_valid_cell(cell_x, cell_y + 1) -- right

		-- memoize
		self._enabled_directions[cell_y][cell_x] = enabled_directions

		return enabled_directions
	end
end

function grid.update_collision(self, gridActor)
	local cell_x, cell_y = gridActor._cell.x, gridActor._cell.y
	local other_obj_list = self._grid_collisions[cell_y][cell_x]
	if (#other_obj_list > 0) then -- has collided
		for i = 1, #other_obj_list do
			local other = other_obj_list[i]
			if other.collided then
				other:collided(gridActor)
			end
			if gridActor.collided then
				gridActor:collided(other)
			end
		end
	end
	table.insert(self._grid_collisions[cell_y][cell_x], gridActor)
end

function grid.clear_collisions(self)
	for i = 1, self.height do
		for j = 1, self.width do
			local position = self._grid_collisions[i][j]
			for k = #position, 1, -1 do
				position[k] = nil
			end
		end
	end
end

return grid