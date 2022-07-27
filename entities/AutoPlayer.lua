-- Guilherme Cunha Prada 2022
local GridActor = require "entities.GridActor"
local AutoPlayer = GridActor:new()
AutoPlayer.__index = AutoPlayer

local qpd = require "qpd.qpd"

local autoplayer_type_name = "player"

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

	self._ann = ann or qpd.ann:new(8, 4, AutoPlayer._ann_depth, AutoPlayer._ann_width)
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

function AutoPlayer:find_in_path_x(dx, class)
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

function AutoPlayer:find_in_path_y(dy, class)
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

function AutoPlayer:distance_in_front_class(class)
	if self._orientation == "up" then
		return self:find_in_path_y(-1, class)/AutoPlayer._search_path_length
	elseif self._orientation == "down" then
		return self:find_in_path_y(1, class)/AutoPlayer._search_path_length
	elseif self._orientation == "left" then
		return self:find_in_path_x(-1, class)/AutoPlayer._search_path_length
	elseif self._orientation == "right" then
		return self:find_in_path_x(1, class)/AutoPlayer._search_path_length
	end
	print("no orientation set", self._orientation)
end

function AutoPlayer:distance_in_back_class(class)
	if self._orientation == "up" then
		return self:find_in_path_y(1, class)/AutoPlayer._search_path_length
	elseif self._orientation == "down" then
		return self:find_in_path_y(-1, class)/AutoPlayer._search_path_length
	elseif self._orientation == "left" then
		return self:find_in_path_x(1, class)/AutoPlayer._search_path_length
	elseif self._orientation == "right" then
		return self:find_in_path_x(-1, class)/AutoPlayer._search_path_length
	end
	print("no orientation set", self._orientation)
end

function AutoPlayer:find_collision_in_path_x(dx)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if GridActor._grid:is_blocked_cell(cell_x + dx * i, cell_y) then
			return (search_path_length - i)
		end
	end
	return 0
end

function AutoPlayer:find_collision_in_path_y(dy)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if GridActor._grid:is_blocked_cell(cell_x, cell_y + dy * i) then
			return (search_path_length - i)
		end
	end
	return 0
end

function AutoPlayer:distance_in_front_collision()
	if self._orientation == "up" then
		return self:find_collision_in_path_y(-1)/AutoPlayer._search_path_length
	elseif self._orientation == "down" then
		return self:find_collision_in_path_y(1)/AutoPlayer._search_path_length
	elseif self._orientation == "left" then
		return self:find_collision_in_path_x(-1)/AutoPlayer._search_path_length
	elseif self._orientation == "right" then
		return self:find_collision_in_path_x(1)/AutoPlayer._search_path_length
	end
	print("no orientation set", self._orientation)
end

function AutoPlayer:is_front_collision()
	if self._orientation == "up" then
		return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	elseif self._orientation == "down" then
		return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	elseif self._orientation == "left" then
		return GridActor._grid:is_blocked_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "right" then
		return GridActor._grid:is_blocked_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	end
	print("no orientation set", self._orientation)
end

function AutoPlayer:is_left_collision()
	if self._orientation == "up" then
		return GridActor._grid:is_blocked_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "down" then
		return GridActor._grid:is_blocked_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	elseif self._orientation == "left" then
		return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	elseif self._orientation == "right" then
		return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	end
	print("no orientation set", self._orientation)
end

function AutoPlayer:is_right_collision()
	if self._orientation == "up" then
		return GridActor._grid:is_blocked_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	elseif self._orientation == "down" then
		return GridActor._grid:is_blocked_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "left" then
		return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	elseif self._orientation == "right" then
		return GridActor._grid:is_blocked_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	end
	print("no orientation set", self._orientation)
end

function AutoPlayer:update(dt, speed, ghost_state)
	if (self._is_active) then
		-- local ghost_in_front = self:distance_in_front_class("ghost")
		-- local ghosts_freighted = (ghost_state == "frightened") and 1 or 0
		local inputs = {
			self:is_left_collision(),
			self:distance_in_front_collision(),
			self:is_right_collision(),
			self:distance_in_front_class("ghost"),
			self:distance_in_back_class("ghost"),
			self:distance_in_front_class("pill"),
			self:distance_in_back_class("pill"),
			(ghost_state == "frightened") and 1 or 0, -- ghosts freightned
			-- (ghost_state == "scattering") and 1 or 0, -- ghosts scattering
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

		GridActor.update(self, dt, speed)

		-- fitness reward
		self._fitness = self._fitness + 0.0001

		-- -- rewarded if changed tile
		-- if self._changed_tile then
		-- 	if self._cell.x > self._max_cell.x then
		-- 		self._fitness = self._fitness + (self._cell.x - self._max_cell.x) * 0.01
		-- 		self._max_cell.x = self._cell.x
		-- 	elseif self._cell.y > self._max_cell.y then
		-- 		self._fitness = self._fitness + (self._cell.y - self._max_cell.y) * 0.01
		-- 		self._max_cell.y = self._cell.y
		-- 	elseif self._cell.x < self._min_cell.x then
		-- 		self._fitness = self._fitness + (self._min_cell.x - self._cell.x) * 0.01
		-- 		self._min_cell.x = self._cell.x
		-- 	elseif self._cell.y < self._min_cell.y then
		-- 		self._fitness = self._fitness + (self._min_cell.y - self._cell.y) * 0.01
		-- 		self._min_cell.y = self._cell.y
		-- 	end
		-- end

		-- -- remove if colliding
		-- if self._has_collided then
		-- 	print(self._fitness)
		-- 	self._fitness = self._fitness - 0.01
		-- 	if self._fitness < 0 then
		-- 		self._fitness = 0
		-- 		self._is_active = false
		-- 	end
		-- end
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
