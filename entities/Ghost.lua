-- Guilherme Cunha Prada 2019
local GridActor = require "entities.GridActor"
local Ghost = GridActor:new()
Ghost.__index = Ghost

local qpd = require "qpd.qpd"
local ghost_type_name = "ghost"

Ghost._state = "none"

function Ghost.set_state(new_state)
	Ghost._state = new_state
end

function Ghost.set_speed(new_speed)
	Ghost._speed = new_speed
end

function Ghost.init(Grid,
					initial_state,
					target_spread)
	Ghost._grid = Grid
	Ghost._target_spread = target_spread
	Ghost.set_state(initial_state)

	GridActor.register_type(ghost_type_name)
end

function Ghost:new(o)
	local o = GridActor:new(o or {})
	setmetatable(o, self)

	o._home = {} -- determined by pos_index, it is a phenotype
	o._try_order = {} -- gene

	o._type = GridActor.get_type_by_name(ghost_type_name)

	return  o
end

function Ghost:reset(reset_table)
	local home_cell, target_offset, try_order
	if reset_table then
		home_cell = reset_table.home_cell
		target_offset = reset_table.target_offset
		try_order = reset_table.try_order
	end
	home_cell = home_cell or Ghost._grid:get_invalid_cell()

	target_offset = target_offset or qpd.random.random(math.floor(-Ghost._target_spread), math.ceil(Ghost._target_spread))
	try_order = try_order or nil

	if not try_order then
		try_order = {}
		for i = 1, 4, 1 do
			try_order[i] = i
		end
		qpd.array.shuffle(try_order)
	end

	self._try_order[1] = try_order[1]
	self._try_order[2] = try_order[2]
	self._try_order[3] = try_order[3]
	self._try_order[4] = try_order[4]

	self._home.x = home_cell.x
	self._home.y = home_cell.y

	GridActor.reset(self, Ghost._grid:get_valid_cell())

	self._n_catches = 0
	self._fitness = 0

	self._target_offset = target_offset

	-- set a valid direction
	self:set_random_valid_direction()
	self._debounce_get_next_direction = true
	self:update_dynamic_front()
end

function Ghost:get_history()
	return {
		_fitness = self._fitness,
		_target_offset = self._target_offset,
		_try_order = self._try_order
	}
end

function Ghost:crossover(mom, dad, reset_table)
	local son = {}

	local target_offset = math.floor((mom._target_offset + dad._target_offset)/2)

	if (qpd.random.random(0, 10)<=3) then -- mutate
		target_offset = target_offset + math.floor(qpd.random.random(-2, 2))
	end

	son.try_order = {} -- we should add mutation

	local this_rand = qpd.random.random(0, 10)
	if (this_rand <= 3) then
		for i = 1, #mom.try_order, 1 do
			son.try_order[i] = mom.try_order[i]
		end
	elseif (this_rand <= 5) then
		for i = 1, #dad.try_order, 1 do
			son.try_order[i] = dad.try_order[i]
		end
	else
		for i = 1, 4, 1 do
			son.try_order[i] = i
		end
		qpd.array.shuffle(son.try_order)
	end

	self:reset({target_offset = son._target_offset})
end

function Ghost:is_type(type_name)
	if type_name == ghost_type_name then
		return true
	else
		return false
	end
end

function Ghost:draw(state)
	if self._is_active then
		if(self._target_offset <= 0)then
			if (self._target_offset == -1) then
				love.graphics.setColor(0.2, 0.5, 0.8)
			elseif (self._target_offset == -2) then
				love.graphics.setColor(0.4, 0.5, 0.6)
			elseif (self._target_offset == -3) then
				love.graphics.setColor(0.6, 0.5, 0.4)
			elseif (self._target_offset == -4) then
				love.graphics.setColor(0.8, 0.5, 0.2)
			else--if (self._target_offset < -4) then
				love.graphics.setColor(1, 0.5, 0)
			end
		else
			if (self._target_offset == 1) then
				love.graphics.setColor(0.5, 0.2, 0.8)
			elseif (self._target_offset == 2) then
				love.graphics.setColor(0.5, 0.4, 0.6)
			elseif (self._target_offset == 3) then
				love.graphics.setColor(0.5, 0.6, 0.4)
			elseif (self._target_offset == 4) then
				love.graphics.setColor(0.5, 0.8, 0.2)
			else--if (self._target_offset > 4) then
				love.graphics.setColor(0.5, 1, 0)
			end
		end

		love.graphics.circle("fill", self.x, self.y, Ghost._tilesize * 0.5)

		local middle_x, middle_y = qpd.point.middle_point2(self, self._front)
		middle_x, middle_y = qpd.point.middle_point(self.x, self.y, middle_x, middle_y)
		middle_x, middle_y = qpd.point.middle_point(self.x, self.y, middle_x, middle_y)
		love.graphics.circle("fill", middle_x, middle_y, Ghost._tilesize/4)

		love.graphics.setColor(1, 1, 1)
	end
