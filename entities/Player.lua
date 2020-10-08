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
    local front_x, front_y = new_x, new_y
    if love.keyboard.isDown(keymap.keys.up) and (not love.keyboard.isDown(keymap.keys.down)) then        
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y - self.speed * dt
            front_x, front_y = new_x, new_y - self.size/2
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self.y - diag * self.speed * dt
            new_x = self.x - diag * self.speed * dt
            front_x, front_y = new_x - self.size/2, new_y - self.size/2
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y - diag * self.speed * dt
            new_x = self.x + diag * self.speed * dt
            front_x, front_y = new_x + self.size/2, new_y - self.size/2
        else
            new_y = self.y - self.speed * dt
            front_x, front_y = new_x, new_y - self.size/2
        end
    elseif love.keyboard.isDown(keymap.keys.down) and (not love.keyboard.isDown(keymap.keys.up)) then
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y + self.speed * dt
            front_x, front_y = new_x, new_y + self.size/2
        elseif love.keyboard.isDown(keymap.keys.left) then
            new_y = self.y + diag * self.speed * dt
            new_x = self.x - diag * self.speed * dt
            front_x, front_y = self.x - self.size/2, new_y + self.size/2
        elseif love.keyboard.isDown(keymap.keys.right) then
            new_y = self.y + diag * self.speed * dt
            new_x = self.x + diag * self.speed * dt
            front_x, front_y = self.x + self.size/2, new_y + self.size/2
        else 
            new_y = self.y + self.speed * dt
            front_x, front_y = self.x, new_y + self.size/2
        end
    else
        if love.keyboard.isDown(keymap.keys.left) then
            new_x = self.x - self.speed * dt
            front_x, front_y = self.x - self.size/2, new_y
        end
        if love.keyboard.isDown(keymap.keys.right) then
            new_x = self.x + self.speed * dt
            front_x, front_y = self.x + self.size/2, new_y
        end
    end

    --check collision
    if not self.grid:is_colliding(front_x, front_y) then
        self.x, self.y = new_x, new_y
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