local Tripod = {}
local utils = require "qpd.utils"

function Tripod.new(x, y, sprite, size)
    local o = {}
    o.x = x
    o.y = y
    o.sprite = sprite
    o.size = size or 1
    o.scale = size/ sprite:getWidth()
    o.rot = 0
    o.offset = -size/2

    utils.assign_methods(o, Tripod)
    return o
end

function Tripod.update(self, dt)
end

function Tripod.draw(self)
    love.graphics.draw(self.sprite, self.x, self.y, self.rot, self.scale, self.scale, self.offset, self.offset)
end

return Tripod