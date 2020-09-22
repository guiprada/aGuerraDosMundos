local gs = {}

local gamestate = require "qpd.gamestate"
local utils = require "qpd.utils"
local love_utils = require "qpd.love_utils"

local text_box = require "qpd.widgets.text_box"

local color = require "qpd.color"
local timer = require "qpd.timer"

local files = require "qpd.services.files"
local keymap = require "qpd.services.keymap"
local fonts = require "qpd.services.fonts"
local strings = require "qpd.services.strings"
local window = require "qpd.services.window"

--------------------------------------------------------------------------------

local function save_settings(settings)
    -- settings have already been applied, so just save
    window.save(settings, files.window_conf)
    gamestate.switch("settings_menu")
end

local function fallback_settings()
    -- settings have only been applied, not saved, so just apply the saved
    -- settings
    window.apply(window.get_settings())
    fonts.resize()
    gamestate.switch("settings_menu")
end

local function timer_out()
    fallback_settings()
end

--------------------------------------------------------------------------------

function gs.load(new_settings)
    assert(new_settings, "save_settings gamestate received wrong settings")

    window.apply(new_settings)
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    fonts.resize(w, h)


    gs.timer = timer.new(10, timer_out)

    gs.instructions = text_box.new( 
        strings.save_settings_instructions,
        "regular",
        0,
        h*1/4,
        w,
        "center",
        color.offwhite)

    gs.fallback_timer_text_box =  text_box.new( 
        nil,                                        
        "regular",
        0,
        h*3/4,
        w,
        "center",
        color.red)

    gs.actions = {}
    gs.actions[keymap.keys.select] =
        function ()
            save_settings(new_settings)
        end
    gs.actions[keymap.keys.exit] =
        function ()
            fallback_settings()
        end
end

function gs.draw()
    gs.fallback_timer_text_box.text = table.concat({
        strings.save_settings_timer,
        math.floor(gs.timer:get_timer())}) 
                                            
    gs.fallback_timer_text_box:draw()
    gs.instructions:draw()
end

function gs.keyreleased(key, scancode)
    local func = gs.actions[key]
    if func then
        func()
    end
end

function gs.resize(w, h)
    fonts.resize(w, h)
    gs.instructions:resize(0, h*1/4, w)
    gs.fallback_timer_text_box:resize(0, h*3/4, w)
end

function gs.update(dt)
    gs.timer:update(dt)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs
