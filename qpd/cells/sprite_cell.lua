local sprite_cell = {}

function sprite_cell.make_func(sprite)
    return  
        function (x, y, tilesize)
            local r, g, b, a = love.graphics.getColor()
            love.graphics.setColor(unpack(color))
            love.graphics.rectangle(
                "fill",
                x,
                y,
                tilesize,
                tilesize)
            love.graphics.setColor(r, g, b, a)                
        end    
end

function sprite_cell.new(sprite)
    return sprite_cell.make_func(sprite)
end

return sprite_cell