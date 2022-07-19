-- Guilherme Cunha Prada 2022
local GridActor = require "entities.GridActor"
local AutoPlayer = GridActor:new()
AutoPlayer.__index = AutoPlayer

local qpd = require "qpd.qpd"

local autoplayer_type_name = "player"

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

	self._ann = ann or qpd.ann:new(3, 1, 1, 3)
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

function AutoPlayer:find_in_path_x(dx)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y
	if self:is_front_wall() then
		cell_x, cell_y = self._cell.x, self._cell.y
	else
		cell_x, cell_y = self:get_cell_in_front()
	end

	for i = 1, search_path_length do
		if not GridActor.grid:is_valid_cell(cell_x + dx * i, cell_y) then
			return - (search_path_length - i)
		end

		local collision_list = AutoPlayer.grid:get_collisions_in_cell(cell_x + dx * i, cell_y)
		if (#collision_list > 0) then
			if list_has_class("ghost", collision_list) then
				return - (search_path_length - i)
			elseif list_has_class("pill", collision_list) then -- or list_has_class("player", collision_list) then
				return search_path_length - i
			end
		end
	end
	return search_path_length
end

function AutoPlayer:find_in_path_y(dy)
	local search_path_length = AutoPlayer._search_path_length
	local cell_x, cell_y
	if self:is_front_wall() then
		cell_x, cell_y = self._cell.x, self._cell.y
	else
		cell_x, cell_y = self:get_cell_in_front()
	end

	for i = 1, search_path_length do
		if not GridActor.grid:is_valid_cell(cell_x, cell_y + dy * i) then
			return - (search_path_length - i)
		end

		local collision_list = AutoPlayer.grid:get_collisions_in_cell(cell_x, cell_y + dy * i)
		if (#collision_list > 0) then
			if list_has_class("ghost", collision_list) then
				return - (search_path_length - i)
			elseif list_has_class("pill", collision_list) then -- or list_has_class("player", collision_list) then
				return search_path_length - i
			end
		end
	end
	return search_path_length
end

function AutoPlayer:find_in_front()
	if self.direction == "up" then
		return self:find_in_path_y(-1)/AutoPlayer._search_path_length
	elseif self.direction == "down" then
		return self:find_in_path_y(1)/AutoPlayer._search_path_length
	elseif self.direction == "left" then
		return self:find_in_path_x(-1)/AutoPlayer._search_path_length
	elseif self.direction == "right" then
		return self:find_in_path_x(1)/AutoPlayer._search_path_length
	end
end

function AutoPlayer:update(dt, tilesize, ghost_state)
	if (self._is_active) then
		local last_direction = self.direction
		if self.direction == "idle" then
			local enable_directions = AutoPlayer.grid:get_enabled_directions(self._cell.x, self._cell.y)
			if enable_directions[1] == true then
				self.direction = "up"
			elseif enable_directions[2] == true then
				self.direction = "down"
			elseif enable_directions[3] == true then
				self.direction = "left"
			elseif enable_directions[4] == true then
				self.direction = "right"
			end
		end
		local inputs = {
			self:find_in_front(),
			(ghost_state == "frightened") and 0 or 1, -- ghosts freightned
			(ghost_state == "scattering") and 0 or 1, -- ghosts scattering
		}
		local outputs = self._ann:get_outputs(inputs)

		if outputs[1].value == 1 then
			-- go left
			if self.direction == "up" then
				self.next_direction = "left"
			elseif self.direction == "down" then
				self.next_direction = "right"
			elseif self.direction == "left" then
				self.next_direction = "down"
			elseif self.direction == "right" then
				self.next_direction = "up"
			end
		end

		GridActor.update(self, dt, tilesize)

		-- rewarded if changed tile
		if self.direction ~= last_direction then
			self._fitness = self._fitness + 1
		end
		if self.changed_tile == true then
			self._fitness = self._fitness + 0.1
		end

		-- remove if colliding
		if self._has_collided then
			self._collision_counter = self._collision_counter + 1
			if self._collision_counter > 10 then
				self._is_active = false
			end
		else
			self._collision_counter = 0
		end
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
