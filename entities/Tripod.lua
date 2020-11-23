local Tripod = {}
local utils = require "qpd.utils"

function Tripod._get_next_grid(self, tilesize)
    local allowed = {}
    -- get allowed grids to go
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            print(self._grid_cell.x - i, self._grid_cell.y - j)
            if not self.grid:is_colliding_grid(self._grid_cell.x - i, self._grid_cell.y - j, tilesize) then
                local new_value = {x = self._grid_cell.x - i, y = self._grid_cell.y - j}
                table.insert(allowed, new_value)
            end
        end
    end

    -- see which one gets it closer to target
    if #allowed > 1 then
        print(allowed[1].x, allowed[1].y)
        local min_dist = utils.distance(allowed[1], self._target)
        local next_grid = allowed[1]
        for i=2, #allowed, 1 do
            local dist = utils.distance(allowed[i], self._target)
            if dist < min_dist then
                min_dist = dist
                next_grid = allowed[i]
            end
        end
        self._next_grid.x, self._next_grid.y = next_grid.x, next_grid.y
    else
        print("error: Tripod has nowhere to go!")
    end
end

function Tripod.new(x, y, sprite, grid, size, tilesize, target, speed)
    local o = {}
    o.x = x
    o.y = y
    o.sprite = sprite
    o.size = size or 1
    o.scale = size/ sprite:getWidth()
    o.rot = 0
    o.offset = -size/2
    o.grid = grid
    
    o._start = {}
    o._start.x, o._start.y = utils.point_to_grid(o.x, o.y, tilesize)
    o._target = target
    o._grid_cell = {}
    o._grid_cell.x, o._grid_cell.y = o._start.x, o._start.y

    o.speed = speed
    
    utils.assign_methods(o, Tripod)

    o._next_grid = {}
    o:_get_next_grid(tilesize)

    return o
end

function Tripod.update(self, dt, player, tilesize)
    self._grid_cell.x, self._grid_cell.y = utils.point_to_grid(self.x, self.y, tilesize)
    if  self._grid_cell.x == self._target.x and
        self._grid_cell.y == self._target.y then
        self:_aquire_target(player, tilesize)
    end

    self:_move(dt, tilesize)
end

function Tripod.draw(self)
    love.graphics.draw(self.sprite, self.x, self.y, self.rot, self.scale, self.scale, self.offset, self.offset)
end

function Tripod._aquire_target(self, player, tilesize)
    self._target, self._start = self._start, self._target
end

function Tripod._move(self, dt, tilesize)
    if  self._grid_cell.x == self._next_grid.x and
        self._grid_cell.y == self._next_grid.y then
        self:_get_next_grid(tilesize)
    end
    local px, py = utils.grid_to_center_point(self._next_grid.x, self._next_grid.y, tilesize)
    self.x, self.y = utils.lerp(self, {x = px, y = py}, self.speed * dt)
end

return Tripod