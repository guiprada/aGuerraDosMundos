local Collectable = {}

local utils = require "qpd.utils"
local timer = require "qpd.timer"

function Collectable.new(cell, sprite, size, tilesize, bonus_type, bonus_quant, reactivation_time)
    local o = {}

    o.x, o.y = utils.grid_to_center_point(cell.x, cell.y, tilesize)

    o._size = size
    o._scale = size/ sprite:getWidth()    
    o._offset = (o._size/2) * (1/o._scale)
    o._cell = {}
    o._cell.x, o._cell.y = cell.x, cell.y
    o._is_enabled = true

    o._sprite = sprite    
    o._reactivate = false

    if reactivation_time ~= nil then
        o._reactivate = true    
        local function reactivate()
            o._is_enabled = true
        end
        o._timer = timer.new(reactivation_time, reactivate)
    end

    utils.assign_methods(o, Collectable)

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

return Collectable