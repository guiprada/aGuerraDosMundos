local Tripod = {}
local utils = require "qpd.utils"

local function check_unobstructed(origin, angle, distance, grid, tilesize)
    local current_cell = {}
    local x, y = origin.x, origin.y

    -- we go tile by tile
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

    --self._rot = math.atan2(delta_y, delta_x)
    local o2 = math.atan2(delta_y, delta_x)
    self._rot = utils.lerp_rotation(self._rot, o2, self.vision_angle/10)
end

function Tripod._get_next_cell(self, targets, tilesize)
    local viable_targets = {}
    for _, target in ipairs(targets) do
        if self:_can_see(target, tilesize) then
            table.insert(viable_targets, target)
        end 
    end
    if #viable_targets >= 1 then
        local closest = viable_targets[1]
        local min_distance = utils.distance(self, closest)
        for i = 2, #viable_targets, 1 do
            local this_distance = utils.distance(self, viable_targets[i])
            if this_distance < min_distance then
                closest = viable_targets[i]
                min_distance = this_distance
            end
        end
        
        self._target_cell.x = closest._cell.x
        self._target_cell.y = closest._cell.y
        self.speed = self.speed_boost * self.start_speed
    else
        self.speed = self.start_speed
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
        local min_dist = utils.distance(allowed[1], self._target_cell)
        local next_grid = allowed[1]
        for i=2, #allowed, 1 do
            local dist = utils.distance(allowed[i], self._target_cell)
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
            self._target_cell = self.grid:get_valid_pos()
            self._is_stuck = false
        end
    else
        print("error: Tripod has nowhere to go!")
        self._next_cell.x, self._next_cell.y = self._curr_cell.x, self._curr_cell.y        
    end

    self:_update__rotation()
end

function Tripod._can_see(self, target, tilesize)
    local p_target = {x = target.x, y = target.y}
    local p_self = {x = self.x, y = self.y}
    local distance = utils.distance(p_target, p_self)
    if distance < self.vision_dist then
        -- check within angle
        local delta_y = p_target.y - p_self.y
        local delta_x = p_target.x - p_self.x
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

function Tripod.new(start_cell, end_cell, sprite, grid, _size, tilesize, speed, speed_boost, vision_dist, vision_angle)
    local o = {}

    o._sprite = sprite
    o.grid = grid
    o.start_speed = speed
    o.speed = speed
    o.speed_boost = speed_boost
    o.vision_dist = vision_dist or 10*tilesize
    if vision_angle then
        o.vision_angle = vision_angle/2
    else
        o.vision_angle = math.pi/10
    end

    o.x, o.y = utils.grid_to_center_point(start_cell.x, start_cell.y, tilesize)
    o._start_cell = start_cell
    o._end_cell = end_cell
    o._target_cell = {}
    o._target_cell.x, o._target_cell.y = end_cell.x, end_cell.y
    o._curr_cell = {}
    o._curr_cell.x, o._curr_cell.y = o._start_cell.x, o._start_cell.y
    
    o._size = _size or 1
    o._scale = _size/ sprite:getWidth()
    o._rot = 0
    o._offset = (o._size/2) * (1/o._scale)
      
    utils.assign_methods(o, Tripod)
    o._last_cell = {}
    o._next_cell = {}
    o:_get_next_cell({}, tilesize)

    return o
end

function Tripod.update(self, dt, targets, tilesize)
    self._curr_cell.x, self._curr_cell.y = utils.point_to_grid(self.x, self.y, tilesize)

    -- has reached the target?
    if  self._curr_cell.x == self._target_cell.x and
        self._curr_cell.y == self._target_cell.y then
        self:_aquire_target_cell(tilesize)
    end

    self:_move(dt, targets, tilesize)
end

function Tripod.draw(self)    
    love.graphics.draw(self._sprite, self.x, self.y, self._rot, self._scale, self._scale, self._offset, self._offset)

    if self._is_stuck then
        local r, g, b, a = love.graphics.getColor()
        love.graphics.setColor(255, 0, 0)
        love.graphics.circle("fill", self.x, self.y, self._size/2)
        love.graphics.setColor(r, g, b, a)
    end
end

function Tripod._aquire_target_cell(self, tilesize)
    if  self._target_cell.x == self._end_cell.x and
        self._target_cell.y == self._end_cell.y then
        self._target_cell.x, self._start_cell.y = self._start_cell.x, self._target_cell.y
    elseif  self._target_cell.x == self._start_cell.x and
            self._target_cell.y == self._start_cell.y then
        self._target_cell.x, self._start_cell.y = self._end_cell.x, self._end_cell.y
    else
        local furthest = "_end_cell"
        if utils.distance(self._curr_cell, self._start_cell) > utils.distance(self._curr_cell, self._end_cell) then
            furthest = "_start_cell"
        end
        self._target_cell.x, self._start_cell.y = self[furthest].x, self[furthest].y
    end
end

function Tripod._move(self, dt, targets, tilesize)    
    local px, py = utils.grid_to_center_point(self._next_cell.x, self._next_cell.y, tilesize)
    local has_reached = false
    self.x, self.y, has_reached = utils.lerp({x = self.x, y = self.y}, {x = px, y = py}, self.speed * dt)

    if has_reached then
        self:_get_next_cell(targets, tilesize)
    end
end

return Tripod