local Tripod = {}
local utils = require "qpd.utils"

local function check_unobstructed(origin, angle, distance, grid, tilesize)
    local current_cell = {}
    local x, y = origin.x, origin.y

    local step_x = math.cos( angle ) * tilesize
    local step_y = math.sin( angle ) * tilesize

    local acc_distance = 0

    while acc_distance < distance do
        current_cell.x, current_cell.y = utils.point_to_grid(x, y, tilesize)
        if grid:is_colliding_grid(current_cell.x, current_cell.y) then
            return false
        end
        acc_distance = acc_distance + tilesize
        x, y = x + step_x, y + step_y
    end
    return true
end

function Tripod._update__rotation(self)
    local delta_x = self._next_cell.x - self._curr_cell.x
    local delta_y = self._next_cell.y - self._curr_cell.y

    self._rot = math.atan2(delta_y, delta_x)
end

function Tripod._get_next_cell(self, player, tilesize)
    if player and self:_can_see(player, tilesize) then
        self._target.x = player._cell.x
        self._target.y = player._cell.y
    end
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

    self:_update__rotation()
end

function Tripod._can_see(self, player, tilesize)
    local p_player = {x = player._x, y = player._y}
    local p_self = {x = self._x, y = self._y}
    local distance = utils.distance(p_player, p_self)
    if distance < self.vision_dist then
        -- check within angle
        local delta_y = p_player.y - p_self.y
        local delta_x = p_player.x - p_self.x
        local angle = math.atan2(delta_y, delta_x)

        if  self._rot - self.vision_angle < angle or
            self._rot + self.vision_angle > angle then
        -- it is in view
        -- check unobstructed
            if check_unobstructed(p_self, angle, self.vision_dist, self.grid, tilesize) then
                return true
            end
        end
    end
    return false
end

function Tripod.new(x, y, sprite, grid, _size, tilesize, target, speed, vision_dist, vision_angle)
    local o = {}

    o.sprite = sprite
    o.grid = grid
    o.speed = speed
    o.vision_dist = vision_dist or 10*tilesize
    if vision_angle then
        o.vision_angle = vision_angle/2
    else
        o.vision_angle = math.pi/10
    end

    o._x = x
    o._y = y
    o._size = _size or 1
    o._scale = _size/ sprite:getWidth()
    o._rot = 0
    o._offset = (o._size/2) * (1/o._scale)
        
    o._start = {}
    o._start.x, o._start.y = utils.point_to_grid(o._x , o._y, tilesize)
    o._target = target
    o._curr_cell = {}
    o._curr_cell.x, o._curr_cell.y = o._start.x, o._start.y
    o._last_try = 1
    
    utils.assign_methods(o, Tripod)
    o._last_cell = {}
    o._next_cell = {}
    o:_get_next_cell(nil, tilesize)

    return o
end

function Tripod.update(self, dt, player, tilesize)
    self._curr_cell.x, self._curr_cell.y = utils.point_to_grid(self._x, self._y, tilesize)

    -- has reached the target?
    if  self._curr_cell.x == self._target.x and
        self._curr_cell.y == self._target.y then
        self:_aquire_target(tilesize)
    end

    self:_move(dt, player, tilesize)
end

function Tripod.draw(self)    
    love.graphics.draw(self.sprite, self._x, self._y, self._rot, self._scale, self._scale, self._offset, self._offset)

    if self._is_stuck then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("fill", self._x, self._y, self._size/2)
        love.graphics.setColor(r, g, b, a)
    end
end

function Tripod._aquire_target(self, tilesize)
    self._target, self._start = self._start, self._target
end

function Tripod._move(self, dt, player, tilesize)    
    local px, py = utils.grid_to_center_point(self._next_cell.x, self._next_cell.y, tilesize)
    local has_reached = false
    self._x, self._y, has_reached = utils.lerp({x = self._x, y = self._y}, {x = px, y = py}, self.speed * dt)

    if has_reached then
        self:_get_next_cell(player, tilesize)
    end
end

return Tripod