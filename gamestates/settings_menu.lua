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

local function change_player_color()
    gamestate.switch("change_color", "player_color")
end

local function change_friend_color()
    gamestate.switch("change_color", "friend_color")
end

local function change_language()
    gamestate.switch("change_language")
end

local function change_resolution()
    gamestate.switch("change_resolution")
end

local function change_keymap()
    gamestate.switch("change_keymap")
end

local function change_setting(indexer)
    local new_settings = window.get_settings()

    if type(window.settings[indexer]) == 'boolean' then
        new_settings[indexer] = not window.settings[indexer]
    else
        local new_value = 0
        if window.settings[indexer] == 0 then
            new_value = 1
        end
        new_settings[indexer] = new_value
    end
    gamestate.switch("save_settings", new_settings)
end

local function change_fullscreen()
    change_setting("fullscreen")
end

local function change_vsync()
    change_setting("vsync")
end

local function change_msaa()
    change_setting("msaa")
end

local function reset_settings()    
    os.remove(files.window_conf)
    gamestate.switch("love")
end

--------------------------------------------------------------------------------

function gs.load()
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()
    --fonts.resize(w, h)

    gs.title = text_box.new(
        strings.settings_menu_title,
        "huge",
        0,
        0,
        w,
        "center",
        color.yellow)
                                
    gs.instructions = text_box.new(
        strings.settings_menu_instructions,
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
        strings.settings_menu_change_player_color,
        change_player_color)
    gs.selection_box:add_selection(
        strings.settings_menu_change_friend_color,
        change_friend_color)
    gs.selection_box:add_selection(
        strings.settings_menu_change_language,
        change_language)
    gs.selection_box:add_selection(
        strings.settings_menu_change_resolution,
        change_resolution)
    gs.selection_box:add_selection(
        strings.settings_menu_change_keymap,
        change_keymap)
    gs.selection_box:add_selection(
        strings.settings_menu_fullscreen .. 
        tostring(window.settings.fullscreen),
        change_fullscreen)
    gs.selection_box:add_selection(
        table.concat({
            strings.settings_menu_vsync,
            tostring(utils.number_2_bool( window.settings.vsync))}),
        change_vsync)
    -- gs.selection_box:add_selection(
    --     table.concat({
    --         strings.settings_menu_msaa,
    --         tostring(utils.number_2_bool(window.settings.msaa))}),
    --     change_msaa)
    gs.selection_box:add_selection( strings.settings_menu_reset, reset_settings)

    gs.actions = {}
    gs.actions[keymap.keys.exit] = function () gamestate.switch("menu") end
    gs.actions[keymap.keys.up] = function () gs.selection_box:up() end
    gs.actions[keymap.keys.down] = function () gs.selection_box:down() end
    gs.actions[keymap.keys.select] =  function () gs.selection_box:select() end

end

function gs.draw()
    gs.title:draw()
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
    gs.instructions:resize( 0, h*7/8, w)
    gs.selection_box:resize(0, h*1/4, w)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs