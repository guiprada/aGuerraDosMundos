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

local function tilesize(w, h, n_tiles_w, n_tiles_h)
    local map_ratio = n_tiles_w/n_tiles_h
    local screen_ratio = w/h

    if map_ratio > screen_ratio then -- wider, limited by width
        return w/n_tiles_w
    else -- taller, limited by height
        return h/n_tiles_h
    end    
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

    -- save old line width and set it to 5
    gs.old_line_width = love.graphics.getLineWidth()
    love.graphics.setLineWidth(5)

    gs.fps = fps.new()
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- read map file
    local map_file_path = map_file_path or files.map_1
    gs.map_matrix = utils.matrix_read_from_file(map_file_path, ',')

    -- calculate the on_screen tilesize, add 1 to tiles height for sprite_box
    local tilesize = tilesize(w, h, #gs.map_matrix[1], #gs.map_matrix + 1)
    
    -- camera
    local tilemap_width = tilesize * #gs.map_matrix[1]
    local tilemap_height = tilesize * #gs.map_matrix

    gs.camera = camera.new(tilemap_width, tilemap_height, 1, 3)
    gs.camera:set_viewport(0, 0, w, h - tilesize)

    -- create a cell_set
    gs.cell_set = {}
    for index, value in ipairs(color_array) do
        gs.cell_set[index] = color_cell.new(value)
    end
    -- add sprites
    local brick_sprite = love.graphics.newImage(files.spr_brick)
    gs.cell_set[#gs.cell_set+1] = sprite_cell.new(brick_sprite)

    -- offsets
    local offset_x = (w - tilemap_width)/2
    local offset_y = (h - tilesize - tilemap_height)/2

    -- create map
    gs.tilemap = tilemap.new(   offset_x,
                                offset_y,
                                tilesize,
                                gs.map_matrix,
                                gs.cell_set)
    
    -- sprite_box
    gs.sprite_box = cell_box.new( 0,
                                h - tilesize,
                                w/2,
                                tilesize,
                                gs.cell_set)

    -- selector for tilemap cell
    gs.selector = grid_selector.new(offset_x,
                                    offset_y,
                                    1,
                                    1,
                                    #gs.map_matrix[1],
                                    #gs.map_matrix,
                                    tilesize)

    -- define keyboard actions
    gs.actions_keydown = {}
    gs.actions_keydown[keymap.keys.exit] =
        function ()
            gamestate.switch("menu")
        end
    gs.actions_keydown[keymap.keys.up] = function () gs.selector:up() end
    gs.actions_keydown[keymap.keys.down] = function () gs.selector:down() end
    gs.actions_keydown[keymap.keys.left] = function () gs.selector:left() end
    gs.actions_keydown[keymap.keys.right] = function () gs.selector:right() end

    gs.actions_keydown[keymap.keys.action] =
        function ()
            change_grid(gs.sprite_box:get_selected())
        end

    gs.actions_keydown[keymap.keys.next_sprite] = function () gs.sprite_box:right() end
    gs.actions_keydown[keymap.keys.previous_sprite] = function () gs.sprite_box:left() end


    gs.actions_keydown[keymap.keys.save] =  
        function ()
            gs.tilemap:save(
                map_file_path)
        end
end

function gs.draw()
    gs.camera:draw( 
        function ()
            gs.tilemap:draw()
            gs.selector:draw()
            
        end)
    gs.fps:draw()

    gs.sprite_box:draw()
end

function gs.update(dt)    
    if love.keyboard.isDown(keymap.keys.zoom_in) then
        zoom_in()        
    elseif love.keyboard.isDown(keymap.keys.zoom_out) then
        zoom_out()
    end

    -- camera panning
    local move_speed_x = 0
    local move_speed_y = 0

    if love.keyboard.isDown(keymap.keys.pan_up) then
        move_speed_y = -1        
    elseif love.keyboard.isDown(keymap.keys.pan_down) then
        move_speed_y = 1        
    end
    if love.keyboard.isDown(keymap.keys.pan_left) then
        move_speed_x = -1
    elseif love.keyboard.isDown(keymap.keys.pan_right) then
        move_speed_x = 1
    end
    move_speed_x, move_speed_y = utils.normalize(move_speed_x, move_speed_y)
    gs.camera:move( move_speed_x*gs.camera_speed*dt,
                    move_speed_y*gs.camera_speed*dt)
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
end

function gs.unload()
    love.graphics.setLineWidth(gs.old_line_width)

    -- the callbacks are saved by the gamestate
    gs = {}    
end

return gs