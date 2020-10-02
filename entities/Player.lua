local Player = {}

local keymap = require "qpd.services.keymap"
local utils = require "qpd.utils"

function Player.new(x, y, size, speed)
    local o = {}
    o.x = x or 0
    o.y = y or 0
    o.size = size or 1
    o.speed = speed or 1

    utils.assign_methods(o, Player)

    return o
end

function Player.update(self)
    local diag = 1/math.sqrt(2)
    if love.keyboard.isDown(keymap.keys.up) and (not love.keyboard.isDown(keymap.keys.down)) then        
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y - self.speed
        elseif love.keyboard.isDown(keymap.keys.left) then
            self.y = self.y - diag * self.speed
            self.x = self.x - diag * self.speed
        elseif love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y - diag * self.speed
            self.x = self.x + diag * self.speed
        else
            self.y = self.y - self.speed
        end
    elseif love.keyboard.isDown(keymap.keys.down) and (not love.keyboard.isDown(keymap.keys.up)) then
        if love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y + self.speed
        elseif love.keyboard.isDown(keymap.keys.left) then
            self.y = self.y + diag * self.speed
            self.x = self.x - diag * self.speed
        elseif love.keyboard.isDown(keymap.keys.right) then
            self.y = self.y + diag * self.speed
            self.x = self.x + diag * self.speed
        else 
            self.y = self.y + self.speed
        end
    else
        if love.keyboard.isDown(keymap.keys.left) then
            self.x = self.x - self.speed
        end
        if love.keyboard.isDown(keymap.keys.right) then
            self.x = self.x + self.speed
        end
    end
end

function Player.draw(self)
    love.graphics.setColor(1,0,0)
    love.graphics.circle("fill", self.x, self.y, self.size)
    love.graphics.setColor(1,1,1)
end

return Player