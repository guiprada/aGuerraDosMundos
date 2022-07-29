local AutoplayerAnnModes = {}
AutoplayerAnnModes.updates = {}
AutoplayerAnnModes.ann_creates = {}

local qpd = require "qpd.qpd"

-- helper functions
local function rotate_left(self)
	if self._orientation == "up" then
		self._orientation = "left"
	elseif self._orientation == "down" then
		self._orientation = "right"
	elseif self._orientation == "left" then
		self._orientation = "down"
	elseif self._orientation == "right" then
		self._orientation = "up"
	end
end

local function rotate_right(self)
	if self._orientation == "up" then
		self._orientation = "right"
	elseif self._orientation == "down" then
		self._orientation = "left"
	elseif self._orientation == "left" then
		self._orientation = "up"
	elseif self._orientation == "right" then
		self._orientation = "down"
	end
end

local function flip(self)
	if self._orientation == "up" then
		self._orientation = "down"
	elseif self._orientation == "down" then
		self._orientation = "up"
	elseif self._orientation == "left" then
		self._orientation = "right"
	elseif self._orientation == "right" then
		self._orientation = "left"
	end
end

local function keep(self)
	if self._orientation == "up" then
		self._orientation = "up"
	elseif self._orientation == "down" then
		self._orientation = "down"
	elseif self._orientation == "left" then
		self._orientation = "left"
	elseif self._orientation == "right" then
		self._orientation = "right"
	end
end

local function list_has_class(class_name, grid_actor_list)
	for i = 1, #grid_actor_list do
		if grid_actor_list[i]:is_type(class_name) then
			return true
		end
	end

	return false
end

-- Autoplayer helper Methods
local function distance_to_class_x(self, dx, class, grid, search_path_length)
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if grid:is_blocked_cell(cell_x + dx * i, cell_y) then
			return search_path_length
		end

		local collision_list = grid:get_collisions_in_cell(cell_x + dx * i, cell_y)
		if (#collision_list > 0) then
			if list_has_class(class, collision_list) then
				return i
			end
		end
	end
	return search_path_length
end

local function distance_to_class_y(self, dy, class, grid, search_path_length)
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if grid:is_blocked_cell(cell_x, cell_y + dy * i) then
			return search_path_length
		end

		local collision_list = grid:get_collisions_in_cell(cell_x, cell_y + dy * i)
		if (#collision_list > 0) then
			if list_has_class(class, collision_list) then
				return i
			end
		end
	end
	return search_path_length
end

local function distance_in_front_class(self, class, grid, search_path_length)
	if self._orientation == "up" then
		return distance_to_class_y(self, -1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "down" then
		return distance_to_class_y(self, 1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "left" then
		return distance_to_class_x(self, -1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "right" then
		return distance_to_class_x(self, 1, class, grid, search_path_length)/search_path_length
	end
	print("no orientation set", self._orientation)
end

local function distance_in_back_class(self, class, grid, search_path_length)
	if self._orientation == "up" then
		return distance_to_class_y(self, 1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "down" then
		return distance_to_class_y(self, -1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "left" then
		return distance_to_class_x(self, 1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "right" then
		return distance_to_class_x(self, -1, class, grid, search_path_length)/search_path_length
	end
	print("no orientation set", self._orientation)
end

local function distance_in_left_class(self, class, grid, search_path_length)
	if self._orientation == "up" then
		return distance_to_class_x(self, -1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "down" then
		return distance_to_class_x(self, 1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "left" then
		return distance_to_class_y(self, 1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "right" then
		return distance_to_class_y(self, -1, class, grid, search_path_length)/search_path_length
	end
	print("no orientation set", self._orientation)
end

local function distance_in_right_class(self, class, grid, search_path_length)
	if self._orientation == "up" then
		return distance_to_class_x(self, 1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "down" then
		return distance_to_class_x(self, -1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "left" then
		return distance_to_class_y(self, -1, class, grid, search_path_length)/search_path_length
	elseif self._orientation == "right" then
		return distance_to_class_y(self, 1, class, grid, search_path_length)/search_path_length
	end
	print("no orientation set", self._orientation)
end

local function find_collision_in_path_x(self, dx, grid, search_path_length)
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if grid:is_blocked_cell(cell_x + dx * i, cell_y) then
			return (search_path_length - i)
		end
	end
	return 0
end

local function find_collision_in_path_y(self, dy, grid, search_path_length)
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if grid:is_blocked_cell(cell_x, cell_y + dy * i) then
			return (search_path_length - i)
		end
	end
	return 0
end

local function distance_in_front_collision(self, search_path_length)
	if self._orientation == "up" then
		return self:find_collision_in_path_y(-1)/search_path_length
	elseif self._orientation == "down" then
		return self:find_collision_in_path_y(1)/search_path_length
	elseif self._orientation == "left" then
		return self:find_collision_in_path_x(-1)/search_path_length
	elseif self._orientation == "right" then
		return self:find_collision_in_path_x(1)/search_path_length
	end
	print("no orientation set", self._orientation)
end

local function is_front_collision(self, grid)
	if self._orientation == "up" then
		return grid:is_blocked_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	elseif self._orientation == "down" then
		return grid:is_blocked_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	elseif self._orientation == "left" then
		return grid:is_blocked_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "right" then
		return grid:is_blocked_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	end
	print("no orientation set", self._orientation)
end

local function is_left_collision(self, grid)
	if self._orientation == "up" then
		return grid:is_blocked_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "down" then
		return grid:is_blocked_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	elseif self._orientation == "left" then
		return grid:is_blocked_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	elseif self._orientation == "right" then
		return grid:is_blocked_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	end
	print("no orientation set", self._orientation)
end

local function is_right_collision(self, grid)
	if self._orientation == "up" then
		return grid:is_blocked_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	elseif self._orientation == "down" then
		return grid:is_blocked_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "left" then
		return grid:is_blocked_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	elseif self._orientation == "right" then
		return grid:is_blocked_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	end
	print("no orientation set", self._orientation)
end

local function is_collision_x(self, dx, grid)
	return grid:is_blocked_cell(self._cell.x + dx, self._cell.y) and 1 or 0
end

local function is_collision_y(self, dy, grid)
	return grid:is_blocked_cell(self._cell.x, self._cell.y + dy) and 1 or 0
end

local function grade_path_x(self, dx, grid, search_path_length, ghost_state)
	local inputs = {
		is_collision_x(self, dx, grid),
		distance_to_class_x(self, dx, "ghost", grid, search_path_length)/search_path_length,
		distance_to_class_x(self, dx, "pill", grid, search_path_length)/search_path_length,
		distance_to_class_x(self, dx, "player", grid, search_path_length)/search_path_length,
		(ghost_state == "frightened") and 1 or 0, -- ghosts freightned
		(ghost_state == "scattering") and 1 or 0, -- ghosts scattering
	}

	local outputs = self._ann:get_outputs(inputs, true)

	return outputs[1].value
end

local function grade_path_y(self, dy, grid, search_path_length, ghost_state)
	local inputs = {
		is_collision_y(dy),
		distance_to_class_y(self, dy, "ghost", grid, search_path_length)/search_path_length,
		distance_to_class_y(self,dy, "pill", grid, search_path_length)/search_path_length,
		distance_to_class_y(self, dy,"player", grid, search_path_length)/search_path_length,
		(ghost_state == "frightened") and 1 or 0, -- ghosts freightned
		(ghost_state == "scattering") and 1 or 0, -- ghosts scattering
	}

	local outputs = self._ann:get_outputs(inputs, true)

	return outputs[1].value
end

-- implementations
AutoplayerAnnModes.ann_creates["nb4"] = function (self, ann_depth, ann_width)
	return qpd.ann:new(17, 1, ann_depth, ann_width)
end
AutoplayerAnnModes.updates.nb4 = function (self, grid, search_path_length, ghost_state)
	local inputs = {
		is_left_collision(self, grid),
		is_front_collision(self, grid),
		is_right_collision(self, grid),
		distance_in_front_class(self, "ghost", grid, search_path_length),
		distance_in_back_class(self, "ghost", grid, search_path_length),
		distance_in_left_class(self, "ghost", grid, search_path_length),
		distance_in_right_class(self, "ghost", grid, search_path_length),
		distance_in_front_class(self, "pill", grid, search_path_length),
		distance_in_back_class(self, "pill", grid, search_path_length),
		distance_in_left_class(self, "pill", grid, search_path_length),
		distance_in_right_class(self, "pill", grid, search_path_length),
		distance_in_front_class(self, "player", grid, search_path_length),
		distance_in_back_class(self, "player", grid, search_path_length),
		distance_in_left_class(self, "player", grid, search_path_length),
		distance_in_right_class(self, "player", grid, search_path_length),
		(ghost_state == "frightened") and 1 or 0, -- ghosts freightned
		(ghost_state == "scattering") and 1 or 0, -- ghosts scattering
	}

	local outputs = self._ann:get_outputs(inputs, true)

	local greatest_index = 1
	local greatest_value = outputs[greatest_index].value
	for i = 1, #outputs do
		if outputs[i].value > greatest_value then
			greatest_index = i
		end
	end

	if greatest_index == 1 then
		keep(self)
	elseif greatest_index == 2 then
		flip(self)
	elseif greatest_index == 3 then
		rotate_left(self)
	elseif greatest_index == 4 then
		rotate_right(self)
	end

	self._next_direction = self._orientation

	-- fitness reward
	self._fitness = self._fitness + 0.0001
end

AutoplayerAnnModes.ann_creates.nb4_valid_paths = function (self, ann_depth, ann_width)
	self._ann = qpd.ann:new(6, 1, ann_depth, ann_width)
end
AutoplayerAnnModes.updates.nb4_valid_paths = function (self, grid, search_path_length, ghost_state)
	self._orientation = self._direction  -- not needed, just to keep it synced
	self._fitness = self._fitness + 1

	local enabled_directions = self:get_enabled_directions()
	local available_paths = {}
	if enabled_directions[1] == true then -- "up"
		local this_direction = {}
		this_direction.grade = grade_path_y(self, -1, grid, search_path_length, ghost_state)
		this_direction.direction = "up"
		table.insert(available_paths, this_direction)
	end
	if enabled_directions[2] == true then -- "down"
		local this_direction = {}
		this_direction.grade = grade_path_y(self, 1, grid, search_path_length, ghost_state)
		this_direction.direction = "down"
		table.insert(available_paths, this_direction)
	end
	if enabled_directions[3] == true then -- "left"
		local this_direction = {}
		this_direction.grade = grade_path_x(self, -1, grid, search_path_length, ghost_state)
		this_direction.direction = "left"
		table.insert(available_paths, this_direction)
	end
	if enabled_directions[4] == true then -- "right"
		local this_direction = {}
		this_direction.grade = grade_path_x(self, 1, grid, search_path_length, ghost_state)
		this_direction.direction = "right"
		table.insert(available_paths, this_direction)
	end

	if (#available_paths >= 2) then
		local best_index = 1
		local best_grade = available_paths[best_index].grade
		for i = 2, #available_paths do
			if (available_paths[i].grade >= best_grade) then
				best_grade = available_paths[i].grade
				best_index = i
			end
		end
		self._next_direction = available_paths[best_index].direction
	elseif (#available_paths >= 1) then
		self._next_direction = available_paths[1].direction
	else
		print("AutoPlayer has nowhere to go!")
	end
end

return AutoplayerAnnModes