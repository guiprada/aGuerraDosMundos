local N_PARTICLES = 20000
local WORLD_WIDTH = 10000
local WORLD_HEIGHT = 10000

local gs = {}

local gamestate = require "qpd.gamestate"
local fps = require "qpd.widgets.fps"
local camera = require "qpd.camera"
local particle = require "qpd.widgets.particle"

local keymap = require "qpd.services.keymap"

--------------------------------------------------------------------------------

function gs.load(player)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    --fonts.resize(w, h)

    gs.fps = fps.new()

    gs.player = player

    gs.camera = camera.new(WORLD_WIDTH, WORLD_HEIGHT, 0.1, 5)

    gs.camera:set_viewport(w/4, h/4, w/2, h/2)

    gs.particles = {}
    local particle_settings = {}
    particle_settings.spawn_rect = {
        x = 0,
        y = 0,
        width = WORLD_WIDTH,
        height = WORLD_HEIGHT}

    particle_settings.max_duration = 2
    particle_settings.min_duration = 0.6
    particle_settings.max_size = 50

    for i=1,N_PARTICLES,1 do
        gs.particles[i] = particle.new(particle_settings)
    end


end

function gs.draw()
    gs.fps:draw()
    gs.camera:draw( 
        function ()        
            for i=1,N_PARTICLES,1 do
                gs.particles[i]:draw()
            end
        end)
end

function gs.update(dt)
    for i=1,N_PARTICLES,1 do
        gs.particles[i]:update(dt)
    end
end

function gs.keypressed(key, scancode, isrepeat)
    if key == keymap.keys.zoom_in then
        gs.camera:set_scale(gs.camera:get_scale() * 1.1)
        --gs.player:moving_left()
    elseif key == keymap.keys.zoom_out then
        gs.camera:set_scale(gs.camera:get_scale() / 1.1)
    end
end

function gs.keyreleased(key, scancode)
    if key == keymap.keys.exit then
        gamestate.switch("menu", gs.player)
    end
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs
