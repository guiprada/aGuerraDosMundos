local Player = {}

local keymap = require "qpd.services.keymap"
local utils = require "qpd.utils"

function Player.new(x, y, sprite, grid, size, speed)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    o.size = size or 1
    o.speed = speed or 1
    o.sprite = sprite
    o.grid = grid
    o.scale = size/ sprite:getWidth()
    o.rot = 0
    o.offset = -size/2

    utils.assign_methods(o, Player)

    return o
end

function Player.update(self, dt)
    local diag = 1/math.sqrt(2)
    local new_x, new_y = self.x, self.y

    if love.keyboard.isDown(keymap.keys.up) and (not love.keyboard.isDown(keymap.keys.down)) then        
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y - self.speed * dt            
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self.y - diag * self.speed * dt
            new_x = self.x - diag * self.speed * dt            
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y - diag * self.speed * dt
            new_x = self.x + diag * self.speed * dt            
        else
            new_y = self.y - self.speed * dt            
        end
    elseif love.keyboard.isDown(keymap.keys.down) and (not love.keyboard.isDown(keymap.keys.up)) then
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y + self.speed * dt            
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self.y + diag * self.speed * dt
            new_x = self.x - diag * self.speed * dt
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y + diag * self.speed * dt
            new_x = self.x + diag * self.speed * dt
        else 
            new_y = self.y + self.speed * dt
        end
    else
        if love.keyboard.isDown(keymap.keys.left) then
            new_x = self.x - self.speed * dt
        end
        if love.keyboard.isDown(keymap.keys.right) then
            new_x = self.x + self.speed * dt
        end
    end


    local size = math.floor(self.size/2)
    top_x, top_y = new_x, new_y - size
    botton_x, botton_y = new_x, new_y + size
    left_x, left_y = new_x - size, new_y
    right_x, right_y = new_x + size, new_y

    --check collision
    if  not self.grid:is_colliding(top_x, top_y) and
        not self.grid:is_colliding(botton_x, botton_y) then

        self.y = new_y
    elseif  not self.grid:is_colliding(top_x, top_y) and
            new_y < self.y then

        self.y = new_y
    elseif not self.grid:is_colliding(botton_x, botton_y) and
            new_y > self.y then
            
        self.y = new_y
    end
    if  not self.grid:is_colliding(left_x, left_y) and
        not self.grid:is_colliding(right_x, right_y) then

        self.x = new_x

    elseif  not self.grid:is_colliding(left_x, left_y) and
            new_x < self.x then

        self.x = new_x
    elseif  not self.grid:is_colliding(right_x, right_y) and
            new_x > self.x then
    
        self.x = new_x
    end
end

function Player.draw(self)    
    --love.graphics.circle("fill", self.x, self.y, self.size)
    love.graphics.draw(self.sprite, self.x, self.y, self.rot, self.scale, self.scale, self.offset, self.offset)
end

function Player.get_center(self)
    return self.x, self.y
end

return Player