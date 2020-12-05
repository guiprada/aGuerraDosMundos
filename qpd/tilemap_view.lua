local tilemap_view = {}

local utils = require "qpd.utils"
local tilemap = require "qpd.tilemap"
local camera = require "qpd.camera"
local grid = require "qpd.grid"

local files = require "qpd.services.files"

--------------------------------------------------------------------------------
-- helper functions

local function _draw(tilemap, tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
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
                            tilesize)
                elseif value ~= nil and value~=0 then
                    print("draw function for: " .. value .. " not found!")
                end
            end
        end
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

local function _calculate_tilesize(w, h, n_tiles_w, n_tiles_h)
    local map_ratio = n_tiles_w/n_tiles_h
    local screen_ratio = w/h

    if map_ratio > screen_ratio then -- wider, limited by height
        return h/n_tiles_h
    else -- taller, limited by width
        return w/n_tiles_w
    end    
end

--------------------------------------------------------------------------------

function tilemap_view.new(matrix, cell_set, width, height)
    local o = {}

    local tile_width = #matrix[1]
    local tile_height = #matrix 

    o.tilesize = _calculate_tilesize(width, height, tile_width, tile_height)
    
    -- camera
    local tilemap_width = o.tilesize * tile_width
    local tilemap_height = o.tilesize * tile_height

    o.camera = camera.new(tilemap_width, tilemap_height, 1, 3)
    o.camera:set_viewport(0, 0, tilemap_width, tilemap_height)
    
    -- create map
    o.tilemap = tilemap.new(0,
                            0,
                            matrix,
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

    matrix_start_x, matrix_start_y = grid.point_to_cell(start_x, start_y, self.tilesize)
    matrix_end_x, matrix_end_y = grid.point_to_cell(end_x, end_y, self.tilesize)
    
    matrix_start_x = utils.clamp(matrix_start_x, 1, self.tilemap.tile_width)
    matrix_end_x = utils.clamp(matrix_end_x, 1, self.tilemap.tile_width)
    matrix_start_y = utils.clamp(matrix_start_y, 1, self.tilemap.tile_height)
    matrix_end_y =utils.clamp(matrix_end_y, 1, self.tilemap.tile_height)

    _draw(self.tilemap, self.tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
end



return tilemap_view