end

function Ghost:collided(other)
	if other:is_type("player") then
		if (Ghost._state ~= "frightened") then
			--print("you loose, my target is: " .. self._target_offset)
			-- Ghost.reporter.report_catched(self._target_offset)

			self._n_catches = self._n_catches + 1
			other._is_active = false
		else
			if self.got_ghost then
				self:got_ghost()
			end
			self._is_active = false
		end
	end
end

function Ghost:update(dt, speed, targets)
	if (self._is_active) then
		if speed*dt > (GridActor._tilesize/2) then
			print("physics sanity check failed, Actor traveled distance > tilesize")
		end

		if GridActor._tilesize ~= self._tilesize then
			self._tilesize = GridActor._tilesize
			-- here we just center on grid, we should perhaps do a scaling
			self:center_on_cell()
		end
		Ghost._grid:update_collision(self)

		self._fitness = self._n_catches

		-- updates average distance to player and group,
		-- it is used for collision
		local target
		if #targets > 0 then
			target = targets[1]
			local target_distance = qpd.point.distance2(target, self)
			for i = 2, #targets do
				local this_target = targets[i]
				if this_target._is_active then
					local this_target_distance = qpd.point.distance2(this_target, self)
					if (this_target_distance < target_distance) then
						target = this_target
						target_distance = this_target_distance
					end
				end
			end

			if target_distance < Ghost._tilesize then
				self:collided(target)
			end
		else
			target = Ghost._grid:get_invalid_cell()
		end

		self:update_dynamic_front()
		self:update_cell()

		-- check collision with wall
		self._has_collided = false
		if(self:is_front_wall()) then
			self:center_on_cell() -- it stops relayed cornering
			self:find_next_direction(target)
			self._has_collided = true
		end

		--on change tile
		self._changed_tile = false
		if  self._cell.x ~= self._last_cell.x then
			self._changed_tile = "x"
		end
		if self._cell.y ~= self._last_cell.y then
			if self._changed_tile then
				self._changed_tile = "xy"
			else
				self._changed_tile = "y"
			end
		end
		if self._changed_tile then
			self._debounce_get_next_direction = false
		end

		--on tile center, or close
		local dist_grid_center = qpd.point.distance(self.x, self.y, Ghost._grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize))
		if (dist_grid_center < speed*dt) then
			if ( self._direction == "up" or self._direction== "down") then
				self:center_on_cell_x()
			elseif ( self._direction == "left" or self._direction== "right") then
				self:center_on_cell_y()
			end
			self:find_next_direction(target)
		end

		if self._direction ~= "idle" then
			--print("X: ", self.x, "Y:", self.y)
			if self._direction == "up" then self.y = self.y - dt * speed
			elseif self._direction == "down" then self.y = self.y + dt * speed
			elseif self._direction == "left" then self.x = self.x -dt * speed
			elseif self._direction == "right" then self.x = self.x +dt * speed
			end
		end

	end
end

function Ghost:find_next_direction(target)
	if self._debounce_get_next_direction == true then
		return
	else
		self._debounce_get_next_direction = true

		self.enabled_directions = self:get_enabled_directions()
		if (#self.enabled_directions < 1) then
			print("enabled_directions cant be empty")
		elseif not Ghost._grid:is_corridor(self._cell.x, self._cell.y) then
		-- if 	(Ghost._grid.grid_types[self._cell.y][self._cell.x]~=3 and-- invertido
		-- 	Ghost._grid.grid_types[self._cell.y][self._cell.x]~=12 ) then
			--check which one is closer to the target
			-- make a table to contain the posible destinations
			local possible_next_moves = {}
			for i = 1, #self._try_order, 1 do
				if (self.enabled_directions[self._try_order[i]] == true) then
					local cell = {}
					if(self._try_order[i] == 1) then
						cell.x = self._cell.x
						cell.y = self._cell.y - 1
						cell._direction = "up"
					elseif(self._try_order[i] == 2) then
						cell.x = self._cell.x
						cell.y = self._cell.y + 1
						cell._direction = "down"
					elseif(self._try_order[i] == 3) then
						cell.x = self._cell.x - 1
						cell.y = self._cell.y
						cell._direction = "left"
					elseif(self._try_order[i] == 4) then
						cell.x = self._cell.x + 1
						cell.y = self._cell.y
						cell._direction = "right"
					end

					-- ghost can not reverse direction, so
					if Ghost._grid.oposite_direction[self._direction] ~= cell._direction then
						table.insert(possible_next_moves, cell)
					end
				end
			end

			if (#possible_next_moves == 0) then
				print("possible_next_moves cant be empty")
				return
			end

			if (target._is_active) then
				if (Ghost._state == "chasing") then
					self:go_to_target(target, possible_next_moves)
				elseif (Ghost._state == "scattering") then
						self:go_home(possible_next_moves)
				elseif (Ghost._state == "frightened") then
					self:wander(possible_next_moves)
				else
					print("error, invalid ghost_state")
				end
			else
				self:go_home(possible_next_moves)
			end
		end
	end
end

---------------------------------------------------------------
function Ghost:catch_target(target, possible_next_moves)
	local destination = {}

	destination.x = target._cell.x
	destination.y = target._cell.y

	self:get_closest(possible_next_moves, destination)
end

function Ghost:go_to_target(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target._cell.x
		destination.y = -self._target_offset + target._cell.y
	elseif (target._direction == "down") then
		destination.x = target._cell.x
		destination.y = self._target_offset + target._cell.y
	elseif (target._direction == "left") then
		destination.x = -self._target_offset + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "right") then
		destination.x = self._target_offset + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "idle") then
		destination.x = target._cell.x
		destination.y = target._cell.y
	end

	self:get_closest(possible_next_moves, destination)
end

function Ghost:surround_target_front(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target._cell.x
		destination.y = -4 + target._cell.y
	elseif (target._direction == "down") then
		destination.x = target._cell.x
		destination.y = 4 + target._cell.y
	elseif (target._direction == "left") then
		destination.x = -4 + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "right") then
		destination.x = 4 + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "idle") then
		destination.x = target._cell.x
		destination.y = target._cell.y
	end

	self:get_closest(possible_next_moves, destination)
