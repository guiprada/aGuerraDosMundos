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

function AutoPlayer.init(grid, search_path_length, mutate_chance, mutate_percentage)
	GridActor.init(grid)

	AutoPlayer._search_path_length = search_path_length
	AutoPlayer._max_grid_distance = math.ceil(math.sqrt((grid.width ^ 2) + (grid.height ^ 2)))

	AutoPlayer._mutate_chance = 0.05 or mutate_chance
	AutoPlayer._mutate_percentage = 0.05 or mutate_percentage

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

function AutoPlayer:reset(tilesize, reset_table)
	local cell = reset_table._cell
	local speed = reset_table.speed
	local ann = reset_table.ann

	cell = cell or AutoPlayer.grid:get_valid_cell()
	GridActor.reset(self, cell, speed, tilesize)

	self._fitness = 0
	self._collision_counter = 0

	local target_grid = AutoPlayer.grid:get_valid_cell()
	self._home_grid.x = target_grid.x
	self._home_grid.y = target_grid.y

	self._target_grid.x = target_grid.x
	self._target_grid.y = target_grid.y

	self:set_random_valid_direction()
	self._orientation = self.direction
	self.rotate = qpd.random.choose(rotate_left, rotate_right)

	self._ann = ann or qpd.ann:new(5, 1, 1, 5)
end

function AutoPlayer:crossover(mom, dad, tilesize, reset_table)
	local newAnn = qpd.ann:crossover(mom._ann, dad._ann, self._mutate_chance, self._mutate_percentage)
	-- reset
	self:reset(tilesize, {speed = reset_table.speed, ann = newAnn})
end

function AutoPlayer:draw(tilesize)
	--AutoPlayer body :)
	if (self._is_active) then
		love.graphics.setColor(0.9, 0.9, 0.9)
		love.graphics.circle(	"fill",
								self.x,
								self.y,
								tilesize*0.55)

		-- front dot
		love.graphics.setColor(1, 0, 1)
		--love.graphics.setColor(138/255,43/255,226/255, 0.9)
		love.graphics.circle(	"fill",
								self.front.x,
								self.front.y,
								tilesize/5)
		-- front line, mesma cor
		-- love.graphics.setColor(1, 0, 1)
		love.graphics.line(self.x, self.y, self.front.x, self.front.y)
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
		if not GridActor.grid:is_valid_cell(cell_x + dx * i, cell_y) then
			return 0
		end

		local collision_list = AutoPlayer.grid:get_collisions_in_cell(cell_x + dx * i, cell_y)
		if (#collision_list > 0) then
			if list_has_class(class, collision_list) then
				return (search_path_length - i)
			end
		end
	end
	return search_path_length
end

function AutoPlayer:find_in_path_y(dy, class)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if not GridActor.grid:is_valid_cell(cell_x, cell_y + dy * i) then
			return 0
		end

		local collision_list = AutoPlayer.grid:get_collisions_in_cell(cell_x, cell_y + dy * i)
		if (#collision_list > 0) then
			if list_has_class(class, collision_list) then
				return (search_path_length - i)
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
end

function AutoPlayer:find_collision_in_path_x(dx)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if not GridActor.grid:is_valid_cell(cell_x + dx * i, cell_y) then
			return (search_path_length - i)
		end
	end
	return 0
end

function AutoPlayer:find_collision_in_path_y(dy)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y = self._cell.x, self._cell.y

	for i = 1, search_path_length do
		if not GridActor.grid:is_valid_cell(cell_x, cell_y + dy * i) then
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
end

function AutoPlayer:is_front_collision()
	if self._orientation == "up" then
		return GridActor.grid:is_valid_cell(self._cell.x - 1, self._cell.y) and 1 or 0
	elseif self._orientation == "down" then
		return GridActor.grid:is_valid_cell(self._cell.x + 1, self._cell.y) and 1 or 0
	elseif self._orientation == "left" then
		return GridActor.grid:is_valid_cell(self._cell.x, self._cell.y - 1) and 1 or 0
	elseif self._orientation == "right" then
		return GridActor.grid:is_valid_cell(self._cell.x, self._cell.y + 1) and 1 or 0
	end
end

function AutoPlayer:update(dt, tilesize, ghost_state)
	if (self._is_active) then
		local inputs = {
			self:distance_in_front_collision(),
			self:distance_in_front_class("ghost"),
			self:distance_in_front_class("pill"),
			(ghost_state == "frightened") and 0 or 1, -- ghosts freightned
			(ghost_state == "scattering") and 0 or 1, -- ghosts scattering
		}
		local outputs = self._ann:get_outputs(inputs)

		if outputs[1].value == 1 then
			self:rotate()
			-- self.next_direction = self._orientation
			self.direction = self._orientation
		end

		GridActor.update(self, dt, tilesize)

		-- rewarded if changed tile
		if self.changed_tile == true then
			if not self._change_boost then
				self._change_boost = 1
			end

			local changed_tile_x, changed_tile_y
			if self._cell.x ~= self.last_cell.x then
				changed_tile_x = true
			elseif self._cell.y ~= self.last_cell.y then
				changed_tile_y = true
			end
			if changed_tile_x then
				self._change_in_x = true
			elseif changed_tile_y then
				self._change_in_y = true
			end

			if self._change_in_x and self._change_in_y then
				self._change_boost = 10
			end

			self._fitness = self._fitness + 0.1 * self._change_boost
			self._not_changed_tile = 0
		else
			if not self._not_changed_tile then
				self._not_changed_tile = 1
			else
				self._not_changed_tile = self._not_changed_tile + 1
				if self._not_changed_tile > 60 then
					self._is_active = false
				end
			end
		end

		-- -- remove if colliding
		-- if self._has_collided then
		-- 	self._collision_counter = self._collision_counter + 1
		-- 	if self._collision_counter > 50 then
		-- 		self._is_active = false
		-- 	end
		-- else
		-- 	self._collision_counter = 0
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

function  AutoPlayer:get_history()
	return {_fitness = self:get_fitness(), _ann = self:get_ann()}
end

return AutoPlayer
