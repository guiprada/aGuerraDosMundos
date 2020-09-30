local grid_selector = {}

local utils = require "qpd.utils"

function grid_selector.new(
    offset_x,
    offset_y,
    min_grid_x,
    min_grid_y,
    max_grid_x,
    max_grid_y,
    tilesize,
    color,
    grid_start_x,
    grid_start_y)

    local o = {}

    o.offset_x = offset_x
    o.offset_y = offset_y
    o.min_grid_x = min_grid_x
    o.min_grid_y = min_grid_y
    o.max_grid_x = max_grid_x
    o.max_grid_y = max_grid_y

    o.grid_x = grid_start_x or math.floor((min_grid_x + max_grid_x)/2)
    o.grid_y = grid_start_y or math.floor((min_grid_y + max_grid_y)/2)

    o.tilesize = tilesize
    o.color = color or {1, 0, 0}

    utils.assign_methods(o, grid_selector)

    return o
end

--------------------------------------------------------------------------------

function grid_selector.draw(self)
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(unpack(self.color))
    
    love.graphics.rectangle(
        "line",
        self.offset_x + (self.grid_x - 1) * self.tilesize,
        self.offset_y + (self.grid_y - 1) * self.tilesize,
        self.tilesize,
        self.tilesize)

    love.graphics.setColor(r, g, b, a)
end

function grid_selector.up(self)
    self.grid_y = utils.clamp(
        self.grid_y - 1,
        self.min_grid_y, self.max_grid_y)
end

function grid_selector.down(self)
    self.grid_y = utils.clamp(
        self.grid_y + 1,
        self.min_grid_y, self.max_grid_y)
end

function grid_selector.right(self)
    self.grid_x = utils.clamp(
        self.grid_x + 1,
        self.min_grid_x, self.max_grid_x)
end

function grid_selector.left(self)
    self.grid_x = utils.clamp(
        self.grid_x - 1,
        self.min_grid_x, self.max_grid_x)
end

function grid_selector.add_line(self)
    self.max_grid_y = self.max_grid_y + 1
end

function grid_selector.add_row(self)
    self.max_grid_x = self.max_grid_x + 1
end

return grid_selector