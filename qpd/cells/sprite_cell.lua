local sprite_cell = {}
local utils = require "qpd.utils"

function sprite_cell.make_func(sprite)
    return  
        function (x, y, tilesize)
            local width, height = sprite:getDimensions()
            local size = utils.max(width, height) 
            local scale = tilesize/size
            love.graphics.draw(
                sprite,
                x,
                y,
                0,
                scale,
                scale)            
        end    
end

function sprite_cell.new(sprite)
    return sprite_cell.make_func(sprite)
end

return sprite_cell