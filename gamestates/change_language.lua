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

local function save(value)
    local strings_conf = utils.table_read_from_conf(files.strings_conf)
    strings_conf.choosen = value
    utils.table_write_to_file(strings_conf, files.strings_conf)

    local string_conf = utils.table_read_from_conf(files.strings_conf, "=")
    local strings_index = string_conf[string_conf.choosen]
    strings.load(files[strings_index])

    love.window.setTitle(strings.title)
    if  gs.first_boot == true then
        gamestate.switch("menu")
    else
        gamestate.switch("settings_menu")
    end
end

local function exit()    
    if  gs.first_boot == true then

        --gamestate.switch("menu")
    else
        gamestate.switch("settings_menu")
    end
end

--------------------------------------------------------------------------------

function gs.load(args)
    if args == "first_boot" then
        gs.first_boot = true
    else
        gs.first_boot = false
    end

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    gs.snd_selection = love.audio.newSource(files.snd_selection, "static")
    gs.snd_selected = love.audio.newSource(files.snd_selected, "static")
    
    gs.title = text_box.new(
        strings.language_title, 
        "huge",
        0,
        0,
        w,
        "center",
        color.yellow)

    gs.instructions = text_box.new( 
        strings.language_instructions,
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
        color.red,
        gs.snd_selection,
        gs.snd_selected)

    local languages = utils.table_read_from_conf(files.available_languages)
    for key, value in pairs(languages) do
        gs.selection_box:add_selection(value, function() save(key) end)
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
    gs.instructions:resize(0, h*7/8, w)
    gs.selection_box:resize(0, h*1/4, w)
end

function gs.unload()
    -- the callbacks are saved by the gamestate
    gs = {}
end

return gs
