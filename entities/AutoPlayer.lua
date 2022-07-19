-- Guilherme Cunha Prada 2022
local GridActor = require "entities.GridActor"
local AutoPlayer = GridActor:new()
AutoPlayer.__index = AutoPlayer

local qpd = require "qpd.qpd"

local autoplayer_type_name = "player"

local outputs_to_next_direction = {
	"up",
	"down",
	"left",
	"right",
	"do_nothing",
}

function AutoPlayer.init(grid, search_path_length)
	GridActor.init(grid)

	AutoPlayer._search_path_length = search_path_length
	AutoPlayer._max_grid_distance = math.ceil(math.sqrt((grid.width ^ 2) + (grid.height ^ 2)))
	AutoPlayer._hunger_limit = 144 * 60 * 1

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
	self._hunger = 0

	local target_grid = AutoPlayer.grid:get_valid_cell()
	self._home_grid.x = target_grid.x
	self._home_grid.y = target_grid.y

	self._target_grid.x = target_grid.x
	self._target_grid.y = target_grid.y


	self._ann = ann or qpd.ann:new(6, 5, 1, 5)
end

function AutoPlayer:crossover(mom, dad, reset_table)
	local newAnn = qpd.ann:crossover(mom._ann, dad._ann)
	-- reset
	self:reset({speed = reset_table.speed, ann = newAnn})
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
	local search_path_length = -AutoPlayer._search_path_length
	for i = 1, search_path_length do
		if not GridActor.grid:is_grid_way({x = self._cell.x + dx, y = self._cell.y}) then
			return i - search_path_length
		end

		local obj_list = AutoPlayer.grid:get_grid_actors_in_position({x = self._cell + dx * i, y = self._cell.y})
		if (#obj_list > 0) then
			if list_has_class("ghost") then
				return i - search_path_length
			elseif list_has_class("pill") or list_has_class("player") then
				return search_path_length - i
			end
		end
	end
	return search_path_length
end

function AutoPlayer:find_in_path_y(dy)
	local search_path_length = -AutoPlayer._search_path_length
	for i = 1, search_path_length do
		if not GridActor.grid:is_grid_way({x = self._cell.x, y = self._cell.y + dy}) then
			return i - search_path_length
		end

		local obj_list = AutoPlayer.grid:get_grid_actors_in_position({x = self._cell, y = self._cell.y  + dy * i})
		if (#obj_list > 0) then
			if list_has_class("ghost") then
				return i - search_path_length
			elseif list_has_class("pill") or list_has_class("player") then
				return search_path_length - i
			end
		end
	end
	return search_path_length
end

function AutoPlayer:update(dt, tilesize, ghost_state)
	if (self._is_active) then
		local inputs = {
			self:find_in_path_x(1),
			self:find_in_path_x(-1),
			self:find_in_path_y(1),
			self:find_in_path_y(-1),
			(ghost_state == "frightened") and 0 or 1, -- ghosts freightned
			(ghost_state == "scattering") and 0 or 1, -- ghosts scattering
		}
		local outputs = self._ann:get_outputs(inputs)

		local greatest_index = 1
		local greatest_value = outputs[greatest_index].value
		for i = 2, #outputs do
			local this_value = outputs[i].value

			if this_value >= greatest_value then
				greatest_value = this_value
				greatest_index = i
			end
		end

		if not (greatest_index == 5) then
			self.next_direction = outputs_to_next_direction[greatest_index]
		end
		-- print(self.next_direction)

		GridActor.update(self, dt, tilesize)
		if self.changed_tile == true then
			self._fitness = self._fitness + 0.001
		end
	end
end

function AutoPlayer:got_ghost()
	self:add_fitness(1)
	self._hunger = 0
end

function AutoPlayer:got_pill()
	self:add_fitness(1)
	self._hunger = 0
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
