local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------
local color_array = {}
color_array[1] = qpd.color.gray
color_array[2] = qpd.color.pink
color_array[3] = qpd.color.red
color_array[4] = qpd.color.brown
color_array[5] = qpd.color.violet
color_array[6] = qpd.color.gold
color_array[7] = qpd.color.darkblue
color_array[8] = qpd.color.skyblue
color_array[9] = qpd.color.green
color_array[10] = qpd.color.darkgreen
color_array[11] = qpd.color.purple
color_array[12] = qpd.color.darkpurple
color_array[13] = qpd.color.magenta
color_array[14] = qpd.color.beige
color_array[15] = qpd.color.orange
color_array[16] = qpd.color.lime

--------------------------------------------------------------------------------
function gs.load(map_file_path)
	gs.scale_speed = 0.6

	-- save old line width and set it to 5
	gs.old_line_width = love.graphics.getLineWidth()
	love.graphics.setLineWidth(2)

	gs.width = love.graphics.getWidth()
	gs.height = love.graphics.getHeight()

	-- read map file
	local map_file_path = map_file_path or qpd.files.map_editing
	gs.map_matrix = qpd.matrix.read_from_file(map_file_path, ',')

	-- create a cell_set
	local cell_set = {}
	for index, value in ipairs(color_array) do
		cell_set[index] = qpd.cells.color.new(value)
	end
	-- add sprites
	local brick_sprite = love.graphics.newImage(qpd.files.spr_brick)
	cell_set[#cell_set+1] = qpd.cell_sprite.new(brick_sprite)
	cell_set[#cell_set+1] = cell_set[#cell_set]

	-- create the on_screen tilemap_view
	gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, cell_set, gs.width, gs.height)

	-- sprite_box
	gs.cell_box_size_factor = 3
	gs.sprite_box = qpd.cell_box.new( 0,
								gs.height - gs.tilemap_view.tilesize * gs.cell_box_size_factor,
								gs.width,
								gs.tilemap_view.tilesize * gs.cell_box_size_factor,
								cell_set)

	-- selector with logic to keep position on reset
	local grid_start_x, grid_start_y
	if gs.selector == nil then
		grid_start_x = math.ceil(gs.tilemap_view.tilemap.tile_width/2)
		grid_start_y = math.ceil(gs.tilemap_view.tilemap.tile_height/2)
	else
		grid_start_x = gs.selector.grid_x
		grid_start_y = gs.selector.grid_y
	end

	gs.selector = qpd.grid_selector.new(0,
									0,
									1,
									1,
									gs.tilemap_view.tilemap.tile_width,
									gs.tilemap_view.tilemap.tile_height,
									gs.tilemap_view.tilesize,
									nil,
									grid_start_x,
									grid_start_y)

	-- define keyboard actions
	gs.actions_keyup = {}
	gs.actions_keyup[qpd.keymap.keys.exit] =
		function ()
			qpd.gamestate.switch("menu")
		end
	gs.actions_keyup[qpd.keymap.keys.action] =
		function ()
			gs.tilemap_view.tilemap:change_matrix(gs.sprite_box:get_selected(), gs.selector.grid_x, gs.selector.grid_y)
		end

	gs.actions_keyup[qpd.keymap.keys.delete] =
		function ()
			gs.tilemap_view.tilemap:change_matrix(0, gs.selector.grid_x, gs.selector.grid_y)
		end

	gs.actions_keyup[qpd.keymap.keys.next_sprite] = function () gs.sprite_box:right() end
	gs.actions_keyup[qpd.keymap.keys.previous_sprite] = function () gs.sprite_box:left() end

	gs.actions_keyup[qpd.keymap.keys.add_top] =
		function ()
			gs.tilemap_view.tilemap:add_top()
			gs.selector:add_line()
			local zoom_level = gs.tilemap_view.camera:get_scale()
			gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, cell_set, gs.width, gs.height)
			gs.tilemap_view.camera:set_scale(zoom_level)
			gs.selector = qpd.grid_selector.new(0, 0, 1, 1, gs.tilemap_view.tilemap.tile_width, gs.tilemap_view.tilemap.tile_height, gs.tilemap_view.tilesize, nil,
				gs.selector.grid_x,
				gs.selector.grid_y+1)
		end
	gs.actions_keyup[qpd.keymap.keys.add_bottom] =
		function ()
			gs.tilemap_view.tilemap:add_bottom()
			gs.selector:add_line()
			local zoom_level = gs.tilemap_view.camera:get_scale()
			gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, cell_set, gs.width, gs.height)
			gs.tilemap_view.camera:set_scale(zoom_level)
			gs.selector = qpd.grid_selector.new(0, 0, 1, 1, gs.tilemap_view.tilemap.tile_width, gs.tilemap_view.tilemap.tile_height, gs.tilemap_view.tilesize, nil,
				gs.selector.grid_x,
				gs.selector.grid_y)
		end

	gs.actions_keyup[qpd.keymap.keys.add_right] =
		function ()
			gs.tilemap_view.tilemap:add_right()
			gs.selector:add_row()
			local zoom_level = gs.tilemap_view.camera:get_scale()
			gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, cell_set, gs.width, gs.height)
			gs.tilemap_view.camera:set_scale(zoom_level)
			gs.selector = qpd.grid_selector.new(0, 0, 1, 1, gs.tilemap_view.tilemap.tile_width, gs.tilemap_view.tilemap.tile_height, gs.tilemap_view.tilesize, nil,
				gs.selector.grid_x,
				gs.selector.grid_y)
		end

	gs.actions_keyup[qpd.keymap.keys.add_left] =
		function ()
			gs.tilemap_view.tilemap:add_left()
			gs.selector:add_row()
			local zoom_level = gs.tilemap_view.camera:get_scale()
			gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, cell_set, gs.width, gs.height)
			gs.tilemap_view.camera:set_scale(zoom_level)
			gs.selector = qpd.grid_selector.new(0, 0, 1, 1, gs.tilemap_view.tilemap.tile_width, gs.tilemap_view.tilemap.tile_height, gs.tilemap_view.tilesize, nil,
				gs.selector.grid_x+1,
				gs.selector.grid_y)
		end

	gs.actions_keyup[qpd.keymap.keys.save] =
		function ()
			gs.tilemap_view.tilemap:save(
				map_file_path)
		end

	gs.actions_keydown = {}
	gs.actions_keydown[qpd.keymap.keys.up] =
		function ()
			gs.selector:up()
		end
	gs.actions_keydown[qpd.keymap.keys.down] =
		function ()
			gs.selector:down()
		end
	gs.actions_keydown[qpd.keymap.keys.left] =
		function ()
			gs.selector:left()
		end
	gs.actions_keydown[qpd.keymap.keys.right] =
		function ()
			gs.selector:right()
		end
