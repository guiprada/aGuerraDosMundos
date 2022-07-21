-- Guilherme Cunha Prada 2020
local GridActor = {}
GridActor.__index = GridActor

local qpd = require "qpd.qpd"

local registered_types_list = {
	"generic",
}

local registered_types = {
	[registered_types_list[1]] = 1,
}

function GridActor.init(grid)
	GridActor.grid = grid
end

function GridActor.get_type_by_name(type_name)
	local type = registered_types[type_name]
	if type then
		return type
	else
		print("[ERROR] - GridActor.get_type() - unkwnown type:", type_name)
		return nil
	end
end

function GridActor.register_type(type_name)
	if not registered_types[type_name] then
		table.insert(registered_types_list, type_name)
		registered_types[type_name] = #registered_types_list
	end
end

function GridActor:new(o)
	local o = o or {}
	setmetatable(o, self)

	o._cell = {}
	o.enabled_directions = {}
	o.front = {}
	o.last_cell = {}

	o._is_active = false
	o.changed_tile = false
	o._has_collided = false
	o.speed = 0
	o.direction = "idle"
	o.next_direction = "idle"

	o._cell.x = 0
	o._cell.y = 0

	o.x = 0
	o.y = 0

	-- we set it negative so it enters the first on tile change
	o.last_cell.x = -1
	o.last_cell.y = -1

	o.front.x = 0
	o.front.y = 0

	o.relay_x_counter = 0
	o.relay_y_counter = 0
	o.relay_x = 0
	o.relay_y = 0
	o.relay_times = 3 -- controls how many gameloops it takes to relay

	o._type = GridActor.get_type_by_name("generic")

	return o
end

function GridActor:reset(cell, speed, tilesize)
	self.changed_tile = false
	self.changed_tile_x = false
	self.changed_tile_y = false
	self._has_collided = false
	self.speed = speed or 0
	self._tilesize = tilesize
	self.direction = "idle"
	self.next_direction = "idle"

	self._cell.x = cell.x
	self._cell.y = cell.y

	self.x, self.y = GridActor.grid.cell_to_center_point(self._cell.x, self._cell.y, tilesize)

	-- we set it negative so it enters the first on tile change
	self.last_cell.x = -1
	self.last_cell.y = -1

	self.relay_x_counter = 0
	self.relay_y_counter = 0
	self.relay_x = 0
	self.relay_y = 0
	self.relay_times = 3 -- controls how many gameloops it takes to relay

	self.front.x = self.x
	self.front.y = self.y

	self._is_active = true
end

function GridActor:is_type(type_name)
	if type_name == registered_types_list[self._type] then
		return true
	else
		return false
	end
end

function GridActor:draw(tilesize)
	if (self._is_active) then
		love.graphics.setColor(1, 1, 0)
		love.graphics.circle(	"fill",
								self.x,
								self.y,
								tilesize*0.55)
	end
end

function GridActor:update(dt, tilesize)
	--speed*dt, which is the distance travelled cant be bigger than the tile
	--grid_size*1.5 or the physics wont work
	if self.speed*dt > (tilesize/2) then
		print("physics sanity check failed, Actor traveled distance > tilesize")
	end

	if tilesize ~= self._tilesize then
		self._tilesize = tilesize
		-- here we just center on grid, we should perhaps do a scaling
		self:center_on_cell()
	end

	-- print(self.speed)
	if (self._is_active) then
		self.changed_tile = false
		if self.direction ~= "idle" then
			if self.direction == "up" then self.y = self.y - self.speed * dt
			elseif self.direction == "down" then self.y = self.y + self.speed * dt
			elseif self.direction == "left" then self.x = self.x - self.speed * dt
			elseif self.direction == "right" then self.x = self.x + self.speed * dt
			end
		end

		-- update o info
		self:update_dynamic_front()
		self:update_cell()

		--on change tile
		if  self._cell.x ~= self.last_cell.x or
			self._cell.y ~= self.last_cell.y then

			self.changed_tile = true
			self.enabled_directions = self:get_enabled_directions()
			self.last_cell.x = self._cell.x
			self.last_cell.y = self._cell.y
		end

		-- apply next_direction
		if self.next_direction ~= "idle" then
			local cell_center_x, cell_center_y = GridActor.grid.cell_to_center_point(self._cell.x, self._cell.y, tilesize)

			if  self.next_direction == "up" and
				self.enabled_directions[1] == true then

				self.direction = self.next_direction
				self.relay_x = self.x - cell_center_x
				self.relay_x_counter = self.relay_times
			elseif  self.next_direction == "down" and
					self.enabled_directions[2] == true then

				self.direction = self.next_direction
				self.relay_x = self.x - cell_center_x
				self.relay_x_counter = self.relay_times
			elseif  self.next_direction == "left" and
					self.enabled_directions[3] == true then

				self.direction = self.next_direction
				self.relay_y = self.y - cell_center_y
				self.relay_y_counter = self.relay_times
			elseif  self.next_direction == "right" and
					self.enabled_directions[4] == true then

				self.direction = self.next_direction
				self.relay_y = self.y - cell_center_y
				self.relay_y_counter = self.relay_times
			end
		end

		-- check collision with wall
		self._has_collided = false
		if(self:is_front_wall()) then
			self.direction = "idle"
			self.next_direction = "idle"
			self:center_on_cell()
			self._has_collided = true
		end

		-- relays mov for cornering
		if self.relay_x_counter >= 1 then
			self.x = self.x - self.relay_x/self.relay_times
			self.relay_x_counter = self.relay_x_counter -1
			if self.relay_x_counter == 0 then self:center_on_cell_x() end
		end

		if self.relay_y_counter >= 1 then
			self.y = self.y - self.relay_y/self.relay_times
			self.relay_y_counter = self.relay_y_counter -1
			if self.relay_y_counter == 0 then self:center_on_cell_y() end
		end

		GridActor.grid:update_collision(self)
	end
end

function GridActor:set_random_valid_direction()
	local enable_directions = GridActor.grid:get_enabled_directions(self._cell.x, self._cell.y)
	local direction_select_list = {}

	if enable_directions[1] == true then
		table.insert(direction_select_list, 1)
	end
	if enable_directions[2] == true then
		table.insert(direction_select_list, 2)
	end
	if enable_directions[3] == true then
		table.insert(direction_select_list, 3)
	end
	if enable_directions[4] == true then
		table.insert(direction_select_list, 4)
	end

	local selected_direction = qpd.random.choose_list(direction_select_list)
	self.direction = GridActor.grid.directions[selected_direction]
end

function GridActor:center_on_cell()
	self.x, self.y = GridActor.grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)
end

function GridActor:center_on_cell_x()
	self.x, _ = GridActor.grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)
end

function GridActor:center_on_cell_y()
	_, self.y = GridActor.grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)
end

function GridActor:update_dynamic_front()
	-- returns the point that is lookahead in front of the player
	-- it does consider the direction obj is set
	local point = {}
	-- the player has a dynamic center
	if self.direction == "up" then
		point.y = self.y - (self._tilesize/2)
 		point.x = self.x
	elseif self.direction == "down" then
		point.y = self.y + (self._tilesize/2)
		point.x = self.x
	elseif self.direction == "left" then
		point.x = self.x - (self._tilesize/2)
		point.y = self.y
	elseif self.direction == "right" then
		point.x = self.x + (self._tilesize/2)
		point.y = self.y
	else -- "idle"
		point.y = self.y
		point.x = self.x
	end

	self.front = point
end

function GridActor:update_cell()
	self._cell.x, self._cell.y = GridActor.grid.point_to_cell(self.x, self.y, self._tilesize)
end

function GridActor:get_cell_in_front()
	return GridActor.grid.point_to_cell(self.front.x, self.front.y, self._tilesize)
end

function GridActor:get_enabled_directions()
	return GridActor.grid:get_enabled_directions(self._cell.x, self._cell.y)
end

function GridActor:is_front_wall()
	local cell_x, cell_y = self:get_cell_in_front()
	return not GridActor.grid:is_valid_cell(cell_x, cell_y)
end

return GridActor
