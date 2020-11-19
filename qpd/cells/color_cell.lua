local color_cell = {}

function color_cell.make_func(color)
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

function color_cell.new(color)
    return color_cell.make_func(color)
end

return color_cell