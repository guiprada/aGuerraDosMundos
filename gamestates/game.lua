local gs = {}

local gamestate = require "qpd.gamestate"

local utils = require "qpd.utils"

local files = require "qpd.services.files"
local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"
local camera = require "qpd.camera"
local color = require "qpd.color"

local fps = require "qpd.widgets.fps"
local tilemap = require "qpd.widgets.tilemap"
local grid_selector = require "qpd.widgets.grid_selector"
local cell_box = require "qpd.widgets.cell_box"

local color_cell = require "qpd.cells.color_cell"
local sprite_cell = require "qpd.cells.sprite_cell"

local Player = require "entities.Player"

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

local function calculate_tilesize(w, h, n_tiles_w, n_tiles_h)
    local map_ratio = n_tiles_w/n_tiles_h
    local screen_ratio = w/h

    if map_ratio > screen_ratio then -- wider, limited by width
        return w/n_tiles_w
    else -- taller, limited by height
        return h/n_tiles_h
    end    
end

local function set_map_view()
        --tile_height + 1 to acomodate cellbox
        gs.tilesize = calculate_tilesize(gs.width, gs.height, gs.tile_width, gs.tile_height + 1)

        -- camera
        local tilemap_width = gs.tilesize * gs.tile_width
        local tilemap_height = gs.tilesize * gs.tile_height
    
        gs.camera = camera.new(tilemap_width, tilemap_height, 1, 3)
        gs.camera:set_viewport(0, 0, gs.width, gs.height - gs.tilesize)
    
        -- create a cell_set
        gs.cell_set = {}
        for index, value in ipairs(color_array) do
            gs.cell_set[index] = color_cell.new(value, gs.tilesize)
        end
        -- add sprites
        local brick_sprite = love.graphics.newImage(files.spr_brick)
        gs.cell_set[#gs.cell_set+1] = sprite_cell.new(brick_sprite, gs.tilesize)
    
        -- offsets
        local offset_x = (gs.width - tilemap_width)/2
        local offset_y = (gs.height - gs.tilesize - tilemap_height)/2
    
        -- create map
        gs.tilemap = tilemap.new(   offset_x,
                                    offset_y,
                                    gs.tilesize,
                                    gs.map_matrix,
                                    gs.cell_set)
end

local function zoom_in()
    gs.camera:set_scale(gs.camera:get_scale() * gs.scale_speed)
end

local function zoom_out()
    gs.camera:set_scale(gs.camera:get_scale() / gs.scale_speed)
end

local function change_grid(new_val)
    gs.tilemap:change_grid(new_val, gs.selector.grid_x, gs.selector.grid_y)
end

--------------------------------------------------------------------------------

function gs.load(map_file_path)
    gs.camera_speed = 500
    gs.scale_speed = 1.01
    
    gs.fps = fps.new()
    
    gs.width = love.graphics.getWidth()
    gs.height = love.graphics.getHeight()

    -- read map file
    local map_file_path = map_file_path or files.map_1
    gs.map_matrix = utils.matrix_read_from_file(map_file_path, ',')

    -- calculate the on_screen view
    gs.tile_width = #gs.map_matrix[1]
    gs.tile_height = #gs.map_matrix 
    set_map_view()

    -- define keyboard actions
    gs.actions_keydown = {}
    gs.actions_keydown[keymap.keys.exit] =
        function ()
            gamestate.switch("menu")
        end

    local x, y = gs.camera:get_center()
    local spr_player = love.graphics.newImage(files.spr_him)
    gs.player = Player.new(x, y, spr_player, gs.tilesize, 150)
end

function gs.draw()
    gs.camera:draw( 
        function ()
            gs.tilemap:draw()
            gs.player:draw()
        end)
    gs.fps:draw()
end

function gs.update(dt)    
    if love.keyboard.isDown(keymap.keys.zoom_in) then
        zoom_in()        
    elseif love.keyboard.isDown(keymap.keys.zoom_out) then
        zoom_out()
    end

    gs.player:update(dt)
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
    set_map_view()
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}    
end

return gs