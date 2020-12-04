local gs = {}

local gamestate = require "qpd.gamestate"

local utils = require "qpd.utils"

local files = require "qpd.services.files"
local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"
local fps = require "qpd.widgets.fps"
local tilemap_view = require "qpd.tilemap_view"
local grid_selector = require "qpd.widgets.grid_selector"

local Player = require "entities.Player"
local Friend = require "entities.Friend"
local Tripod = require "entities.Tripod"
local Collectable = require "entities.Collectable"
local grid = require "qpd.grid"

local color = require "qpd.color"
local color_cell = require "qpd.cells.color_cell"
local sprite_cell = require "qpd.cells.sprite_cell"
local timer = require "qpd.timer"

--------------------------------------------------------------------------------

local color_array = {}
color_array[1] = color.gray
color_array[2] = color.pink
color_array[3] = color.red
color_array[4] = color.brown
color_array[5] = color.violet
color_array[6] = color.gold 
color_array[7] = color.darkblue
color_array[8] = color.skyblue
color_array[9] = color.green
color_array[10] = color.darkgreen
color_array[11] = color.purple
color_array[12] = color.darkpurple
color_array[13] = color.magenta
color_array[14] = color.beige
color_array[15] = color.orange
color_array[16] = color.lime

--------------------------------------------------------------------------------

function gs.load(map_file_path)
    print(files.game_conf)
    local game_conf = utils.table_read_from_conf(files.game_conf)
    local difficulty_factor = game_conf.difficulty/3

    local default_zoom = game_conf.default_zoom

    local player_speed = game_conf.player_speed
    local friend_speed_factor = game_conf.friend_speed_factor
    local friend_min_distance = game_conf.friend_min_distance
    local friend_max_distance = game_conf.friend_max_distance
    local tripod_speed = game_conf.tripod_speed
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

    local player_sprite_index = 'spr_' .. game_conf.player_color
    local spr_player = love.graphics.newImage(files[player_sprite_index])
    local friend_sprite_index = 'spr_' .. game_conf.friend_color
    local spr_friend = love.graphics.newImage(files[friend_sprite_index])

    local spr_tripod = love.graphics.newImage(files.spr_tripod)
    local spr_apple = love.graphics.newImage(files.spr_apple)

    gs.fps = fps.new()
    
    gs.width = love.graphics.getWidth()
    gs.height = love.graphics.getHeight()

    -- read map file
    local map_file_path = map_file_path or files.map_1
    gs.map_matrix = utils.matrix_read_from_file(map_file_path, ',')
    
    -- create a gs.cell_set
    gs.cell_set = {}
    -- initiate gs.cell_set
    for index, value in ipairs(color_array) do
        gs.cell_set[index] = color_cell.new(value)
    end
    -- add sprites
    local brick_sprite = love.graphics.newImage(files.spr_brick)
    gs.cell_set[#gs.cell_set+1] = sprite_cell.new(brick_sprite)
    gs.brick_index = #gs.cell_set
    gs.cell_set[#gs.cell_set+1] = gs.cell_set[gs.brick_index]
    gs.door_index = #gs.cell_set
    gs.open_door_index = 9 -- green color    

    -- create the on_screen tilemap_view    
    gs.tilemap_view = tilemap_view.new(gs.map_matrix, gs.cell_set, gs.width, gs.height)
    
    -- set camera zoom
    gs.tilemap_view.camera:set_scale(default_zoom)

    -- create grid
    local collisions = {}
    for i = 1, #gs.cell_set, 1 do
        collisions[i] = true
    end
    local grid = grid.new(gs.map_matrix, collisions)

    -- create player
    local x, y = gs.tilemap_view.camera:get_center()
    x, y = utils.point_to_grid(x, y, gs.tilemap_view.tilesize)
    x, y = utils.grid_to_center_point(x, y, gs.tilemap_view.tilesize)
    gs.player = Player.new(x,
        y,
        spr_player,
        grid,
        gs.tilemap_view.tilesize,
        gs.tilemap_view.tilesize,
        player_speed,
        gs.player_health_max)

    -- create player collision timer
    gs.player_collision_enabled = true
    local enable_player_collision = function() gs.player_collision_enabled = true end
    gs.player_collision_timer = timer.new(disable_collision_duration, enable_player_collision)
    --gs.player_collision_timer:reset()

    -- create friend
    local friend_start_cell = grid:get_valid_pos()
    local friend_player_distance = utils.distance(gs.player._cell, friend_start_cell)
    while   friend_player_distance < friend_min_distance or
            friend_player_distance > friend_max_distance do
        friend_start_cell = grid:get_valid_pos()
        friend_player_distance = utils.distance(gs.player._cell, friend_start_cell)
    end
    gs.friend = Friend.new(friend_start_cell.x,
        friend_start_cell.y,
        spr_friend,
        grid,
        gs.tilemap_view.tilesize,
        gs.player,
        gs.tilemap_view.tilesize,
        player_speed * friend_speed_factor,
        gs.player_health_max)
    -- create friend collision timer
    gs.friend_collision_enabled = true
    local enable_friend_collision = function() gs.friend_collision_enabled = true end
    gs.friend_collision_timer = timer.new(disable_collision_duration, enable_friend_collision)
    --gs.friend_collision_timer:reset()

    -- create a Tripods
    gs.tripods = {}
    for i=1, n_tripods, 1 do
        local new_start = grid:get_valid_pos()
        while utils.distance(gs.player._cell, new_start) < tripod_min_distance do
            new_start = grid:get_valid_pos()
        end
        local new_end = grid:get_valid_pos()
        while utils.distance(new_start, new_end) <= tripod_min_path  do
            new_end = grid:get_valid_pos()
        end
        gs.tripods[i] = Tripod.new(new_start,
            new_end,
            spr_tripod,
            grid,
            gs.tilemap_view.tilesize,
            gs.tilemap_view.tilesize,
            tripod_speed,
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
        local new_start = grid:get_valid_pos()
        local new_apple = Collectable.new(new_start,
            spr_apple,
            gs.tilemap_view.tilesize,
            gs.tilemap_view.tilesize,
            "health",
            gs.damage_points,
            apple_reactivation_time)
        table.insert(gs.collectables, new_apple)
    end

    -- define keyboard actions
    gs.actions_keydown = {}
    gs.actions_keydown[keymap.keys.exit] =
        function ()
            gamestate.switch("menu")
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
end

function gs.update(dt)    
    -- center camera
    gs.tilemap_view.camera:set_center(gs.player:get_center())
        
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
    for _, item in ipairs(gs.tripods) do
        item:update(dt, gs.targets, gs.tilemap_view.tilesize)
        
        if gs.player_collision_enabled then
            if utils.check_collision_circle(item.x, item.y, item._size/2, gs.player.x, gs.player.y, gs.player._size/2) then
                gs.player:take_health(gs.damage_points)
                gs.player_collision_enabled = false
                gs.player_collision_timer:reset()
            end
        end
        if gs.friend_collision_enabled and gs.friend._is_active then
            if utils.check_collision_circle(item.x, item.y, item._size/2, gs.friend.x, gs.friend.y, gs.friend._size/2) then
                gs.friend:take_health(gs.damage_points)
                gs.friend_collision_enabled = false
                gs.friend_collision_timer:reset()
            end
        end
    end
    gs.player_collision_timer:update(dt)
    gs.friend_collision_timer:update(dt)

    for _, item in ipairs(gs.collectables) do
        
    end

    -- collectables
    if  gs.player.health < gs.player_health_max or gs.friend.health < gs.player_health_max then
        for _, item in ipairs(gs.collectables) do
            item:update(dt)
            if item:is_enabled() and utils.check_collision_circle(item.x, item.y, item._size/2, gs.player.x, gs.player.y, gs.player._size/2) then
                gs.player.health = utils.clamp((gs.player.health + gs.damage_points), 0, gs.player_health_max)
                gs.friend.health = utils.clamp((gs.friend.health + gs.damage_points), 0, gs.player_health_max)
                item:disable()
            end            
        end
    end
    
    -- check win or loose
    if gs.player.health <=0 or gs.friend.health <= 0 then
        gamestate.switch("gameover")
    elseif gs.friend._is_active and 
        (gs.player._cell.x < 3 or
        gs.player._cell.x > (gs.tilemap_view.tilemap.tile_width -2) or
        gs.player._cell.y < 3 or
        gs.player._cell.y > (gs.tilemap_view.tilemap.tile_height -2) ) then
        gamestate.switch("victory")
    end
end

function gs.keypressed(key, scancode, isrepeat)
end

function gs.keyreleased(key, scancode)
    local func = gs.actions_keydown[key]

    if func then
        func()
    end
end

function gs.resize(w, h)
    fonts.resize(w, h)
    gs.width = w
    gs.height = h
    gs.tilemap_view = tilemap_view.new(gs.map_matrix, gs.tilemap_view.tilemap.draw_functions, gs.width, gs.height)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}    
end

return gs