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

local function exit()    
    gamestate.switch("settings_menu")
end

local function save(target, value)
    local game_conf = utils.table_read_from_conf(files.game_conf)
    game_conf[target] = value
    utils.table_write_to_file(game_conf, files.game_conf)
    exit()
end

--------------------------------------------------------------------------------

function gs.load(args)
    local target = args
    
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    gs.title = text_box.new(
        strings.color_title, 
        "huge",
        0,
        0,
        w,
        "center",
        color.yellow)

    gs.instructions = text_box.new( 
        strings.color_instructions,
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

    local colors = utils.table_read_from_conf(files.available_colors)
    for key, value in pairs(colors) do
        gs.selection_box:add_selection(key, function() save(target, key) end)
    end

    gs.actions = {}
    gs.actions[keymap.keys.exit] = exit
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
    gs.instructions(0, h*7/8, w)
    gs.selection_box:resize(0, h*1/4, w)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs
