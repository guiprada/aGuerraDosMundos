local gs = {}

local qpd = require "qpd.qpd"

local N_PARTICLES = 250

--------------------------------------------------------------------------------
local function quit()
	love.event.quit(0)
end

local function sprites_dimension()
	gs.sprite_scale = qpd.value.min(gs.width, gs.height)/((#gs.sprites + 1)*gs.sprites[1]:getWidth())
	local spacing = gs.width / (#gs.sprites + 1)
	local sprite_height = gs.height / 5
	for key, _ in ipairs(gs.sprites) do
		gs.positions[key].x = spacing * (key)
		gs.positions[key].y = sprite_height
	end

	gs.tripod_start_pos.x = 2*gs.width/10
	gs.tripod_start_pos.y = 5*gs.height/8

	gs.tripod_pos.x = gs.tripod_start_pos.x

	gs.tripod_position_step = gs.height/16
	gs.tripod_speed = 120*(gs.width/1280)
end

--------------------------------------------------------------------------------
function gs.load()
	gs.width = love.graphics.getWidth()
	gs.height = love.graphics.getHeight()

	gs.sprites = {}

	local colors = qpd.table.read_from_conf(qpd.files.available_colors)
	for _, color in ipairs(colors) do
		table.insert(gs.sprites, love.graphics.newImage(qpd.files["spr_" .. color]))
	end

	gs.offset = {x = gs.sprites[1]:getWidth()/2, y = gs.sprites[1]:getHeight()/2}
	gs.positions = {}
	for key, value in ipairs(gs.sprites) do
		local new_position = {}
		gs.positions[key] = new_position
	end

	gs.spr_tripod = love.graphics.newImage(qpd.files.spr_tripod)
	gs.tripod_start_pos = {}
	gs.tripod_pos = {}
	gs.tripod_rot = -math.pi/2
	gs.tripod_offset = {
		x = gs.spr_tripod:getWidth()/2,
		y = gs.spr_tripod:getHeight()/2
	}

	--gs.sprites[#gs.sprites + 1] = love.graphics.newImage(files.spr_apple)

	sprites_dimension()

	gs.title = qpd.text_box.new(
		qpd.strings.title,
		"huge",
		0,
		2*gs.height/4,
		gs.width,
		"center",
		qpd.color.green)

	gs.menu = qpd.selection_box.new(
		"regular",
		0,
		gs.height*3/4,
		gs.width,
		"center",
		qpd.color.yellow,
		qpd.color.red)

	gs.menu:add_selection(
		qpd.strings.menu_extinction,
		function ()
			qpd.gamestate.switch("extinction")
		end)

	gs.menu:add_selection(
		qpd.strings.menu_war_of_the_worlds,
		function ()
			qpd.gamestate.switch("war_of_the_worlds")
		end)

	gs.menu:add_selection(
		qpd.strings.menu_settings,
		function ()
			qpd.gamestate.switch("settings_menu")
		end)

	gs.menu:add_selection(
		qpd.strings.menu_tilemap_editor,
		function ()
			qpd.gamestate.switch( "tilemap_editor")
		end)

	gs.menu:add_selection(
		qpd.strings.menu_how_to_play,
		function ()
			qpd.gamestate.switch("message", "how_to_play", "menu")
		end)

	gs.menu:add_selection(qpd.strings.menu_exit, quit)

	gs.actions = {}
	-- action to key functions
	gs.actions[qpd.keymap.keys.select] = function () gs.menu:select() end
	gs.actions[qpd.keymap.keys.up] =
		function ()
			gs.menu:up()
		end
	gs.actions[qpd.keymap.keys.down] =
		function ()
			gs.menu:down()
		end
	gs.actions[qpd.keymap.keys.exit] = quit

	local particle_settings = {}
	particle_settings.max_duration = 2
	particle_settings.min_duration = 0.6
	particle_settings.max_size = 5

	gs.particles = {}
	for i=1,N_PARTICLES,1 do
		gs.particles[i] = qpd.particle.new(particle_settings)
	end
end

function gs.draw()
	--particles
	for i=1,N_PARTICLES,1 do
		gs.particles[i]:draw()
	end

	gs.tripod_pos.y = gs.tripod_start_pos.y + gs.menu:get_selected() * gs.tripod_position_step
	love.graphics.draw(
			gs.spr_tripod,
			gs.tripod_pos.x,
			gs.tripod_pos.y,
			gs.tripod_rot,
			gs.sprite_scale,
			gs.sprite_scale,
			gs.tripod_offset.x,
			gs.tripod_offset.y)


	for key, item in ipairs(gs.sprites) do
		-- calculate rot to look to tripod
		local this_rot = math.atan2(
			gs.tripod_pos.y - gs.positions[key].y,
			gs.tripod_pos.x - gs.positions[key].x
		)
		love.graphics.draw(
			item,
			gs.positions[key].x,
			gs.positions[key].y,
			this_rot,
			gs.sprite_scale,
			gs.sprite_scale,
			gs.offset.x,
			gs.offset.y)
	end

	--title
	gs.title:draw()
	--text
	gs.menu:draw()
end

function gs.update(dt)
	for i=1,N_PARTICLES,1 do
		gs.particles[i]:update(dt)
	end
	if love.keyboard.isDown(qpd.keymap.keys.left) and not love.keyboard.isDown(qpd.keymap.keys.right) then
		gs.tripod_pos.x = qpd.value.clamp(gs.tripod_pos.x - gs.tripod_speed * dt, 0, gs.width)
	elseif not love.keyboard.isDown(qpd.keymap.keys.left) and love.keyboard.isDown(qpd.keymap.keys.right) then
		gs.tripod_pos.x = qpd.value.clamp(gs.tripod_pos.x + gs.tripod_speed * dt, 0, gs.width)
	end
end

function gs.keyreleased(key, scancode)
	local func = gs.actions[key]
	if func then
		func()
	end
end

function gs.resize(w, h)
	gs.width = w
	gs.height = h
	qpd.fonts.resize(w, h)
	gs.title:resize(0, h/2, w)
	gs.menu:resize(0, h*3/4, w)
	for i=1,N_PARTICLES,1 do
		gs.particles[i].spawn_rect = {
			x = 0,
			y = 0,
			width = w,
			height = h }
	end
	sprites_dimension()
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs
