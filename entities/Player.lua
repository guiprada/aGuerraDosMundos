local Player = {}

local keymap = require "qpd.services.keymap"
local utils = require "qpd.utils"
local grid = require "qpd.grid"

function Player.new(x, y, sprite, grid, size, tilesize, speed_factor, health_max)
    local o = {}
    o.x = x
    o.y = y

    o._sprite = sprite
    o._size = size
    o._scale = size/ sprite:getWidth()
    o._rot = -math.pi/2
    o._offset = (o._size/2) * (1/o._scale)
 
    o._cell = {}
    o._cell.x, o._cell.y = grid.point_to_grid(o.x, o.y, tilesize)    
     
    o.speed_factor = speed_factor
    o.grid = grid
    o.health = health_max  
    
    utils.assign_methods(o, Player)

    return o
end

function Player.update(self, dt, tilesize)
    local diag = 1/math.sqrt(2)
    local new_x, new_y = self.x, self.y

    local motion = self.speed_factor * tilesize * dt
    local diag_motion = diag * motion
    if love.keyboard.isDown(keymap.keys.up) and (not love.keyboard.isDown(keymap.keys.down)) then        
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y - motion            
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self.y - diag_motion
            new_x = self.x - diag_motion            
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y - diag_motion
            new_x = self.x + diag_motion            
        else
            new_y = self.y - motion            
        end
    elseif love.keyboard.isDown(keymap.keys.down) and (not love.keyboard.isDown(keymap.keys.up)) then
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y + motion            
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self.y + diag_motion
            new_x = self.x - diag_motion
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y + diag_motion
            new_x = self.x + diag_motion
        else 
            new_y = self.y + motion
        end
    else
        if love.keyboard.isDown(keymap.keys.left) then
            new_x = self.x - motion
        end
        if love.keyboard.isDown(keymap.keys.right) then
            new_x = self.x + motion
        end
    end

    -- update rotation
    local delta_x = new_x - self.x
    local delta_y = new_y - self.y

    if delta_x~=0 or delta_y~=0 then
        self._rot = math.atan2(delta_y, delta_x)
    end

    local offset = self._size/2

    -- local top_left_x, top_left_y = new_x - offset/2, new_y - offset/2
    -- local top_right_x, top_right_y = new_x + offset/2, new_y - offset/2
    -- local botton_left_x, botton_left_y = new_x - offset/2, new_y + offset/2
    -- local botton_right_x, botton_right_y = new_x + offset/2, new_y + offset/2
    
    -- local top_left = self.grid:is_colliding_point(top_left_x, top_left_y, tilesize)
    -- local top_right = self.grid:is_colliding_point(top_right_x, top_right_y, tilesize)
    -- local botton_left = self.grid:is_colliding_point(botton_left_x, botton_left_y, tilesize)
    -- local botton_right = self.grid:is_colliding_point(botton_right_x, botton_right_y, tilesize)

    if new_x > self.x then -- wants to go right
        local right_x, right_y = new_x + offset, new_y
        if not self.grid:is_colliding_point(right_x, right_y, tilesize) then
            self.x = new_x
        end
    elseif  new_y < self.x then -- wants to go left
        local left_x, left_y = new_x - offset, new_y
        if not self.grid:is_colliding_point(left_x,left_y, tilesize) then
            self.x = new_x
        end
    end
    if new_y < self.y then -- wants to go up
        local top_x, top_y = new_x, new_y - offset
        if not self.grid:is_colliding_point(top_x, top_y, tilesize) then
            self.y = new_y
        end
    elseif new_y > self.y then -- wantos to go down
        local botton_x, botton_y = new_x, new_y + offset
        if  not self.grid:is_colliding_point(botton_x, botton_y, tilesize) then
            self.y = new_y
        end
    end

    -- update cell
    self._cell.x, self._cell.y = grid.point_to_grid(self.x, self.y, tilesize)
end

function Player.draw(self, collision_enabled)    
    --love.graphics.circle("fill", self.x, self.y, self._size/2)
    love.graphics.draw(self._sprite, self.x, self.y, self._rot, self._scale, self._scale, self._offset, self._offset)

    -- save color
    local r, g, b, a = love.graphics.getColor()
    -- health shadow    
    local damage = self.health/100
    love.graphics.setColor(0, 0, 0, 1 - damage)
    love.graphics.circle("fill", self.x, self.y, (self._size/2)+0.5)
        
    if not collision_enabled then
        love.graphics.setColor(0, 0,0, 0.6)
        love.graphics.circle("fill", self.x, self.y, (self._size/2)+0.5)
    end

    -- restore color
    love.graphics.setColor(r, g, b, a)
end

function Player.get_center(self)
    return self.x, self.y
end

function Player.take_health(self, h_much)
    self.health = self.health - h_much
end

function Player.resize(self, tilesize)
    self.x, self.y = grid.to_center_point(self._cell.x, self._cell.y, tilesize)
end

return Player