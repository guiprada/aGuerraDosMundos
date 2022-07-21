local gs = {}

local qpd = require "qpd.qpd"

local GeneticPopulation = require "entities.GeneticPopulation"
local AutoPlayer = require "entities.AutoPlayer"

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
	gs.width = love.graphics.getWidth()
	gs.height = love.graphics.getHeight()
	gs.paused = false

	-- load game.conf settings
	local game_conf = qpd.table.read_from_conf(qpd.files.game_conf)
	if not game_conf then
		print("Failed to read game.conf")
	else
		gs.default_zoom = game_conf.default_zoom
		-- local difficulty_factor = game_conf.difficulty/3

		gs.fps = qpd.fps.new()

		-- paused
		gs.paused_text = qpd.text_box.new(
			qpd.strings.paused,
			"huge",
			0,
			2*gs.height/4,
			gs.width,
			"center",
			qpd.color.red)

		-- read map file
		local map_file_path = qpd.files.map_extinction
		gs.map_matrix = qpd.matrix.read_from_file(map_file_path, ',')

		-- create a gs.cell_set
		gs.cell_set = {}
		-- initiate gs.cell_set
		for index, value in ipairs(color_array) do
			gs.cell_set[index] = qpd.cell_color.new(value)
		end

		-- add sprites
		local brick_sprite = love.graphics.newImage(qpd.files.spr_brick)
		gs.cell_set[#gs.cell_set+1] = qpd.cell_sprite.new(brick_sprite)
		gs.cell_set[#gs.cell_set+1] = gs.cell_set[#gs.cell_set]

		-- create the on_screen tilemap_view
		gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, gs.cell_set, gs.width, gs.height)

		-- set camera zoom
		-- gs.qpd.tilemap_view.camera:set_scale(gs.default_zoom)

		-- create grid
		local collisions = {}
		collisions[0] = false
		for i = 1, #gs.cell_set, 1 do
			collisions[i] = true
		end
		gs.grid = qpd.grid.new(gs.map_matrix, collisions)

		-- Initialize Ghosts
		gs.ghost_states = {"scattering", "chasing", "frightened"}

		-- Initalize Autoplayer
		local AutoPlayer_search_path_length = 5
		gs.AutoPlayer_speed = 1000
		AutoPlayer.init(gs.grid, AutoPlayer_search_path_length)
		gs.AutoPlayerPopulation = GeneticPopulation:new(AutoPlayer, 50, 100000, nil, {speed = gs.AutoPlayer_speed}, gs.tilemap_view.tilesize)


		-- max dt
		gs.max_dt = (gs.tilemap_view.tilesize / 4) / qpd.value.max(gs.AutoPlayer_speed)

		-- define keyboard actions
		gs.actions_keyup = {}
		gs.actions_keyup[qpd.keymap.keys.exit] =
			function ()
				qpd.gamestate.switch("menu")
			end

		gs.actions_keyup[qpd.keymap.keys.pause] =
			function ()
				if gs.paused then
					gs.paused = false
				else
					gs.paused = true
				end
			end
	end
end

function gs.draw()
	gs.tilemap_view.camera:draw(
		function ()
			gs.tilemap_view:draw()
			gs.AutoPlayerPopulation:draw()
		end)
	gs.fps:draw()
	love.graphics.print(
		gs.AutoPlayerPopulation:get_count(),
		200,
		0)
	if gs.paused then
		gs.paused_text:draw()
	end
end

function gs.update(dt)
	-- center camera
	-- gs.tilemap_view:follow(dt, gs.player.speed_factor, gs.player:get_center())

	if not gs.paused then
		-- dt should not be to high
		local dt = dt < gs.max_dt and dt or gs.max_dt
		if (dt > gs.max_dt ) then
			print("ops, dt too high, physics wont work, skipping dt= " .. dt)
		end

		-- clear grid collisions
		gs.grid:clear_collisions()

		-- randomize ghost_state
		gs.ghost_state = qpd.random.choose_list(gs.ghost_states)
		gs.AutoPlayerPopulation:update(dt, gs.ghost_state)
	end
end

function gs.keypressed(key, scancode, isrepeat)
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

	gs.paused_text:resize(0, gs.height/2, gs.width)

	gs.tilemap_view:resize(gs.width, gs.height)

	gs.AutoPlayerPopulation:set_tilesize(gs.tilemap_view.tilesize)
	gs.max_dt = (gs.tilemap_view.tilesize / 4) / qpd.value.max(gs.AutoPlayer_speed)
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs