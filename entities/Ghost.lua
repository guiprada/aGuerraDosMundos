-- Guilherme Cunha Prada 2019
local GridActor = require "entities.GridActor"
local Ghost = GridActor:new()
Ghost.__index = Ghost

local qpd = require "qpd.qpd"
local ghost_type_name = "ghost"

Ghost.state = "none"

function Ghost.set_state(new_state)
	Ghost.state = new_state
end

function Ghost.set_speed(new_speed)
	Ghost._speed = new_speed
end

function Ghost.init(Grid,
					grid_size,
					speed,
					initial_state,
					target_spread)
	Ghost._grid = Grid
	Ghost._grid_size = grid_size
	Ghost._lookahead = Ghost._grid_size/2
	Ghost._speed = speed
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

function Ghost:reset(home_cell, target_offset, speed)
	local home_cell = home_cell or Ghost._grid.get_valid_cell()
	self._home.x = home_cell.x
	self._home.y = home_cell.y

	GridActor.reset(self, self._home, speed, tilesize)

	self._n_catches = 0
	self._fitness = 0

	self.target_offset = target_offset

	-- self.try_order = {}
	local try_order = {}
	for i=1, 4, 1 do
		try_order[i] = i
	end
	qpd.array.shuffle(try_order)
	self._try_order[1] = try_order[1]
	self._try_order[2] = try_order[2]
	self._try_order[3] = try_order[3]
	self._try_order[4] = try_order[4]

	-- set a valid direction
	self:set_random_valid_direction()

	self.front = Ghost._grid:get_dynamic_front(self)
end

function Ghost:crossover(ghosts, spawn_grid_pos)
	local mom = {}
	local dad = {}
	mom, dad = Ghost.selection(ghosts)

	local son = {}

	local this_spawn_grid_pos = {}
	local this_direction
	if spawn_grid_pos then
		this_spawn_grid_pos = spawn_grid_pos
		this_direction = qpd.random.choose("up", "down", "left", "right")
	else -- nasce com a mae
		this_spawn_grid_pos.x = mom.grid_pos.x
		this_spawn_grid_pos.y = mom.grid_pos.y
		this_direction = mom._direction
	end

	son.pos_index = math.floor((mom.pos_index + dad.pos_index)/2)
	if (qpd.random.random(0, 10) <= 9) then -- mutate
		son.pos_index = son.pos_index + math.floor(qpd.random.random(-50, 50))
		if (son.pos_index < 1) then
			son.pos_index = 1
		elseif (son.pos_index > #Ghost._grid.valid_pos) then
			son.pos_index = #Ghost._grid.valid_pos
		end
	end
	--print(son.pos_index)

	son.target_offset = math.floor((mom.target_offset + dad.target_offset)/2)

	if (qpd.random.random(0, 10)<=3) then -- mutate
		son.target_offset = son.target_offset +
							math.floor(qpd.random.random(-2, 2))
	end

	son.target_offset = qpd.random.random(math.floor(-Ghost._target_spread), math.ceil(Ghost._target_spread))

	son.try_order = {} -- we should add mutation

	local this_rand = qpd.random.random(0, 10)
	if (this_rand <= 3) then
		--print("mom")
		for i = 1, #mom.try_order, 1 do
			--print(mom.try_order[i])
			son.try_order[i] = mom.try_order[i]
			--print(son.try_order[i])
		end
	elseif (this_rand <= 5) then
		--print("dad")
		for i = 1, #dad.try_order, 1 do
			--print(dad.try_order[i])
			son.try_order[i] = dad.try_order[i]
			--print(son.try_order[i])
		end
	else
		for i = 1, 4, 1 do
			son.try_order[i] = i
		end
		qpd.array.shuffle(son.try_order)
	end

	self:reset( nil,
				son.target_offset,
				Ghost._speed)
end

function Ghost:is_type(type_name)
	if type_name == ghost_type_name then
		return true
	else
		return false
	end
end

function Ghost.selection(in_table)
	local mom = {}
	local dad = {}

	local best_stack = qpd.table.get_n_best(in_table, "_fitness", math.floor(#in_table/10))
	mom = best_stack[qpd.random.random(1, #best_stack)]
	dad = in_table[qpd.random.random(1, #in_table)]

	return mom, dad
end

function Ghost:draw(state)
	if self._is_active then
		if(self.target_offset <= 0)then
			if (self.target_offset == -1) then
				love.graphics.setColor( 0.2, 0.5, 0.8)
			elseif (self.target_offset == -2) then
				love.graphics.setColor( 0.4, 0.5, 0.6)
			elseif (self.target_offset == -3) then
				love.graphics.setColor( 0.6, 0.5, 0.4)
			elseif (self.target_offset == -4) then
				love.graphics.setColor( 0.8, 0.5, 0.2)
			else--if (self.target_offset < -4) then
				love.graphics.setColor( 1, 0.5, 0)
			end
		else
			if (self.target_offset == 1) then
				love.graphics.setColor( 0.5, 0.2, 0.8)
			elseif (self.target_offset == 2) then
				love.graphics.setColor( 0.5, 0.4, 0.6)
			elseif (self.target_offset == 3) then
				love.graphics.setColor( 0.5, 0.6, 0.4)
			elseif (self.target_offset == 4) then
				love.graphics.setColor( 0.5, 0.8, 0.2)
			else--if (self.target_offset > 4) then
				love.graphics.setColor( 0.5, 1, 0)
			end
		end

		--love.graphics.setColor( (1/self.target_offset) + 0.3, 0.5, 0.3)
		love.graphics.circle("fill", self.x, self.y, Ghost._grid_size*0.5)

		-- assign  colors based on pos_index
		if (self.pos_index < #Ghost._grid.valid_pos/4 )then
			love.graphics.setColor(1, 1, 1)
		elseif (self.pos_index < (#Ghost._grid.valid_pos/4)*2 )then
			love.graphics.setColor(0.75, 0, 0.75)
		elseif (self.pos_index < (#Ghost._grid.valid_pos/4)*3 )then
			love.graphics.setColor(0, 0.5, 0.5)
		else
			love.graphics.setColor(0.05, 0.05, 0.05)
		end

		--love.graphics.circle("fill", self.x , self.y, grid_size*0.3)
		local midle = qpd.point.midle_point2(self, self.front)
		local midle_midle = qpd.point.midle_point2(self, midle)
		local midle_midle_midle = qpd.point.midle_point2(self, midle_midle)
		love.graphics.circle(	"fill",
								midle_midle_midle.x,
								midle_midle_midle.y,
								Ghost._grid_size/4)
		--love.graphics.circle("fill", self.x, self.y, grid_size/6)
	end
end

function Ghost:collided(other)
	if other:is_type("player") then
		if (Ghost.state ~= "frightened") then
			--print("you loose, my target is: " .. self.target_offset)
			-- Ghost.reporter.report_catched(self.target_offset)

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

function Ghost:update(targets, pills, average_ghost_pos, dt)
	if (self._is_active) then
		Ghost._grid:update_position(self)

		self._fitness = self._n_catches

		-- updates average distance to player and group,
		-- it is used for collision
		local target = targets[1]
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

		if target_distance < Ghost._grid_size then
			self:collided(target)
		end

		self.front = Ghost._grid:get_dynamic_front(self)

		local this_grid_pos = Ghost._grid:get_grid_pos_absolute(self)

		-- check collision with wall
		local front_grid_pos = Ghost._grid:get_grid_pos_absolute(self.front)
		if(Ghost._grid:is_grid_wall(front_grid_pos)) then
			self._direction = "idle"
			self._next_direction = "idle"
			Ghost._grid:center_on_grid(self)
		end

		--on change tile
		if ((this_grid_pos.x ~= self.grid_pos.x) or
			(this_grid_pos.y ~= self.grid_pos.y)) then

			self.last_grid_pos = self.grid_pos
			self.grid_pos = this_grid_pos
		end

		--on tile center, or close
		local dist_grid_center = qpd.point.distance2( Ghost._grid:get_grid_center(self.grid_pos), self)
		if (dist_grid_center < Ghost._lookahead/8) then
			if ( self._direction == "up" or self._direction== "down") then
				Ghost._grid:center_on_grid_x(self)
			elseif ( self._direction == "left" or self._direction== "right") then
				Ghost._grid:center_on_grid_y(self)
			end
			self:find_next_dir(target, average_ghost_pos)
		end

		local this_speed = self.speed
		if self._direction ~= "idle" then
			--print("X: ", self.x, "Y:", self.y)
			if self._direction == "up" then self.y = self.y - dt*this_speed
			elseif self._direction == "down" then self.y = self.y +dt*this_speed
			elseif self._direction == "left" then self.x = self.x -dt*this_speed
			elseif self._direction == "right" then self.x = self.x +dt*this_speed
			end
		end

	end
end

function Ghost:find_next_dir(target, average_ghost_pos)
	self.enabled_directions = Ghost._grid:get_enabled_directions(self.grid_pos)
	if (#self.enabled_directions < 1) then
		print("enabled_directions cant be empty")
	end

	--count = grid.count_enabled_directions(self.grid_pos)
	if 	(Ghost._grid.grid_types[self.grid_pos.y][self.grid_pos.x]~=3 and-- invertido
		Ghost._grid.grid_types[self.grid_pos.y][self.grid_pos.x]~=12 ) then
		--check which one is closer to the target
		-- make a table to contain the posible destinations
		local possible_next_moves = {}
		for i = 1, #self.try_order, 1 do
			if (self.enabled_directions[self.try_order[i]] == true) then
				local grid_pos = {}
				if(self.try_order[i] == 1) then
					grid_pos.x = self.grid_pos.x
					grid_pos.y = self.grid_pos.y - 1
					grid_pos._direction = "up"
				elseif(self.try_order[i] == 2) then
					grid_pos.x = self.grid_pos.x
					grid_pos.y = self.grid_pos.y + 1
					grid_pos._direction = "down"
				elseif(self.try_order[i] == 3) then
					grid_pos.x = self.grid_pos.x - 1
					grid_pos.y = self.grid_pos.y
					grid_pos._direction = "left"
				elseif(self.try_order[i] == 4) then
					grid_pos.x = self.grid_pos.x +1
					grid_pos.y = self.grid_pos.y
					grid_pos._direction = "right"
				end

				table.insert(possible_next_moves, grid_pos)
			end
		end

		if (#possible_next_moves == 0) then
			print("possible_next_moves cant be empty")
			for j = 1, #self.try_order, 1 do
				print(self.try_order[j])
			end
		end

		if (target._is_active) then
			if ( Ghost.state == "chasing" ) then
				self:go_to_target(target, possible_next_moves)
			elseif ( Ghost.state == "scattering") then
				if(Ghost.ghost_go_home_on_scatter) then
					self:go_home(possible_next_moves)
				else
					self:wander(possible_next_moves)
				end
			elseif ( Ghost.state == "frightened") then
				self:wander(possible_next_moves)
				-- ghost.run_from_target(self, target, possible_next_moves)
				-- ghost.go_home(self, possible_next_moves)
				-- ghost.go_to_closest_pill(self, possible_next_moves)
			else
				print("error, invalid ghost_state")
			end
		else
			self:wander(possible_next_moves)
		end
	end
end

---------------------------------------------------------------

function Ghost:catch_target(target, possible_next_moves)
	local destination = {}

	destination.x = target.grid_pos.x
	destination.y = target.grid_pos.y

	self:get_closest(possible_next_moves, destination)
end

function Ghost:go_to_target(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target.grid_pos.x
		destination.y = -self.target_offset + target.grid_pos.y
	elseif (target._direction == "down") then
		destination.x = target.grid_pos.x
		destination.y = self.target_offset + target.grid_pos.y
	elseif (target._direction == "left") then
		destination.x = -self.target_offset + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "right") then
		destination.x = self.target_offset + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "idle") then
		destination.x = target.grid_pos.x
		destination.y = target.grid_pos.y
	end

	self:get_closest(possible_next_moves, destination)
end

function Ghost:surround_target_front(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target.grid_pos.x
		destination.y = -4 + target.grid_pos.y
	elseif (target._direction == "down") then
		destination.x = target.grid_pos.x
		destination.y = 4 + target.grid_pos.y
	elseif (target._direction == "left") then
		destination.x = -4 + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "right") then
		destination.x = 4 + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "idle") then
		destination.x = target.grid_pos.x
		destination.y = target.grid_pos.y
	end

	self:get_closest(possible_next_moves, destination)
end

function Ghost:surround_target_back(target, possible_next_moves)
	local destination = {}

	if (target._direction == "up") then
		destination.x =  target.grid_pos.x
		destination.y = 4 + target.grid_pos.y
	elseif (target._direction == "down") then
		destination.x = target.grid_pos.x
		destination.y = -4 + target.grid_pos.y
	elseif (target._direction == "left") then
		destination.x = 4 + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "right") then
		destination.x = -4 + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "idle") then
		destination.x = target.grid_pos.x
		destination.y = target.grid_pos.y
	end

	self:get_closest(possible_next_moves, destination)
end

function Ghost:wander(possible_next_moves)
	local destination = {}
	local rand_grid = qpd.random.random(1, #Ghost._grid.valid_pos )
	local this_grid_pos = Ghost._grid.valid_pos[rand_grid]

	destination.x = this_grid_pos.x
	destination.y = this_grid_pos.y

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
		destination.x =  target.grid_pos.x
		destination.y = -self.target_offset + target.grid_pos.y
	elseif (target._direction == "down") then
		destination.x = target.grid_pos.x
		destination.y = self.target_offset + target.grid_pos.y
	elseif (target._direction == "left") then
		destination.x = -self.target_offset + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "right") then
		destination.x = self.target_offset + target.grid_pos.x
		destination.y = target.grid_pos.y
	elseif (target._direction == "idle") then
		destination.x = target.grid_pos.x
		destination.y = target.grid_pos.y
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
	local shortest_distance = qpd.point.distance2(possible_next_moves[1], destination)
	for i = 2, #possible_next_moves, 1 do
		local dist = qpd.point.distance2(possible_next_moves[i], destination)
		if (dist < shortest_distance) then
			shortest = i
			shortest_distance = dist
		end
	end
	self._direction = possible_next_moves[shortest]._direction
end

function Ghost:get_furthest(possible_next_moves, destination)
	local furthest = 1
	for i=1, #possible_next_moves, 1 do
		possible_next_moves[i].dist = qpd.point.distance2(possible_next_moves[i], destination)
		if ( possible_next_moves[i].dist > possible_next_moves[furthest].dist ) then
			furthest = i
		end
	end
	--print("furthest" .. furthest)
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
