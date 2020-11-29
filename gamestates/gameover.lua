local gs = {}

local gamestate = require "qpd.gamestate"

local text_box = require "qpd.widgets.text_box"

local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"
local strings = require "qpd.services.strings"
local color = require "qpd.color"


--------------------------------------------------------------------------------

local function quit()
    love.event.quit(0)
end

--------------------------------------------------------------------------------

function gs.load(this_player)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    gs.player = this_player or {}

    gs.text = text_box.new(
        strings.gameover,
        "huge",
        0,
        h/2,
        w,
        "center",
        color.red)

    
    gs.actions = {}
    -- action to key functions    
    gs.actions[keymap.keys.exit] = quit
    gs.actions[keymap.keys.select] = 
        function ()
            gamestate.switch("menu")
        end
    
end

function gs.draw()
    --text
    gs.text:draw()
end

function gs.update(dt)

end

function gs.keyreleased(key, scancode)
    local func = gs.actions[key]
    if func then
        func()
    end
end

function gs.resize(w, h)
    fonts.resize(w, h)
    gs.text:resize(0, h/2, w)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs