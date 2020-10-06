local view = {}

local utils = require "qpd.utils"
local tilemap = require "qpd.tilemap"
local camera = require "qpd.camera"

local files = require "qpd.services.files"

--------------------------------------------------------------------------------

function view.calculate_tilesize(w, h, n_tiles_w, n_tiles_h)
    local map_ratio = n_tiles_w/n_tiles_h
    local screen_ratio = w/h

    if map_ratio > screen_ratio then -- wider, limited by width
        return w/n_tiles_w
    else -- taller, limited by height
        return h/n_tiles_h
    end    
end

function view.new(matrix, cell_set, width, height, tilesize)
    local o = {}

    o.tile_width = #matrix[1]
    o.tile_height = #matrix 

    o.tilesize = tilesize or calculate_tilesize(width, height, o.tile_width, o.tile_height)

    -- camera
    local tilemap_width = o.tilesize * o.tile_width
    local tilemap_height = o.tilesize * o.tile_height

    o.camera = camera.new(tilemap_width, tilemap_height, 1, 3)
    o.camera:set_viewport(0, 0, width, height)

    -- offsets
    o.offset_x = (width - tilemap_width)/2 - o.tilesize/2
    o.offset_y = (height - tilemap_height)/2 - o.tilesize/2

    -- create map
    o.tilemap = tilemap.new(o.offset_x,
                            o.offset_y,
                            o.tilesize,
                            matrix,
                            cell_set)

    utils.assign_methods(o, view)
    return o
end

--------------------------------------------------------------------------------

function view.zoom_in(self, factor)
    self.camera:set_scale(self.camera:get_scale() * (1+factor))
end

function view.zoom_out(self, factor)
    if factor ~= 0 then
        self.camera:set_scale(self.camera:get_scale() / (1+factor))
    end
end

function view.change_grid(self, new_val, grid_x, grid_y)
    self.tilemap:change_grid(new_val, grid_x, grid_y)
end

return view