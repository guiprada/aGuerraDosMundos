local Tripod = {}
local utils = require "qpd.utils"


function Tripod._update_rotation(self)
    local delta_x = self._next_cell.x - self._curr_cell.x
    local delta_y = self._next_cell.y - self._curr_cell.y

    self.rot = math.atan2(delta_y, delta_x)
end


function Tripod._get_next_cell(self, tilesize)
    local allowed = {}
    -- get allowed grids to go
    for i = -1, 1, 1 do
        for j = -1, 1, 1 do
            local grid_x, grid_y = self._curr_cell.x + i, self._curr_cell.y + j
            if (    grid_x >= 1 and
                    grid_x <= self.grid.width and
                    grid_y >= 1 and
                    grid_y <= self.grid.height ) then
                if not self.grid:is_colliding_grid(grid_x, grid_y, tilesize) then
                    local new_value = {x = grid_x, y = grid_y}
                    table.insert(allowed, new_value)
                end
            end
        end
    end
    
    -- see which one gets it closer to target
    if #allowed >= 2 then
        local min_dist = utils.distance(allowed[1], self._target)
        local next_grid = allowed[1]
        for i=2, #allowed, 1 do
            local dist = utils.distance(allowed[i], self._target)
            if dist < min_dist then
                min_dist = dist
                next_grid = allowed[i]
            end
        end
        self._last_cell.x, self._last_cell.y = self._curr_cell.x, self._curr_cell.y
        self._next_cell.x, self._next_cell.y = next_grid.x, next_grid.y
        if  self._last_cell.x == self._next_cell.x and
            self._last_cell.y == self._next_cell.y then
            self._is_stuck = true
        end

        if self._is_stuck then
            self._target = self.grid:get_valid_pos()
            self._is_stuck = false
        end
    else
        print("error: Tripod has nowhere to go!")
        self._next_cell.x, self._next_cell.y = self._curr_cell.x, self._curr_cell.y        
    end

    self:_update_rotation()
end

function Tripod.new(x, y, sprite, grid, size, tilesize, target, speed)
    local o = {}
    o.x = x
    o.y = y
    o.sprite = sprite
    o.size = size or 1
    o.scale = size/ sprite:getWidth()
    o.rot = 0
    o.offset = (o.size/2) * (1/o.scale)
    o.grid = grid
    
    o._start = {}
    o._start.x, o._start.y = utils.point_to_grid(o.x , o.y, tilesize)
    o._target = target
    o._curr_cell = {}
    o._curr_cell.x, o._curr_cell.y = o._start.x, o._start.y
    o._last_try = 1

    o.speed = speed
    
    utils.assign_methods(o, Tripod)
    o._last_cell = {}
    o._next_cell = {}
    o:_get_next_cell(tilesize)

    return o
end

function Tripod.update(self, dt, player, tilesize)
    self._curr_cell.x, self._curr_cell.y = utils.point_to_grid(self.x, self.y, tilesize)

    -- has reached the target?
    if  self._curr_cell.x == self._target.x and
        self._curr_cell.y == self._target.y then
        self:_aquire_target(player, tilesize)
    end

    self:_move(dt, tilesize)
end

function Tripod.draw(self)    
    love.graphics.draw(self.sprite, self.x, self.y, self.rot, self.scale, self.scale, self.offset, self.offset)

    if self._is_stuck then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("fill", self.x, self.y, self.size/2)
        love.graphics.setColor(r, g, b, a)
    end
end

function Tripod._aquire_target(self, player, tilesize)
    self._target, self._start = self._start, self._target
end

function Tripod._move(self, dt, tilesize)    
    local px, py = utils.grid_to_center_point(self._next_cell.x, self._next_cell.y, tilesize)
    local has_reached = false
    self.x, self.y, has_reached = utils.lerp(self, {x = px, y = py}, self.speed * dt)

    if has_reached then
        self:_get_next_cell(tilesize)
    end
end

return Tripod