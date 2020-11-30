local Player = {}

local keymap = require "qpd.services.keymap"
local utils = require "qpd.utils"

function Player.new(x, y, sprite, grid, size, tilesize, speed)
    local o = {}
     
    o.speed = speed or 1
    o.sprite = sprite    
    o.grid = grid
    o.health = 100

    o._x = x or 0
    o._y = y or 0
    o._size = size or 1
    o._scale = size/ sprite:getWidth()
    o._rot = -math.pi/2
    o._offset = (o._size/2) * (1/o._scale)
 
    o._cell = {}
    o._cell.x, o._cell.y = utils.point_to_grid(o._x, o._y, tilesize)
    
    utils.assign_methods(o, Player)

    return o
end

function Player.update(self, dt, tilesize)
    local diag = 1/math.sqrt(2)
    local new_x, new_y = self._x, self._y

    if love.keyboard.isDown(keymap.keys.up) and (not love.keyboard.isDown(keymap.keys.down)) then        
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self._y - self.speed * dt            
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self._y - diag * self.speed * dt
            new_x = self._x - diag * self.speed * dt            
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self._y - diag * self.speed * dt
            new_x = self._x + diag * self.speed * dt            
        else
            new_y = self._y - self.speed * dt            
        end
    elseif love.keyboard.isDown(keymap.keys.down) and (not love.keyboard.isDown(keymap.keys.up)) then
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self._y + self.speed * dt            
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self._y + diag * self.speed * dt
            new_x = self._x - diag * self.speed * dt
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self._y + diag * self.speed * dt
            new_x = self._x + diag * self.speed * dt
        else 
            new_y = self._y + self.speed * dt
        end
    else
        if love.keyboard.isDown(keymap.keys.left) then
            new_x = self._x - self.speed * dt
        end
        if love.keyboard.isDown(keymap.keys.right) then
            new_x = self._x + self.speed * dt
        end
    end

    -- update rotation
    local delta_x = new_x - self._x
    local delta_y = new_y - self._y

    if delta_x~=0 or delta_y~=0 then
        self._rot = math.atan2(delta_y, delta_x)
    end

    --
    local size = self._size/2
    top_x, top_y = new_x, new_y - size
    botton_x, botton_y = new_x, new_y + size
    left_x, left_y = new_x - size, new_y
    right_x, right_y = new_x + size, new_y

    --check collision
    if  not self.grid:is_colliding(top_x, top_y, tilesize) and
        not self.grid:is_colliding(botton_x, botton_y, tilesize) then

        self._y = new_y
    elseif  not self.grid:is_colliding(top_x, top_y, tilesize) and
            new_y < self._y then

        self._y = new_y
    elseif not self.grid:is_colliding(botton_x, botton_y, tilesize) and
            new_y > self._y then
            
        self._y = new_y
    end
    if  not self.grid:is_colliding(left_x, left_y, tilesize) and
        not self.grid:is_colliding(right_x, right_y, tilesize) then

        self._x = new_x

    elseif  not self.grid:is_colliding(left_x, left_y, tilesize) and
            new_x < self._x then

        self._x = new_x
    elseif  not self.grid:is_colliding(right_x, right_y, tilesize) and
            new_x > self._x then
    
        self._x = new_x
    end

    -- update cell
    self._cell.x, self._cell.y = utils.point_to_grid(self._x, self._y, tilesize)
end

function Player.draw(self, collision_enabled)    
    --love.graphics.circle("fill", self._x, self._y, self._size/2)
    love.graphics.draw(self.sprite, self._x, self._y, self._rot, self._scale, self._scale, self._offset, self._offset)

    -- save color
    local r, g, b, a = love.graphics.getColor()
    -- health shadow    
    local damage = self.health/100
    love.graphics.setColor(0, 0, 0, 1 - damage)
    love.graphics.circle("fill", self._x, self._y, (self._size/2)+0.5)
        
    if not collision_enabled then
        love.graphics.setColor(1,0,0, 0.6)
        love.graphics.circle("fill", self._x, self._y, (self._size/2)+0.5)
    end

    -- restore color
    love.graphics.setColor(r, g, b, a)
end

function Player.get_center(self)
    return self._x, self._y
end

function Player.take_health(self, h_much)
    self.health = self.health - h_much
end

return Player