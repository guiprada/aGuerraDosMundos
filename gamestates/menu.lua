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

local N_PARTICLES = 250

--------------------------------------------------------------------------------

local function quit()
    love.event.quit(0)
end

--------------------------------------------------------------------------------

function gs.load(this_player)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    --fonts.resize(w, h)

    gs.player = this_player or {}

    gs.title = text_box.new(
        strings.title,
        "huge",
        0,
        h/4,
        w,
        "center",
        color.green)

    gs.menu = selection_box.new(
        "regular",
        0,
        h*3/4,
        w,
        "center",
        color.gray,
        color.red)

    gs.menu:add_selection(
        strings.menu_start,
        function ()
            gamestate.switch("game", gs.player)
        end)

    gs.menu:add_selection(
        strings.menu_settings,
        function ()
            gamestate.switch("settings_menu", gs.player)
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
    gs.actions[keymap.keys.up] = function () gs.menu:up()  end
    gs.actions[keymap.keys.down] = function () gs.menu:down()  end
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

    --title
    gs.title:draw()
    --text
    gs.menu:draw()
end

function gs.update(dt)
    for i=1,N_PARTICLES,1 do
        gs.particles[i]:update(dt)
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
