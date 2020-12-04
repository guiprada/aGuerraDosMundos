local gs = {}

local gamestate = require "qpd.gamestate"

local text_box = require "qpd.widgets.text_box"
local selection_box = require "qpd.widgets.selection_box"
local particle = require "qpd.widgets.particle"

local color = require "qpd.color"

local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"
local files = require "qpd.services.files"
local strings = require "qpd.services.strings"

local utils = require "qpd.utils"

local N_PARTICLES = 250

--------------------------------------------------------------------------------

local function quit()
    love.event.quit(0)
end

--------------------------------------------------------------------------------

function gs.load()
    gs.width = love.graphics.getWidth()
    gs.height = love.graphics.getHeight()

    gs.sprites = {}

    local colors = utils.table_read_from_conf(files.available_colors)
    for _, color in ipairs(colors) do
        table.insert(gs.sprites, love.graphics.newImage(files["spr_" .. color]))
    end
    
    local spacing = gs.width / (#gs.sprites + 1)
    local sprite_height = gs.height / 5
    local rot_step = 2*math.pi/#gs.sprites
    gs.positions = {}    
    gs.offsets = {}
    for key, value in ipairs(gs.sprites) do        
        local new_position = { x = spacing * (key), y = sprite_height}
        gs.positions[key] = new_position        
        gs.offsets[key] = {x = gs.sprites[key]:getWidth()/2, y = gs.sprites[key]:getHeight()/2}
    end

    gs.spr_tripod = love.graphics.newImage(files.spr_tripod)
    gs.tripod_start_pos = {x = 2*gs.width/10, y = 5*gs.height/8}
    gs.tripod_pos = utils.table_clone(gs.tripod_start_pos)
    gs.tripod_rot = -math.pi/2
    gs.tripod_offset = {
        x = gs.spr_tripod:getWidth()/2,
        y = gs.spr_tripod:getHeight()/2
    }
    gs.tripod_position_step = gs.height/16
    gs.tripod_speed = 120
    
    --gs.sprites[#gs.sprites + 1] = love.graphics.newImage(files.spr_apple)

    gs.title = text_box.new(
        strings.title,
        "huge",
        0,
        2*gs.height/4,
        gs.width,
        "center",
        color.green)

    gs.menu = selection_box.new(
        "regular",
        0,
        gs.height*3/4,
        gs.width,
        "center",
        color.yellow,
        color.red)

    gs.menu:add_selection(
        strings.menu_start,
        function ()
            gamestate.switch("game")
        end)

    gs.menu:add_selection(
        strings.menu_settings,
        function ()
            gamestate.switch("settings_menu")
        end)

    gs.menu:add_selection(
        strings.menu_tilemap_editor, 
        function ()
            gamestate.switch( "tilemap_editor")
        end)

    gs.menu:add_selection(strings.menu_exit, quit)   

    gs.actions = {}
    -- action to key functions
    gs.actions[keymap.keys.select] = function () gs.menu:select() end
    gs.actions[keymap.keys.up] = 
        function ()
            gs.menu:up()            
        end
    gs.actions[keymap.keys.down] = 
        function ()
            gs.menu:down()            
        end
    gs.actions[keymap.keys.exit] = quit

    local particle_settings = {}
    particle_settings.max_duration = 2
    particle_settings.min_duration = 0.6
    particle_settings.max_size = 5

    gs.particles = {}
    for i=1,N_PARTICLES,1 do
        gs.particles[i] = particle.new(particle_settings)
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
            1,
            1,
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
            1,
            1,
            gs.offsets[key].x,
            gs.offsets[key].y)
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
    if love.keyboard.isDown(keymap.keys.left) and not love.keyboard.isDown(keymap.keys.right) then
        gs.tripod_pos.x = utils.clamp(gs.tripod_pos.x - gs.tripod_speed * dt, 0, gs.width)
    elseif not love.keyboard.isDown(keymap.keys.left) and love.keyboard.isDown(keymap.keys.right) then
        gs.tripod_pos.x = utils.clamp(gs.tripod_pos.x + gs.tripod_speed * dt, 0, gs.width)
    end
end

function gs.keyreleased(key, scancode)
    local func = gs.actions[key]
    if func then
        func()
    end
end

function gs.resize(w, h)
    fonts.resize(w, h)
    gs.title:resize(0, h/4, w)
    gs.menu:resize(0, h*3/4, w)
    for i=1,N_PARTICLES,1 do
        gs.particles[i].spawn_rect = {
            x = 0,
            y = 0,
            width = w,
            height = h }
    end

end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs
