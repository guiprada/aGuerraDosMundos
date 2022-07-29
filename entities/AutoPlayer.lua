-- Guilherme Cunha Prada 2022
local GridActor = require "entities.GridActor"
local AutoPlayer = GridActor:new()
AutoPlayer.__index = AutoPlayer

local qpd = require "qpd.qpd"

local autoplayer_type_name = "player"

function AutoPlayer.init(grid, search_path_length, mutate_chance, mutate_percentage, ann_depth, ann_width)
	AutoPlayer._search_path_length = search_path_length
	AutoPlayer._max_grid_distance = math.ceil(math.sqrt((grid.width ^ 2) + (grid.height ^ 2)))

	AutoPlayer._mutate_chance = mutate_chance
	AutoPlayer._mutate_percentage = mutate_percentage
	AutoPlayer._ann_depth = ann_depth
	AutoPlayer._ann_width = ann_width

	GridActor.register_type(autoplayer_type_name)
end

function AutoPlayer:new(o)
	local o = GridActor:new(o or {})
	setmetatable(o, self)

	o._type = GridActor.get_type_by_name(autoplayer_type_name)
	self._target_grid = {}
	self._home_grid = {}

	return o
end

function AutoPlayer:reset(reset_table)
	local cell, ann
	if reset_table then
		cell = reset_table.cell
		ann = reset_table.ann
	end

	cell = cell or AutoPlayer._grid:get_valid_cell()

	GridActor.reset(self, cell)

	self._fitness = 0
	self._collision_counter = 0

	local target_grid = AutoPlayer._grid:get_valid_cell()
	self._home_grid.x = target_grid.x
	self._home_grid.y = target_grid.y

	self._target_grid.x = target_grid.x
	self._target_grid.y = target_grid.y

	self:set_random_valid_direction()
	self._orientation = self._direction

	if not self._max_cell then
		self._max_cell = {}
	end
	if not self._min_cell then
		self._min_cell = {}
	end
	self._min_cell.x = self._cell.x
	self._max_cell.x = self._cell.x
	self._min_cell.y = self._cell.y
	self._max_cell.y = self._cell.y

	self._ann = ann or qpd.ann:new(4, 1, AutoPlayer._ann_depth, AutoPlayer._ann_width)
end

function AutoPlayer:crossover(mom, dad)
	local newAnn = qpd.ann:crossover(mom._ann, dad._ann, self._mutate_chance, self._mutate_percentage)
	-- reset
	self:reset({ann = newAnn})
end

function AutoPlayer:draw()
	--AutoPlayer body :)
	if (self._is_active) then
		love.graphics.setColor(0.9, 0.9, 0.9)

		love.graphics.circle("fill", self.x, self.y, self._tilesize*0.55)

		-- front dot
		love.graphics.setColor(1, 0, 1)
		--love.graphics.setColor(138/255,43/255,226/255, 0.9)
		love.graphics.circle("fill", self._front.x,	self._front.y, self._tilesize/5)
		-- front line, mesma cor
		-- love.graphics.setColor(1, 0, 1)
		love.graphics.line(self.x, self.y, self._front.x, self._front.y)

		-- orientation based "eyes"
		love.graphics.setColor(0.3, 0.2, 0.2)
		local eye_drift = self._tilesize * 0.3
		if self._orientation == "up" then
			love.graphics.circle("fill", self.x, self.y - eye_drift, self._tilesize*0.1)
		elseif self._orientation == "down" then
			love.graphics.circle("fill", self.x, self.y + eye_drift, self._tilesize*0.1)
		elseif self._orientation == "left" then
			love.graphics.circle("fill", self.x - eye_drift, self.y, self._tilesize*0.1)
		elseif self._orientation == "right" then
			love.graphics.circle("fill", self.x + eye_drift, self.y, self._tilesize*0.1)
		end

		-- reset color
		love.graphics.setColor(1,1,1)
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

function AutoPlayer:distance_to_class_x(dx, class)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if GridActor._grid:is_blocked_cell(cell_x + dx * i, cell_y) then
			return search_path_length
		end

		local collision_list = AutoPlayer._grid:get_collisions_in_cell(cell_x + dx * i, cell_y)
		if (#collision_list > 0) then
			if list_has_class(class, collision_list) then
				return i
			end
		end
	end
	return search_path_length
end

function AutoPlayer:distance_to_class_y(dy, class)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if GridActor._grid:is_blocked_cell(cell_x, cell_y + dy * i) then
			return search_path_length
		end

		local collision_list = AutoPlayer._grid:get_collisions_in_cell(cell_x, cell_y + dy * i)
		if (#collision_list > 0) then
			if list_has_class(class, collision_list) then
				return i
			end
		end
	end
	return search_path_length
end

function AutoPlayer:is_collision_x(dx)
	return GridActor._grid:is_blocked_cell(self._cell.x + dx, self._cell.y) and 1 or 0
end

function AutoPlayer:is_collision_y(dy)
	return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y + dy) and 1 or 0
end

function AutoPlayer:grade_path_x(dx, ghost_state)
	local inputs = {
		self:is_collision_x(dx),
		self:distance_to_class_x(dx, "ghost")/AutoPlayer._search_path_length,
		self:distance_to_class_x(dx, "pill")/AutoPlayer._search_path_length,
		(ghost_state == "frightened") and 1 or 0, -- ghosts freightned
		-- (ghost_state == "scattering") and 1 or 0, -- ghosts scattering
	}

	local outputs = self._ann:get_outputs(inputs, true)

	return outputs[1].value
end

function AutoPlayer:grade_path_y(dy, ghost_state)
	local inputs = {
		self:is_collision_y(dy),
		self:distance_to_class_y(dy, "ghost")/AutoPlayer._search_path_length,
		self:distance_to_class_y(dy, "pill")/AutoPlayer._search_path_length,
		(ghost_state == "frightened") and 1 or 0, -- ghosts freightned
		-- (ghost_state == "scattering") and 1 or 0, -- ghosts scattering
	}

	local outputs = self._ann:get_outputs(inputs, true)

	return outputs[1].value
end

function AutoPlayer:update(dt, speed, ghost_state)
	if (self._is_active) then
		self._orientation = self._direction  -- not needed, just to keep it synced
		self._fitness = self._fitness + 1

		local enabled_directions = self:get_enabled_directions()
		local available_paths = {}
		if enabled_directions[1] == true then -- "up"
			local this_direction = {}
			this_direction.grade = self:grade_path_y(-1, ghost_state)
			this_direction.direction = "up"
			table.insert(available_paths, this_direction)
		end
		if enabled_directions[2] == true then -- "down"
			local this_direction = {}
			this_direction.grade = self:grade_path_y(1, ghost_state)
			this_direction.direction = "down"
			table.insert(available_paths, this_direction)
		end
		if enabled_directions[3] == true then -- "left"
			local this_direction = {}
			this_direction.grade = self:grade_path_x(-1, ghost_state)
			this_direction.direction = "left"
			table.insert(available_paths, this_direction)
		end
		if enabled_directions[4] == true then -- "right"
			local this_direction = {}
			this_direction.grade = self:grade_path_x(1, ghost_state)
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

		GridActor.update(self, dt, speed)
	end
end

function AutoPlayer:got_ghost()
	self:add_fitness(1)
end

function AutoPlayer:got_pill()
	self:add_fitness(1)
end

function AutoPlayer:get_ann()
	return self._ann
end

function AutoPlayer:get_fitness()
	return self._fitness
end

function AutoPlayer:add_fitness(amount)
	self._fitness = self._fitness + amount
end

function AutoPlayer:get_history()
	return {_fitness = self:get_fitness(), _ann = self:get_ann()}
end

return AutoPlayer
