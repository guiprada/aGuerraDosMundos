local tilemap = {}

local utils = require "qpd.utils"

--------------------------------------------------------------------------------

function tilemap.new(x, y, matrix, draw_functions)
    local o = {}
    o.x = x
    o.y = y    
    o.matrix = matrix
    o.draw_functions = draw_functions

    o.tile_width = #matrix[1]
    o.tile_height = #matrix 

    utils.assign_methods(o, tilemap)
    return o
end

--------------------------------------------------------------------------------

function tilemap.change_matrix(self, new_val, x, y)
    self.matrix[y][x] = utils.clamp(new_val, 0, #self.draw_functions)
end

function tilemap.save(self, filepath)
    utils.matrix_write_to_file(self.matrix, filepath, ',')
end

function tilemap.add_top(self)    
    for i = #self.matrix, 1, -1 do
        self.matrix[i+1] = self.matrix[i]
    end
    self.matrix[1] = {}
    for i = 1, #self.matrix[2], 1 do
        self.matrix[1][i] = 0
    end
end

function tilemap.add_bottom(self)
    local new_index = #self.matrix + 1
    self.matrix[new_index] = {}
    for i = 1, #self.matrix[1], 1 do
        self.matrix[new_index][i] = 0
    end
end

function tilemap.add_right(self)
    local new_index = #self.matrix[1] + 1
    for i = 1, #self.matrix, 1 do
        self.matrix[i][new_index] = 0
    end
end

function tilemap.add_left(self)
    for i = 1, #self.matrix, 1 do
        table.insert( self.matrix[i], 1, 0)
    end
end

return tilemap