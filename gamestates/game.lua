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
local Tripod = require "entities.Tripod"
local grid = require "qpd.grid"

local color = require "qpd.color"
local color_cell = require "qpd.cells.color_cell"
local sprite_cell = require "qpd.cells.sprite_cell"

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
    local player_speed = 75
    local tripod_speed = 50
    local default_zoom = 3
    local n_tripods = 10

    gs.scale_speed = 0.1
    
    gs.fps = fps.new()
    
    gs.width = love.graphics.getWidth()
    gs.height = love.graphics.getHeight()

    -- read map file
    local map_file_path = map_file_path or files.map_1
    gs.map_matrix = utils.matrix_read_from_file(map_file_path, ',')
    
    -- create a cell_set
    local cell_set = {}
    -- initiate cell_set
    for index, value in ipairs(color_array) do
        cell_set[index] = color_cell.new(value)
    end
    -- add sprites
    local brick_sprite = love.graphics.newImage(files.spr_brick)
    cell_set[#cell_set+1] = sprite_cell.new(brick_sprite)

    -- create the on_screen tilemap_view    
    gs.tilemap_view = tilemap_view.new(gs.map_matrix, cell_set, gs.width, gs.height)
    
    -- set camera zoom
    gs.tilemap_view.camera:set_scale(default_zoom)

    -- create grid
    local collisions = {}
    for i = 1, #cell_set, 1 do
        collisions[i] = true
    end
    local grid = grid.new(gs.map_matrix, collisions)

    -- create player
    local x, y = gs.tilemap_view.camera:get_center()
    local spr_player = love.graphics.newImage(files.spr_him)
    gs.player = Player.new(x, y, spr_player, grid, gs.tilemap_view.tilesize, player_speed)

    -- create a Tripods
    local spr_tripod = love.graphics.newImage(files.spr_tripod)
    tripods = {}    
    for i=1, n_tripods, 1 do
        local new_start = grid:get_valid_pos()
        local this_x, this_y = utils.grid_to_center_point(new_start.x, new_start.y, gs.tilemap_view.tilesize)
        local new_target = grid:get_valid_pos()
        tripods[i] = Tripod.new(this_x, this_y, spr_tripod, grid, gs.tilemap_view.tilesize, gs.tilemap_view.tilesize, new_target, tripod_speed)
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
            gs.player:draw()
            for _, item in ipairs(tripods) do
                item:draw()
            end
        end)
    gs.fps:draw()
end

function gs.update(dt)    
    if love.keyboard.isDown(keymap.keys.zoom_in) then
        gs.tilemap_view:zoom_in(gs.scale_speed*dt)       
    elseif love.keyboard.isDown(keymap.keys.zoom_out) then
        gs.tilemap_view:zoom_out(gs.scale_speed*dt)
    end

    -- center camera
    gs.tilemap_view.camera:set_center(gs.player:get_center())

    for _, item in ipairs(tripods) do
        item:update(dt, gs.player, gs.tilemap_view.tilesize)
    end

    gs.player:update(dt, gs.tilemap_view.tilesize)
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