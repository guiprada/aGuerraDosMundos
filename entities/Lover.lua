local Lover = {}

local utils = require "qpd.utils"

function Lover._move(self, dt, tilesize)    
    local px, py = utils.grid_to_center_point(self._target_cell.x, self._target_cell.y, tilesize)
    local has_reached = false
    self.x, self.y, has_reached = utils.lerp({x = self.x, y = self.y}, {x = px, y = py}, self.speed * dt)
    
    self._cell.x, self._cell.y = utils.point_to_grid(self.x, self.y, tilesize)

    if has_reached then
        self._target_cell.x, self._target_cell.y = self.target._cell.x, self.target._cell.y
    elseif self.grid:is_colliding(self.x, self.y, tilesize) then
        self._is_active = false
    end
end

function Lover.new(cell_x, cell_y, sprite, grid, size, target, tilesize, speed)
    local o = {}
    o._is_active = false
    o._size = size
    o._scale = size/ sprite:getWidth()
    o._rot = -math.pi/2
    o._offset = (o._size/2) * (1/o._scale)
    o._cell = {}
    o._cell.x, o._cell.y = cell_x, cell_y

    o._sprite = sprite
    o.grid = grid

    o.target = target
    o.speed = speed
    o.x, o.y = utils.grid_to_center_point(cell_x, cell_y, tilesize)
    o.old_x, o.old_y = o.x, o.y
    o.health = 100

    o._target_cell = {}

    utils.assign_methods(o, Lover)
    return o
    -- body
end

function Lover.update(self, dt, tilesize)
    if self._is_active then
        if utils.distance(self, self.target) > 10* tilesize then
            self._is_active =  false
        end
        self.old_x, self.old_y = self.x, self.y
        self:_move(dt, tilesize)
        delta_x, delta_y = self.x - self.old_x, self.y - self.old_y
        if delta_x~=0 or delta_y~=0 then
            self._rot = math.atan2(delta_y, delta_x)
        end
    elseif utils.distance(self, self.target) < 3* tilesize then
        self._is_active = true
        self._target_cell.x, self._target_cell.y = self.target._cell.x, self.target._cell.y  
    end
end

function Lover.draw(self, collision_enabled)    
    --love.graphics.circle("fill", self.x, self.y, self._size/2)
    love.graphics.draw(self._sprite, self.x, self.y, self._rot, self._scale, self._scale, self._offset, self._offset)

    -- save color
    local r, g, b, a = love.graphics.getColor()
    -- health shadow    
    local damage = self.health/100
    love.graphics.setColor(0, 0, 0, 1 - damage)
    love.graphics.circle("fill", self.x, self.y, (self._size/2)+0.5)
        
    if not collision_enabled then
        love.graphics.setColor(1,0,0, 0.6)
        love.graphics.circle("fill", self.x, self.y, (self._size/2)+0.5)
    end

    -- restore color
    love.graphics.setColor(r, g, b, a)
end

function Lover.take_health(self, h_much)
    self.health = self.health - h_much
end

return Lover