end

function gs.draw()
	gs.tilemap_view.camera:draw(
		function ()
			gs.tilemap_view:draw()
			gs.selector:draw()

		end)

	gs.sprite_box:draw()
end

function gs.update(dt)
	if love.keyboard.isDown(qpd.keymap.keys.zoom_in) then
		gs.tilemap_view:zoom_in(gs.scale_speed*dt)
	elseif love.keyboard.isDown(qpd.keymap.keys.zoom_out) then
		gs.tilemap_view:zoom_out(gs.scale_speed*dt)
	end

	-- center camera
	gs.tilemap_view.camera:set_center(gs.selector:get_center())
end

function gs.keypressed(key, scancode, isrepeat)
	local func = gs.actions_keydown[key]

	if func then
		func()
	end
end

function gs.keyreleased(key, scancode)
	local func = gs.actions_keyup[key]

	if func then
		func()
	end
end

function gs.resize(w, h)
	gs.width = w
	gs.height = h

	qpd.fonts.resize(gs.width, gs.height)

	gs.tilemap_view:resize(gs.width, gs.height)

	gs.sprite_box = qpd.cell_box.new( 0,
								gs.height - gs.tilemap_view.tilesize * gs.cell_box_size_factor,
								gs.width,
								gs.tilemap_view.tilesize * gs.cell_box_size_factor,
								gs.tilemap_view.tilemap.draw_functions)

end

function gs.unload()
	love.graphics.setLineWidth(gs.old_line_width)

	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs