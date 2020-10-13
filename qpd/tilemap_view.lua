local tilemap_view = {}

local utils = require "qpd.utils"
local tilemap = require "qpd.tilemap"
local camera = require "qpd.camera"

local files = require "qpd.services.files"

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
                            o.tilesize,
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

function tilemap_view.change_grid(self, new_val, grid_x, grid_y)
    self.tilemap:change_grid(new_val, grid_x, grid_y)
end

function tilemap_view.draw(self)
    local start_x, start_y, end_x, end_y = self.camera:get_visible_quad()

    self.tilemap:draw()
end

return tilemap_view