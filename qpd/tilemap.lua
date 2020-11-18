local tilemap = {}

local utils = require "qpd.utils"

--------------------------------------------------------------------------------

function tilemap.new(x, y, tilesize, matrix, draw_functions)
    local o = {}
    o.x = x
    o.y = y
    o.tilesize = tilesize
    o.matrix = matrix
    o.draw_functions = draw_functions

    utils.assign_methods(o, tilemap)
    return o
end

--------------------------------------------------------------------------------

function tilemap.draw(self, grid_start_x, grid_start_y, grid_end_x, grid_end_y)
    local draw_counter = 0
    if grid_start_x and grid_start_y and grid_end_x and grid_end_y then
         for n_column = grid_start_y, grid_end_y, 1 do
            local this_column = self.matrix[n_column]
            for n_line = grid_start_x, grid_end_x, 1 do
                local value = this_column[n_line]
                local func = self.draw_functions[value]
                if func then
                    local this_x = (n_line - 1) *self.tilesize + self.x
                    local this_y = (n_column - 1)*self.tilesize + self.y
                    func(   this_x,
                            this_y,
                            self.tilesize)
                    draw_counter = draw_counter + 1
                elseif value ~= nil and value~=0 then
                    print("draw function for: " .. value .. " not found!")
                end
            end
        end
        print(draw_counter)
    else
        for n_line, line in ipairs(self.matrix) do
            for n_column, value in ipairs(line) do
                local func = self.draw_functions[value]
                if func then
                    func(
                        (n_column - 1) *self.tilesize + self.x,
                        (n_line - 1)*self.tilesize + self.y,
                        self.tilesize)
                else
                    if value ~= 0 then
                        print("draw function for: " .. value .. " not found!")
                    end
                end
            end
        end
    end


        -- for n_line, line in ipairs(self.matrix) do
        --     for n_column, value in ipairs(line) do
        --         local func = self.draw_functions[value]
        --         if func then
        --             local this_x = (n_column - 1) *self.tilesize + self.x
        --             local this_y = (n_line - 1)*self.tilesize + self.y
        --             if utils.check_collision(   this_x, this_y, self.tilesize, self.tilesize,
        --                                         start_x, start_y, end_x - start_x, end_y - start_y) then
        --                 func(
        --                     this_x,
        --                     this_y,
        --                     self.tilesize)
        --                 draw_counter = draw_counter + 1
        --             end
        --         else
        --             if value ~= 0 then
        --                 print("draw function for: " .. value .. " not found!")
        --             end
        --         end
        --     end
        -- end
        -- print(draw_counter)
end

function tilemap.change_grid(self, new_val, grid_x, grid_y)
    self.matrix[grid_y][grid_x] = utils.clamp(new_val, 0, #self.draw_functions)
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