local Player = {}

local keymap = require "qpd.services.keymap"
local utils = require "qpd.utils"

function Player.new(x, y, sprite, size, speed)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    o.size = size or 1
    o.speed = speed or 1
    o.sprite = sprite
    o.scale = size/ sprite:getWidth()
    o.angle = 0

    utils.assign_methods(o, Player)

    return o
end

function Player.update(self, dt)
    local diag = 1/math.sqrt(2)
    if love.keyboard.isDown(keymap.keys.up) and (not love.keyboard.isDown(keymap.keys.down)) then        
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y - self.speed * dt
        elseif love.keyboard.isDown(keymap.keys.left) then
            self.y = self.y - diag * self.speed * dt
            self.x = self.x - diag * self.speed * dt
        elseif love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y - diag * self.speed * dt
            self.x = self.x + diag * self.speed * dt
        else
            self.y = self.y - self.speed * dt
        end
    elseif love.keyboard.isDown(keymap.keys.down) and (not love.keyboard.isDown(keymap.keys.up)) then
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y + self.speed * dt
        elseif love.keyboard.isDown(keymap.keys.left) then
            self.y = self.y + diag * self.speed * dt
            self.x = self.x - diag * self.speed * dt
        elseif love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y + diag * self.speed * dt
            self.x = self.x + diag * self.speed * dt
        else 
            self.y = self.y + self.speed * dt
        end
    else
        if love.keyboard.isDown(keymap.keys.left) then
            self.x = self.x - self.speed * dt
        end
        if love.keyboard.isDown(keymap.keys.right) then
            self.x = self.x + self.speed * dt
        end
    end
end

function Player.draw(self)    
    --love.graphics.circle("fill", self.x, self.y, self.size)
    love.graphics.draw(self.sprite, self.x, self.y, self.angle, self.scale, self.scale)
end

return Player