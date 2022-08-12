-- Guilherme Cunha Prada 2022
local GridActor = require "entities.GridActor"
local AutoPlayerAnnModes = require "entities.AutoPlayerAnnModes"

local AutoPlayer = GridActor:new()
AutoPlayer.__index = AutoPlayer

local qpd = require "qpd.qpd"

local autoplayer_type_name = "player"

function AutoPlayer.init(grid, search_path_length, mutate_chance, mutate_percentage, ann_depth, ann_width, ann_mode)
	AutoPlayer._search_path_length = search_path_length
	AutoPlayer._max_grid_distance = math.ceil(math.sqrt((grid.width ^ 2) + (grid.height ^ 2)))

	AutoPlayer._mutate_chance = mutate_chance
	AutoPlayer._mutate_percentage = mutate_percentage
	AutoPlayer._ann_depth = ann_depth
	AutoPlayer._ann_width = ann_width
	AutoPlayer._ann_mode = ann_mode

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

	self._ann = ann or AutoPlayerAnnModes.new[AutoPlayer._ann_mode](self, AutoPlayer._ann_depth, AutoPlayer._ann_width)

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

function AutoPlayer:update(dt, speed, ghost_state)
	if (self._is_active) then
		AutoPlayerAnnModes.update[AutoPlayer._ann_mode](self, AutoPlayer._grid, AutoPlayer._search_path_length, ghost_state)
		GridActor.update(self, dt, speed)

		-- fitness reward
		self._fitness = self._fitness + 0.0001
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

function AutoPlayer:get_genes()
	return self:get_ann():to_string()
end

function AutoPlayer:add_fitness(amount)
	self._fitness = self._fitness + amount
end

function AutoPlayer:get_history()
	return {_fitness = self:get_fitness(), _ann = self:get_ann()}
end

return AutoPlayer
