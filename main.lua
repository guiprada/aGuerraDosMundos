local gamestate = require "qpd.gamestate"
local utils = require "qpd.utils"

local files = require "qpd.services.files"
local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"
local strings = require "qpd.services.strings"
local window = require "qpd.services.window"

function love.load()
    -- starting files service, should be the first one because we need the
    -- filepaths to start the other services
    files.load("qpd/services/files.conf")

    -- starting the keymap service
    keymap.load(files.keymap_conf)

    --starting the window service
    window.load(files.window_conf)
    window.apply()

    -- starting the fonts service, should be started after window service
    -- to get the proper screen dimensions
    fonts.load(files.fonts_conf)

    -- starting the strings service
    local string_conf = utils.table_read_from_conf(files.strings_conf, "=")
    local strings_index = string_conf[string_conf.choosen]
    strings.load(files[strings_index])

    -- set window title, should be done after the strings service has started
    love.window.setTitle(strings.title)

    -- register the states with the gamestate library
    gamestate.register("love", love)
    gamestate.register("menu", require "gamestates.menu")
    gamestate.register("game", require "gamestates.game")
    gamestate.register("settings_menu", require "gamestates.settings_menu")
    gamestate.register("save_settings", require "gamestates.save_settings")
    gamestate.register(
        "change_resolution",
        require "gamestates.change_resolution")
    gamestate.register("change_keymap", require "gamestates.change_keymap")
    gamestate.register(
        "change_language",
        require "gamestates.change_language")
    gamestate.register("tilemap_editor", require "gamestates.tilemap_editor")

    -- detect first time run
    local has_run = io.open(files.has_run)
    if has_run then
        -- go to menu
        gamestate.switch("menu")
    else
        --create has_run file
        has_run = io.open(files.has_run, 'w')
        has_run:close()
        -- go to language menu
        gamestate.switch("change_language", "first_boot")
    end
end
