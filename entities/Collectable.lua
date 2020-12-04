local Collectable = {}

local utils = require "qpd.utils"

function Collectable.new(cell, sprite, size, tilesize, bonus_type, bonus_quant)
    local o = {}
    o._size = size
    o._scale = size/ sprite:getWidth()    
    o._offset = (o._size/2) * (1/o._scale)
    o._cell = {}
    o._cell.x, o._cell.y = cell.x, cell.y
    o.is_enabled = true

    o._sprite = sprite    
    o.x, o.y = utils.grid_to_center_point(cell.x, cell.y, tilesize)

    utils.assign_methods(o, Collectable)

    return o
end

function Collectable.draw(self)
    if self.is_enabled then
        love.graphics.draw(self._sprite, self.x, self.y, self._rot, self._scale, self._scale, self._offset, self._offset)
    end
end

return Collectable