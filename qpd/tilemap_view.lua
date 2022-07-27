local tilemap_view = {}

local qpd_table = require "qpd.table"
local qpd_value = require "qpd.value"
local qpd_point = require "qpd.point"
local qpd_tilemap = require "qpd.tilemap"
local qpd_camera = require "qpd.camera"
local qpd_grid = require "qpd.grid"

--------------------------------------------------------------------------------
-- helper functions

local function _calculate_tilesize(w, h, n_tiles_w, n_tiles_h)
	local max_size_in_width = w/n_tiles_w
	local max_size_in_height = h/n_tiles_h

	return math.floor(qpd_value.min(max_size_in_width, max_size_in_height))
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

	o.camera = qpd_camera.new(tilemap_width, tilemap_height, 1, 1, 3)

	-- create map
	o.tilemap = qpd_tilemap.new(0,
							0,
							matrix,
							cell_set)

	qpd_table.assign_methods(o, tilemap_view)
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

	local matrix_start_x, matrix_start_y = qpd_grid.point_to_cell(start_x, start_y, self.tilesize)
	local matrix_end_x, matrix_end_y = qpd_grid.point_to_cell(end_x, end_y, self.tilesize)

	matrix_start_x = qpd_value.clamp(matrix_start_x, 1, self.tilemap.tile_width)
	matrix_end_x = qpd_value.clamp(matrix_end_x, 1, self.tilemap.tile_width)
	matrix_start_y = qpd_value.clamp(matrix_start_y, 1, self.tilemap.tile_height)
	matrix_end_y =qpd_value.clamp(matrix_end_y, 1, self.tilemap.tile_height)

	--print((self.width/self.camera:get_scale())/self.tilesize, (self.height/self.camera:get_scale())/self.tilesize)
	self.tilemap:draw(self.tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
	--self.tilemap:draw(self.tilesize)
end

function tilemap_view.follow(self, dt, speed_factor, follow_x, follow_y)
	local camera_center_x, camera_center_y = self.camera:get_center()
	local delta_y, delta_x = follow_y - camera_center_y, follow_x - camera_center_x
	local new_camera_x, new_camera_y = camera_center_x, camera_center_y
	if math.abs(delta_x) > (self.width/4)/self.camera:get_scale() then
		new_camera_x, _ = qpd_point.lerp(
			camera_center_x, 0,
			follow_x, 0,
			speed_factor  * self.tilesize * dt
		)
	end
	if math.abs(delta_y) > (self.height/4)/self.camera:get_scale() then
		_, new_camera_y = qpd_point.lerp(
			0, camera_center_y,
			0, follow_y,
			speed_factor  * self.tilesize * dt
		)
	end

	self.camera:move(new_camera_x - camera_center_x, new_camera_y - camera_center_y)
end

function tilemap_view.resize(self, width, height)
	self.width = width
	self.height = height

	local tile_width = #self.tilemap.matrix[1]
	local tile_height = #self.tilemap.matrix

	self.tilesize = _calculate_tilesize(width, height, tile_width, tile_height)

	local tilemap_width = self.tilesize * tile_width
	local tilemap_height = self.tilesize * tile_height

	local x_over = width - tilemap_width
	local y_over = height - tilemap_height
	local new_center_x = (width)/2 - x_over/2
	local new_center_y = (height)/2 - y_over/2

	self.camera:reset(tilemap_width, tilemap_height)
	self.camera:set_center(new_center_x, new_center_y)
end

-- function tilemap_view.resize_on_spot(self, width, height)
-- 	self.width = width
-- 	self.height = height

-- 	local tile_width = #self.tilemap.matrix[1]
-- 	local tile_height = #self.tilemap.matrix

-- 	local old_tilesize = self.tilesize
-- 	self.tilesize = _calculate_tilesize(width, height, tile_width, tile_height)

-- 	local tilemap_width = self.tilesize * tile_width
-- 	local tilemap_height = self.tilesize * tile_height

-- 	local old_camera_center_x, old_camera_center_y = self.camera:get_center()
-- 	local old_camera_cell_x, old_camera_cell_y = qpd_grid.point_to_cell(old_camera_center_x, old_camera_center_y, old_tilesize)
-- 	local new_camera_center_x, new_camera_center_y = qpd_grid.cell_to_center_point(old_camera_cell_x, old_camera_cell_y, self.tilesize)
-- 	self.camera:reset(tilemap_width, tilemap_height)
-- 	self.camera:set_center(new_camera_center_x, new_camera_center_y)
-- end

return tilemap_view