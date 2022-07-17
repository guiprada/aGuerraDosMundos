local Collectable = {}

local qpd = require "qpd.qpd"

function Collectable.new(cell, sprite, size_factor, tilesize, bonus_type, bonus_quant, reactivation_time)
	local o = {}

	o.x, o.y = qpd.grid.cell_to_center_point(cell.x, cell.y, tilesize)
	o.cell = qpd.table.clone(cell)

	o._sprite = sprite
	o._size_factor = size_factor
	o._size = o._size_factor*tilesize
	o._scale = o._size/ o._sprite:getWidth()
	o._offset = (o._size/2) * (1/o._scale)
	o._cell = {}
	o._cell.x, o._cell.y = cell.x, cell.y
	o._is_enabled = true

	o._reactivate = false

	if reactivation_time ~= nil then
		o._reactivate = true
		local function reactivate()
			o._is_enabled = true
		end
		o._timer = qpd.timer.new(reactivation_time, reactivate)
	end

	qpd.table.assign_methods(o, Collectable)

	return o
end

function Collectable.update(self, dt)
	if self._reactivate then
		self._timer:update(dt)
	end
end

function Collectable.draw(self)
	if self._is_enabled then
		love.graphics.draw(self._sprite, self.x, self.y, self._rot, self._scale, self._scale, self._offset, self._offset)
	end
end

function Collectable.disable(self)
	self._is_enabled = false
	if self._reactivate then
		self._timer:reset()
	end
end

function Collectable.is_enabled(self)
	return self._is_enabled
end

function Collectable.resize(self, tilesize)
	self.x, self.y = qpd.grid.cell_to_center_point(self.cell.x, self.cell.y, tilesize)
	self._size = self._size_factor*tilesize
	self._scale = self._size/ self._sprite:getWidth()
	self._offset = (self._size/2) * (1/self._scale)
end

return Collectable