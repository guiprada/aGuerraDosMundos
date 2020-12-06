local fps = {}
local utils = require "qpd.utils"

function fps.draw(self)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(unpack(self.color))
    love.graphics.print(
        love.timer.getFPS(),
        self.x,
        self.y)
    love.graphics.setColor(r, g, b, a)
end

--------------------------------------------------------------------------------

function fps.new(x, y, color)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    o.color = color or {0, 1, 1}

    -- methods
    utils.assign_methods(o, fps)

    return o
end

return fps