end

function Ghost:surround_target_back(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target._cell.x
		destination.y = 4 + target._cell.y
	elseif (target._direction == "down") then
		destination.x = target._cell.x
		destination.y = -4 + target._cell.y
	elseif (target._direction == "left") then
		destination.x = 4 + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "right") then
		destination.x = -4 + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "idle") then
		destination.x = target._cell.x
		destination.y = target._cell.y
	end

	self:get_closest(possible_next_moves, destination)
end

function Ghost:wander(possible_next_moves)
	local destination = {}
	local valid_cell = Ghost._grid:get_invalid_cell()

	destination.x = valid_cell.x
	destination.y = valid_cell.y

	self:get_closest(possible_next_moves, destination)
end

function Ghost:go_home(possible_next_moves)
	local destination = {}
	destination.x = self._home.x
	destination.y = self._home.y

	self:get_closest(possible_next_moves, destination)
end

function Ghost:go_to_group(possible_next_moves, average_ghost_pos)
	local this_grid_pos = Ghost._grid:get_grid_pos_absolute(average_ghost_pos)

	local destination = {}
	destination.x =  this_grid_pos.x
	destination.y =  this_grid_pos.y

	self:get_closest(possible_next_moves, destination)
end


function Ghost:run_from_target(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target._cell.x
		destination.y = -self._target_offset + target._cell.y
	elseif (target._direction == "down") then
		destination.x = target._cell.x
		destination.y = self._target_offset + target._cell.y
	elseif (target._direction == "left") then
		destination.x = -self._target_offset + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "right") then
		destination.x = self._target_offset + target._cell.x
		destination.y = target._cell.y
	elseif (target._direction == "idle") then
		destination.x = target._cell.x
		destination.y = target._cell.y
	end

	self:get_furthest(possible_next_moves, destination)
end

function Ghost:go_to_closest_pill(possible_next_moves)
	local destination = {}

	destination.x = self._grid_pos_closest_pill.x
	destination.y = self._grid_pos_closest_pill.y

	self:get_closest(possible_next_moves, destination)
end


function Ghost:get_closest(possible_next_moves, destination)
	local shortest = 1
	local shortest_distance = qpd.point.distance2(possible_next_moves[shortest], destination)
	for i = 2, #possible_next_moves, 1 do
		local this_dist = qpd.point.distance2(possible_next_moves[i], destination)
		if (this_dist <= shortest_distance) then
			shortest = i
			shortest_distance = this_dist
		end
	end
	self._direction = possible_next_moves[shortest]._direction
end

function Ghost:get_furthest(possible_next_moves, destination)
	local furthest = 1
	local furthest_distance = qpd.point.distance2(possible_next_moves[furthest], destination)
	for i = 2, #possible_next_moves, 1 do
		local this_dist = qpd.point.distance2(possible_next_moves[i], destination)
		if (this_dist >= possible_next_moves[furthest].dist) then
			furthest = i
			furthest_distance = this_dist
		end
	end
	self._direction = possible_next_moves[furthest]._direction
end

function Ghost:flip_direction()
	if (self._is_active == false) then return end
	if(self._direction == "up") then self._direction = "down"
	elseif(self._direction == "down") then self._direction = "up"
	elseif(self._direction == "left") then self._direction = "right"
	elseif(self._direction == "right") then self._direction = "left" end
end

return Ghost
