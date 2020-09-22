local gs = {}

local gamestate = require "qpd.gamestate"
local utils = require "qpd.utils"

local text_box = require "qpd.widgets.text_box"
local selection_box = require "qpd.widgets.selection_box"

local color = require "qpd.color"

local files = require "qpd.services.files"
local keymap = require "qpd.services.keymap"
local fonts = require "qpd.services.fonts"
local strings = require "qpd.services.strings"
local window = require "qpd.services.window"

--------------------------------------------------------------------------------

local function save(w, h)
    local new_settings = window.get_settings()
    new_settings.width = w
    new_settings.height = h
    gamestate.switch("save_settings", new_settings)
end

local function save_current()
    save(love.graphics.getWidth(), love.graphics.getHeight())
end

--------------------------------------------------------------------------------

function gs.load()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    gs.title = text_box.new(
        strings.resolution_title,
        "huge",
        0,
        0,
        w,
        "center",
        color.yellow)

    gs.current = text_box.new(
        table.concat({strings.resolution_current, w, " x ", h}),
        "regular",
        0,
        h*1/6,
        w,
        "center",
        color.magenta)

    gs.saved = text_box.new(
        strings.resolution_saved ..
        window.settings.width .. " x " ..
        window.settings.height,
        "regular",
        0,
        h*1/6 +
        gs.current:get_height(),
        w,
        "center",
        color.magenta)

    gs.instructions = text_box.new( 
        strings.resolution_instructions,
        "regular",
        0,
        h*7/8,
        w,
        "center",
        color.offwhite)

    gs.selection_box = selection_box.new(   
        "big",
        0,
        h*1/4,
        w,
        "center",
        color.gray,
        color.red)

    gs.selection_box:add_selection( 
        strings.resolution_save_current,
        save_current)

    gs.resolutions =
                utils.table_read_from_conf(files.available_resolutions, "x")
    -- lets sort it
    local sorted = {}
    local index = 0
    for key, value in pairs(gs.resolutions) do
        index = index + 1
        sorted[index] = {w = key, h = value}
    end
    table.sort(
        sorted,
        function(a, b)
            if( a.w < b.w) then
                return true
            else
                return false
            end
        end)

    for key, value in ipairs(sorted) do
        gs.selection_box:add_selection(
            table.concat({ tostring(value.w), "x",  tostring(value.h)}),
            function() save(value.w, value.h) end)
    end

    gs.actions = {}
    gs.actions[keymap.keys.exit] =  
        function ()
            gamestate.switch("settings_menu")
        end

    gs.actions[keymap.keys.up] = function () gs.selection_box:up() end
    gs.actions[keymap.keys.down] = function () gs.selection_box:down() end
    gs.actions[keymap.keys.select] =  function () gs.selection_box:select() end
end

function gs.draw()
    gs.title:draw()
    gs.current:draw()
    gs.saved:draw()
    gs.instructions:draw()
    gs.selection_box:draw()
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
    gs.current.text = table.concat({strings.resolution_current, w, " x ", h})
    gs.current:resize(0, h*1/6, w)
    gs.saved:resize(0, h*1/6 + gs.current:get_height(), w)
    gs.selection_box:resize(0, h*1/4, w)
    gs.instructions:resize(0, h*7/8, w)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs
