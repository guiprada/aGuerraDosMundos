local gs = {}

local gamestate = require "qpd.gamestate"

local text_box = require "qpd.widgets.text_box"

local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"
local strings = require "qpd.services.strings"
local color = require "qpd.color"
--------------------------------------------------------------------------------

function gs.load(target)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    gs.player = this_player or {}

    gs.title = text_box.new(
        strings[target .. "_title"],
        "huge",
        0,
        0,
        w,
        "center",
        color.yellow)

    gs.text = text_box.new(
        strings[target],
        "huge",
        0,
        h/8,
        w,
        "center",
        color.red)

    gs.instructions = text_box.new( 
        strings.message_instructions,
        "regular",
        0,
        h*7/8,
        w,
        "center",
        color.raywhite)
    
    gs.actions = {}
    -- action to key functions    
    gs.actions[keymap.keys.exit] = 
        function ()
            gamestate.switch("menu")
        end
    gs.actions[keymap.keys.select] = 
        function ()
            gamestate.switch("game")
        end
    
end

function gs.draw()
    gs.title:draw()
    gs.text:draw()
    gs.instructions:draw()
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
    gs.title:resize(0, 0, w)
    gs.text:resize(0, h/8, w)
    gs.instructions:resize( 0, h*7/8, w)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs