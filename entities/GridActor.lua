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

function GridActor.init(grid, tilesize, event_logger)
	GridActor._grid = grid
	GridActor._tilesize = tilesize
	GridActor._event_logger = event_logger
	GridActor._current_actor_id = 0
end

function GridActor.set_tilesize(tilesize)
	GridActor._tilesize = tilesize
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
	o._enabled_directions = {}
	o._front = {}
	o._last_cell = {}

	o._is_active = false
	o._changed_tile = false
	o._has_collided = false
	o._direction = "idle"
	o._next_direction = "idle"

	o._cell.x = 0
	o._cell.y = 0

	o.x = 0
	o.y = 0

	-- we set it negative so it enters the first on tile change
	o._last_cell.x = -1
	o._last_cell.y = -1

	o._front.x = 0
	o._front.y = 0

	o._relay_x_counter = 0
	o._relay_y_counter = 0
	o._relay_x = 0
	o._relay_y = 0
	o._relay_loop_counter = 3 -- controls how many gameloops it takes to relay

	o._type = GridActor.get_type_by_name("generic")

	return o
end

function GridActor:reset(cell)
	GridActor._current_actor_id = GridActor._current_actor_id + 1
	self._id = GridActor._current_actor_id

	self:log("created")

	self._changed_tile = false
	self._has_collided = false
	self._direction = "idle"
	self._next_direction = "idle"

	self._cell.x = cell.x
	self._cell.y = cell.y

	self._tilesize = GridActor._tilesize
	self.x, self.y = GridActor._grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)

	-- we set it negative so it enters the first on tile change
	self._last_cell.x = -1
	self._last_cell.y = -1

	self._relay_x_counter = 0
	self._relay_y_counter = 0
	self._relay_x = 0
	self._relay_y = 0
	self._relay_loop_counter = 3 -- controls how many gameloops it takes to relay

	self._front.x = self.x
	self._front.y = self.y

	self._is_active = true
end

function GridActor:is_type(type_name)
	if type_name == registered_types_list[self._type] then
		return true
	else
		return false
	end
end

function GridActor:draw()
	if (self._is_active) then
		love.graphics.setColor(1, 1, 0)
		love.graphics.circle("fill", self.x, self.y, self._tilesize*0.55)
	end
end

function GridActor:update(dt, speed)
	--speed*dt, which is the distance travelled cant be bigger than the tile
	--grid_size*1.5 or the physics wont work
	if speed*dt > (GridActor._tilesize/2) then
		print("physics sanity check failed, Actor traveled distance > tilesize")
	end

	if GridActor._tilesize ~= self._tilesize then
		self._tilesize = GridActor._tilesize
		-- here we just center on grid, we should perhaps do a scaling
		self:center_on_cell()
	end

	-- print(speed)
	if (self._is_active) then
		-- apply next_direction
		if self._next_direction ~= "idle" then
			local cell_center_x, cell_center_y = GridActor._grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)

			if  self._next_direction == "up" and self._enabled_directions[1] == true then
				self._direction = self._next_direction
				self._relay_x = self.x - cell_center_x
				self._relay_x_counter = self._relay_loop_counter
			elseif  self._next_direction == "down" and self._enabled_directions[2] == true then
				self._direction = self._next_direction
				self._relay_x = self.x - cell_center_x
				self._relay_x_counter = self._relay_loop_counter
			elseif  self._next_direction == "left" and self._enabled_directions[3] == true then
				self._direction = self._next_direction
				self._relay_y = self.y - cell_center_y
				self._relay_y_counter = self._relay_loop_counter
			elseif  self._next_direction == "right" and self._enabled_directions[4] == true then
				self._direction = self._next_direction
				self._relay_y = self.y - cell_center_y
				self._relay_y_counter = self._relay_loop_counter
			end
		end

		-- check collision with wall
		self._has_collided = false
		if(self:is_front_wall()) then
			self._direction = "idle"
			self._next_direction = "idle"
			self:center_on_cell() -- it stops relayed cornering
			self._has_collided = true
		end

		-- do move :)
		if self._direction ~= "idle" then
			if self._direction == "up" then self.y = self.y - speed * dt
			elseif self._direction == "down" then self.y = self.y + speed * dt
			elseif self._direction == "left" then self.x = self.x - speed * dt
			elseif self._direction == "right" then self.x = self.x + speed * dt
			end
		end

		-- update o info
		self:update_dynamic_front()
		self:update_cell()

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
			self._enabled_directions = self:get_enabled_directions()
			self._last_cell.x = self._cell.x
			self._last_cell.y = self._cell.y
		end

		-- relays mov for cornering
		if self._relay_x_counter >= 1 then
			self.x = self.x - self._relay_x/self._relay_loop_counter
			self._relay_x_counter = self._relay_x_counter -1
			if self._relay_x_counter == 0 then self:center_on_cell_x() end
		end

		if self._relay_y_counter >= 1 then
			self.y = self.y - self._relay_y/self._relay_loop_counter
			self._relay_y_counter = self._relay_y_counter -1
			if self._relay_y_counter == 0 then self:center_on_cell_y() end
		end

		GridActor._grid:update_collision(self)
	end
