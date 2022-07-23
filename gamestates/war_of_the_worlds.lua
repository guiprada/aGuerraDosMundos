local gs = {}

local qpd = require "qpd.qpd"

local Player = require "entities.Player"
local Friend = require "entities.Friend"
local Tripod = require "entities.Tripod"
local Collectable = require "entities.Collectable"

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
	local war_of_the_worlds_conf = qpd.table.read_from_conf(qpd.files.war_of_the_worlds_conf)
	local games_conf = qpd.table.read_from_conf(qpd.files.games_conf)
	local game_conf = {}
	if war_of_the_worlds_conf and games_conf then
		qpd.table.merge(game_conf, war_of_the_worlds_conf)
		qpd.table.merge(game_conf, games_conf)
	end
	if not game_conf then
		print("Failed to read game.conf")
	else
		local difficulty_factor = game_conf.difficulty/3

		local player_speed_factor = game_conf.player_speed_factor
		local tripod_speed_factor = game_conf.tripod_speed_factor
		local friend_speed_factor = game_conf.friend_speed_factor

		local friend_min_distance = game_conf.friend_min_distance
		local friend_max_distance = game_conf.friend_max_distance
		local tripod_speed_boost = game_conf.tripod_speed_boost
		local tripod_vision_dist_factor = game_conf.tripod_vision_dist_factor
		local tripod_vision_angle = game_conf.tripod_vision_angle
		local tripod_min_path = game_conf.tripod_min_path
		local tripod_min_distance = game_conf.tripod_min_distance
		local n_tripods = game_conf.n_tripods * difficulty_factor
		local disable_collision_duration = game_conf.disable_collision_duration
		local n_apples = game_conf.n_apples / difficulty_factor
		local apple_reactivation_time = game_conf.apple_reactivation_time

		gs.damage_points = game_conf.damage_points
		gs.player_health_max = game_conf.player_health_max
		gs.default_zoom = game_conf.default_zoom

		-- paused
		gs.paused_text = qpd.text_box.new(
			qpd.strings.paused,
			"huge",
			0,
			2*gs.height/4,
			gs.width,
			"center",
			qpd.color.red)

		-- load sprites
		local player_sprite_index = 'spr_' .. game_conf.player_color
		local spr_player = love.graphics.newImage(qpd.files[player_sprite_index])
		local friend_sprite_index = 'spr_' .. game_conf.friend_color
		local spr_friend = love.graphics.newImage(qpd.files[friend_sprite_index])

		local spr_tripod = love.graphics.newImage(qpd.files.spr_tripod)
		local spr_apple = love.graphics.newImage(qpd.files.spr_apple)

		gs.fps = qpd.fps.new()

		-- read map file
		local map_file_path = map_file_path or qpd.files.map_war_of_the_words
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
		gs.brick_index = #gs.cell_set
		gs.cell_set[#gs.cell_set+1] = gs.cell_set[gs.brick_index]
		gs.door_index = #gs.cell_set
		gs.open_door_index = 9 -- green color

		-- create the on_screen tilemap_view
		gs.tilemap_view = qpd.tilemap_view.new(gs.map_matrix, gs.cell_set, gs.width, gs.height)

		-- set camera zoom
		gs.tilemap_view.camera:set_scale(gs.default_zoom)

		-- create grid
		local collisions = {}
		for i = 1, #gs.cell_set, 1 do
			collisions[i] = true
		end
		local grid = qpd.grid.new(gs.map_matrix, collisions)

		-- create player
		local x, y = gs.tilemap_view.camera:get_center()
		x, y = grid.point_to_cell(x, y, gs.tilemap_view.tilesize)
		x, y = grid.cell_to_center_point(x, y, gs.tilemap_view.tilesize)
		gs.player = Player.new(x,
			y,
			spr_player,
			grid,
			1,
			gs.tilemap_view.tilesize,
			player_speed_factor,
			gs.player_health_max)

		-- create player collision timer
		gs.player_collision_enabled = true
		local enable_player_collision = function() gs.player_collision_enabled = true print("collision enable") end
		gs.player_collision_timer = qpd.timer.new(disable_collision_duration, enable_player_collision)

		-- create friend
		local friend_start_cell = grid:get_valid_cell()
		local friend_player_distance = qpd.point.distance2(gs.player._cell, friend_start_cell)
		while   friend_player_distance < friend_min_distance or
				friend_player_distance > friend_max_distance do
			friend_start_cell = grid:get_valid_cell()
			friend_player_distance = qpd.point.distance2(gs.player._cell, friend_start_cell)
		end
		gs.friend = Friend.new(friend_start_cell.x,
			friend_start_cell.y,
			spr_friend,
			grid,
			1,
			gs.player,
			gs.tilemap_view.tilesize,
			friend_speed_factor,
			gs.player_health_max)
		-- create friend collision timer
		gs.friend_collision_enabled = true
		local enable_friend_collision = function() gs.friend_collision_enabled = true end
		gs.friend_collision_timer = qpd.timer.new(disable_collision_duration, enable_friend_collision)

		-- create a Tripods
		gs.tripods = {}
		for i=1, n_tripods, 1 do
			local new_start = grid:get_valid_cell()
			while qpd.point.distance2(gs.player._cell, new_start) < tripod_min_distance do
				new_start = grid:get_valid_cell()
			end
			local new_end = grid:get_valid_cell()
			while qpd.point.distance2(new_start, new_end) <= tripod_min_path  do
				new_end = grid:get_valid_cell()
			end
			gs.tripods[i] = Tripod.new(new_start,
				new_end,
				spr_tripod,
				grid,
				1,
				gs.tilemap_view.tilesize,
				tripod_speed_factor,
				tripod_speed_boost,
				tripod_vision_dist_factor*gs.tilemap_view.tilesize,
				tripod_vision_angle)
		end

		-- create targets
		gs.targets = {}
		gs.targets[1] = gs.player
		gs.targets[2] = gs.friend

		-- create collectables
		gs.collectables = {}
		-- add apples
		for i=1, n_apples, 1 do
			local new_start = grid:get_valid_cell()
			local new_apple = Collectable.new(new_start,
				spr_apple,
				1,
				gs.tilemap_view.tilesize,
				"health",
				gs.damage_points,
				apple_reactivation_time)
			table.insert(gs.collectables, new_apple)
		end

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
			gs.friend:draw(gs.friend_collision_enabled)
			for _, item in ipairs(gs.collectables) do
				item:draw()
			end
			gs.player:draw(gs.player_collision_enabled)
			for _, item in ipairs(gs.tripods) do
				item:draw()
			end
		end)
	gs.fps:draw()
	if gs.paused then
		gs.paused_text:draw()

	end
end

function gs.update(dt)
	-- center camera
	gs.tilemap_view:follow(dt, gs.player.speed_factor, gs.player:get_center())

	if not gs.paused then
		gs.player:update(dt, gs.tilemap_view.tilesize)
		gs.friend:update(dt, gs.tilemap_view.tilesize)

		-- open door and activate friend chase
		if gs.friend._is_active then
			gs.targets[2] = gs.friend
			gs.cell_set[gs.door_index] = gs.cell_set[gs.open_door_index]
		else
			gs.targets[2] = nil
			gs.cell_set[gs.door_index] = gs.cell_set[gs.brick_index]
		end

		--  enemy update and check collision with player
		for _, tripod in ipairs(gs.tripods) do
			tripod:update(dt, gs.targets, gs.tilemap_view.tilesize)

			if gs.player_collision_enabled then
				if qpd.collision.check_circle(tripod.x, tripod.y, tripod._size/2, gs.player.x, gs.player.y, gs.player._size/2) then
					gs.player:take_health(gs.damage_points)
					gs.player_collision_enabled = false
					gs.player_collision_timer:reset()
				end
			end
			if gs.friend_collision_enabled and gs.friend._is_active then
				if qpd.collision.check_circle(tripod.x, tripod.y, tripod._size/2, gs.friend.x, gs.friend.y, gs.friend._size/2) then
					gs.friend:take_health(gs.damage_points)
					gs.friend_collision_enabled = false
					gs.friend_collision_timer:reset()
				end
			end
		end

		-- timers
		gs.player_collision_timer:update(dt)
		gs.friend_collision_timer:update(dt)

		-- collectables
		if  gs.player.health < gs.player_health_max or gs.friend.health < gs.player_health_max then
			for _, item in ipairs(gs.collectables) do
				item:update(dt)
				if item:is_enabled() and qpd.collision.check_circle(item.x, item.y, item._size/2, gs.player.x, gs.player.y, gs.player._size/2) then
					gs.player.health = qpd.value.clamp((gs.player.health + gs.damage_points), 0, gs.player_health_max)
					gs.friend.health = qpd.value.clamp((gs.friend.health + gs.damage_points), 0, gs.player_health_max)
					item:disable()
				end
			end
		end

		-- check win or loose
		if gs.player.health <=0 or gs.friend.health <= 0 then
			qpd.gamestate.switch("message", "gameover", "war_of_the_worlds")
		elseif gs.friend._is_active and
			(gs.player._cell.x < 3 or
			gs.player._cell.x > (gs.tilemap_view.tilemap.tile_width -2) or
			gs.player._cell.y < 3 or
			gs.player._cell.y > (gs.tilemap_view.tilemap.tile_height -2) ) then
			qpd.gamestate.switch("message", "victory", "war_of_the_worlds")
		end
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

	gs.player:resize(gs.tilemap_view.tilesize)
	gs.friend:resize(gs.tilemap_view.tilesize)
	for _, item in ipairs(gs.tripods) do
		item:resize(gs.tilemap_view.tilesize)
	end
	for _, item in ipairs(gs.collectables) do
		item:resize(gs.tilemap_view.tilesize)
	end
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs