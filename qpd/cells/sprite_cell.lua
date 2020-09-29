local sprite_cell = {}
local utils = require "qpd.utils"

function sprite_cell.make_func(sprite, tilesize)
    local width, height = sprite:getDimensions()
    local size = utils.max(width, height) 
    local scale = tilesize/size
    return  
        function (x, y)            
            love.graphics.draw(
                sprite,
                x,
                y,
                0,
                scale,
                scale)            
        end    
end

function sprite_cell.new(sprite, tilesize)
    return sprite_cell.make_func(sprite, tilesize)
end

return sprite_cell