end

function GridActor:set_random_valid_direction()
	local enable_directions = self:get_enabled_directions()
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

	if #direction_select_list > 0 then
		local selected_direction = qpd.random.choose_list(direction_select_list)
		self._direction = GridActor._grid.directions[selected_direction]
	else
		print("Set random valid direction for invalid position:", self._cell.x, self._cell.y)
	end
end

function GridActor:center_on_cell()
	self.x, self.y = GridActor._grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)
end

function GridActor:center_on_cell_x()
	self._relay_x_counter = 0
	self._relay_y_counter = 0
	self.x, _ = GridActor._grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)
end

function GridActor:center_on_cell_y()
	_, self.y = GridActor._grid.cell_to_center_point(self._cell.x, self._cell.y, self._tilesize)
end

function GridActor:update_dynamic_front()
	-- returns the point that is lookahead in front of the player
	-- it does consider the direction obj is set
	local point = {}
	-- the player has a dynamic center
	if self._direction == "up" then
		point.y = self.y - (self._tilesize/2)
 		point.x = self.x
	elseif self._direction == "down" then
		point.y = self.y + (self._tilesize/2)
		point.x = self.x
	elseif self._direction == "left" then
		point.x = self.x - (self._tilesize/2)
		point.y = self.y
	elseif self._direction == "right" then
		point.x = self.x + (self._tilesize/2)
		point.y = self.y
	else -- "idle"
		point.y = self.y
		point.x = self.x
	end

	self._front = point
end

function GridActor:update_cell()
	self._cell.x, self._cell.y = GridActor._grid.point_to_cell(self.x, self.y, self._tilesize)
end

function GridActor:get_cell_in_front()
	return GridActor._grid.point_to_cell(self._front.x, self._front.y, self._tilesize)
end

function GridActor:get_enabled_directions()
	return GridActor._grid:get_enabled_directions(self._cell.x, self._cell.y)
end

function GridActor:is_front_wall()
	local cell_x, cell_y = self:get_cell_in_front()
	return GridActor._grid:is_blocked_cell(cell_x, cell_y)
end

function GridActor:log(event_type)
	local event_table = {}
	-- {"timestamp", "actor_id", "actor_type", "event_type", "cell_x", "cell_y"}
	event_table["timestamp"] = os.time()
	event_table["actor_id"] = self._id
	event_table["actor_type"] = registered_types_list[self._type]
	event_table["event_type"] = event_type
	event_table["cell_x"] = self._cell.x
	event_table["cell_y"] = self._cell.y

	GridActor._event_logger:log(event_table)
end

return GridActor
