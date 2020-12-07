local tilemap_view = {}

local utils = require "qpd.utils"
local tilemap = require "qpd.tilemap"
local camera = require "qpd.camera"
local grid = require "qpd.grid"

local files = require "qpd.services.files"

--------------------------------------------------------------------------------
-- helper functions

local function _calculate_tilesize(w, h, n_tiles_w, n_tiles_h)
    -- diagonal based
    local screen_diag = math.sqrt(w^2 + h^2)
    local tiles_diag = math.sqrt(n_tiles_h^2 + n_tiles_w^2)
    return screen_diag/tiles_diag
end

--------------------------------------------------------------------------------

function tilemap_view.new(matrix, cell_set, width, height)
    local o = {}

    o.width = width
    o.height = height

    local tile_width = #matrix[1]
    local tile_height = #matrix 

    o.tilesize = _calculate_tilesize(width, height, tile_width, tile_height)
    
    -- camera
    local tilemap_width = o.tilesize * tile_width
    local tilemap_height = o.tilesize * tile_height

    o.camera = camera.new(tilemap_width, tilemap_height, 1, 1, 3)
    
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

    --print((self.width/self.camera:get_scale())/self.tilesize, (self.height/self.camera:get_scale())/self.tilesize)
    self.tilemap:draw(self.tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
    --self.tilemap:draw(self.tilesize)
end

function tilemap_view.follow(self, dt, speed_factor, follow_x, follow_y)
    local camera_center_x, camera_center_y = self.camera:get_center()
    local delta_y, delta_x = follow_y - camera_center_y, follow_x - camera_center_x
    local new_camera_x, new_camera_y = camera_center_x, camera_center_y
    if math.abs(delta_x) > (self.width/4)/self.camera:get_scale() then        
        new_camera_x, _ = utils.lerp(
            camera_center_x, 0,
            follow_x, 0,
            speed_factor  * self.tilesize * dt
        )
    end
    if math.abs(delta_y) > (self.height/4)/self.camera:get_scale() then        
        _, new_camera_y = utils.lerp(
            0, camera_center_y,
            0, follow_y,
            speed_factor  * self.tilesize * dt
        )
    end
    --new_camera_x = utils.clamp(new_camera_x, (self.width/2)/self.camera:get_scale(), self.camera:get_width() - (self.width/2)/self.camera:get_scale())
    --new_camera_y = utils.clamp(new_camera_y, (self.height/2)/self.camera:get_scale(), self.camera:get_height() - (self.height/2)/self.camera:get_scale())
    --self.camera:set_center(new_camera_x, new_camera_y)    
    
    self.camera:move(new_camera_x - camera_center_x, new_camera_y - camera_center_y)
end

function tilemap_view.resize(self, width, height)
    self.width = width
    self.height = height
        
    local tile_width = #self.tilemap.matrix[1]
    local tile_height = #self.tilemap.matrix 

    local old_tilesize = self.tilesize
    self.tilesize = _calculate_tilesize(width, height, tile_width, tile_height)

    local tilemap_width = self.tilesize * tile_width
    local tilemap_height = self.tilesize * tile_height

    self.camera:reset(tilemap_width, tilemap_height)    
    local old_camera_center_x, old_camera_center_y = self.camera:get_center()
    local old_camera_cell_x, old_camera_cell_y = grid.point_to_cell(old_camera_center_x, old_camera_center_y, old_tilesize)
    local new_camera_center_x, new_camera_center_y = grid.cell_to_center_point(old_camera_cell_x, old_camera_cell_y, self.tilesize)
    self.camera:set_center(new_camera_center_x, new_camera_center_y)
end

return tilemap_view