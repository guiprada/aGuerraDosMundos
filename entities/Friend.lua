local Friend = {}

local qpd = require "qpd.qpd"

function Friend._move(self, dt, tilesize)
	local px, py = qpd.grid.cell_to_center_point(self._target_cell.x, self._target_cell.y, tilesize)
	local maybe_x, maybe_y, has_reached = qpd.point.lerp(self.x, self.y, px, py, self.speed_factor * tilesize * dt)

	self._cell.x, self._cell.y = qpd.grid.point_to_cell(self.x, self.y, tilesize)
	if self.grid:is_blocked_point(maybe_x, maybe_y, tilesize) then
		self._is_active = false
	else
		self.x, self.y = maybe_x, maybe_y
	end

	if has_reached then
		self._target_cell.x, self._target_cell.y = self.follow_target._cell.x, self.follow_target._cell.y
	end
end

function Friend.new(cell_x, cell_y, sprite, grid, size_factor, follow_target, tilesize, speed_factor, health_max)
	local o = {}
	o._is_active = false
	o._sprite = sprite
	o._size_factor = size_factor
	o._size = o._size_factor * tilesize
	o._scale = o._size/ o._sprite:getWidth()
	o._rot = -math.pi/2
	o._offset = (o._size/2) * (1/o._scale)
	o._cell = {}
	o._cell.x, o._cell.y = cell_x, cell_y
	o._target_cell = {}

	o.grid = grid

	o.follow_target = follow_target
	o.speed_factor = speed_factor
	o.x, o.y = grid.cell_to_center_point(cell_x, cell_y, tilesize)
	o.old_x, o.old_y = o.x, o.y
	o.health = health_max

	qpd.table.assign_methods(o, Friend)
	return o
	-- body
end

function Friend.update(self, dt, tilesize)
	if self._is_active then
		if qpd.point.distance2(self, self.follow_target) > 10* tilesize then
			self._is_active =  false
		end
		self.old_x, self.old_y = self.x, self.y
		self:_move(dt, tilesize)
		local delta_x, delta_y = self.x - self.old_x, self.y - self.old_y
		if (delta_x ~= 0) or (delta_y ~= 0) then
			self._rot = math.atan2(delta_y, delta_x)
		end
	elseif qpd.point.distance2(self, self.follow_target) < 3* tilesize then
		local angle = math.atan2(self.follow_target.y - self.y, self.follow_target.x - self.x)
		if self.grid:check_unobstructed(self, angle, 3*tilesize, tilesize, self.speed_factor * tilesize * dt) == true then
			self._is_active = true
			self._target_cell.x, self._target_cell.y = self.follow_target._cell.x, self.follow_target._cell.y
		end
	end
end

function Friend.draw(self, collision_enabled)
	--love.graphics.circle("fill", self.x, self.y, self._size/2)
	love.graphics.draw(self._sprite, self.x, self.y, self._rot, self._scale, self._scale, self._offset, self._offset)

	-- save color
	local r, g, b, a = love.graphics.getColor()
	-- health shadow
	local damage = self.health/100
	love.graphics.setColor(0, 0, 0, 1 - damage)
	love.graphics.circle("fill", self.x, self.y, (self._size/2)+0.5)

	if not collision_enabled then
		love.graphics.setColor(0,0,0, 0.6)
		love.graphics.circle("fill", self.x, self.y, (self._size/2)+0.5)
	end

	-- restore color
	love.graphics.setColor(r, g, b, a)
end

function Friend.take_health(self, h_much)
	self.health = self.health - h_much
end

function Friend.resize(self, tilesize)
	self.x, self.y = qpd.grid.cell_to_center_point(self._cell.x, self._cell.y, tilesize)
	self._size = self._size_factor * tilesize
	self._scale = self._size/ self._sprite:getWidth()
	self._offset = (self._size/2) * (1/self._scale)
end

return Friend