local tilemap_view = {}

local utils = require "qpd.utils"
local tilemap = require "qpd.tilemap"
local camera = require "qpd.camera"

local files = require "qpd.services.files"

--------------------------------------------------------------------------------
-- draw helper

local function _get_matrix_pos(x, y, tilesize)		
	matrix_x = math.floor(x / tilesize) + 1--lua arrays start at 1
	matrix_y = math.floor(y / tilesize) + 1 --lua arrays start at 1
	return matrix_x, matrix_y
end

local function _draw(tilemap, tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
    local draw_counter = 0
    if matrix_start_x and matrix_start_y and matrix_end_x and matrix_end_y then
         for n_column = matrix_start_y, matrix_end_y, 1 do
            local this_column = tilemap.matrix[n_column]
            for n_line = matrix_start_x, matrix_end_x, 1 do
                local value = this_column[n_line]
                local func = tilemap.draw_functions[value]
                if func then
                    local this_x = (n_line - 1) * tilesize + tilemap.x
                    local this_y = (n_column - 1)* tilesize + tilemap.y
                    func(   this_x,
                            this_y,
                            tilemap.tilesize)
                    draw_counter = draw_counter + 1
                elseif value ~= nil and value~=0 then
                    print("draw function for: " .. value .. " not found!")
                end
            end
        end
        print(draw_counter)
    else
        for n_line, line in ipairs(tilemap.matrix) do
            for n_column, value in ipairs(line) do
                local func = tilemap.draw_functions[value]
                if func then
                    func(
                        (n_column - 1) * tilesize + tilemap.x,
                        (n_line - 1)* tilesize + tilemap.y,
                        tilesize)
                else
                    if value ~= 0 then
                        print("draw function for: " .. value .. " not found!")
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------------

function tilemap_view.calculate_tilesize(w, h, n_tiles_w, n_tiles_h)
    local map_ratio = n_tiles_w/n_tiles_h
    local screen_ratio = w/h

    if map_ratio > screen_ratio then -- wider, limited by width
        return w/n_tiles_w
    else -- taller, limited by height
        return h/n_tiles_h
    end    
end

function tilemap_view.new(grid, cell_set, width, height, tilesize)
    local o = {}

    o.grid = grid

    

    o.tile_width = #o.grid.matrix[1]
    o.tile_height = #o.grid.matrix 

    o.tilesize = tilesize or calculate_tilesize(width, height, o.tile_width, o.tile_height)
    --o.tilesize = o.camera._w / o.tile_width
    
    -- camera
    local tilemap_width = o.tilesize * o.tile_width
    local tilemap_height = o.tilesize * o.tile_height

    o.camera = camera.new(tilemap_width, tilemap_height, 1, 3)
    o.camera:set_viewport(0, 0, width, height)

    
    -- offsets
    o.offset_x = - o.tilesize/2
    o.offset_y = - o.tilesize/2
    
    -- create map
    o.tilemap = tilemap.new(o.offset_x,
                            o.offset_y,
                            o.grid.matrix,
                            cell_set)

    utils.assign_methods(o, tilemap_view)
    return o
end

--------------------------------------------------------------------------------

function tilemap_view.zoom_in(self, factor)
    self.camera:set_scale(self.camera:get_scale() * (1+factor))
end

function tilemap_view.zoom_out(self, factor)
    if factor ~= 0 then
        self.camera:set_scale(self.camera:get_scale() / (1+factor))
    end
end

function tilemap_view.draw(self)
    local start_x, start_y, end_x, end_y = self.camera:get_visible_quad()

    matrix_start_x, matrix_start_y = _get_matrix_pos(start_x, start_y, self.tilesize)
    matrix_end_x, matrix_end_y = _get_matrix_pos(end_x, end_y, self.tilesize)
    
    matrix_start_x = utils.clamp(matrix_start_x, 1, self.grid.width)
    matrix_end_x = utils.clamp(matrix_end_x, 1, self.grid.width)
    matrix_start_y = utils.clamp(matrix_start_y, 1, self.grid.height)
    matrix_end_y =utils.clamp(matrix_end_y, 1, self.grid.height)

    _draw(self.tilemap, self.tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
end



return tilemap_view