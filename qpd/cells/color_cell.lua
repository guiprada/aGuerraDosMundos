local color_cell = {}

function color_cell.make_func(color, tilesize)
    return  
        function (x, y)
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

function color_cell.new(color, tilesize)
    return color_cell.make_func(color, tilesize)
end

return color_cell