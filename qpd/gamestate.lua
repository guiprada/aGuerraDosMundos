local gamestate = {}

local utils = require "qpd.utils"
local pvt = {} -- private functions

gamestate.states = {}

gamestate.callback_list = {
    "load",
    "unload",
    "update",
    "draw",
    "keypressed",
    "keyreleased",
    "displayrotated",
    "errorhandler",
    "lowmemory",
    "quit",
    "run",
    "threaderror",
    "directorydropped",
    "filedropped",
    "focus",
    "mousefocus",
    "resize",
    "visible",
    "textedited",
    "textinput",
    "mousemoved",
    "mousepressed",
    "mousereleased",
    "wheelmoved",
    "gamepadaxis",
    "gamepadpressed",
    "gamepadreleased",
    "joystickadded",
    "joystickaxis",
    "joystickhat",
    "joystickpressed",
    "joystickreleased",
    "joystickremoved",
    "touchmoved",
    "touchpressed",
    "touchreleased",
    "displayrotated"
}

--------------------------------------------------------------------------------

function pvt.assign(dest, callbacks)
    for _, callback in pairs(gamestate.callback_list) do
        dest[callback] = callbacks[callback] or nil
    end
end

--------------------------------------------------------------------------------

function gamestate.register(name, callbacks)
    local new_entry = {}
    pvt.assign(new_entry, callbacks)
    gamestate.states[name] = new_entry
end

function gamestate.switch(name, args)
    if gamestate.current and gamestate.current.unload then
        gamestate.current.unload()
    end

    gamestate.current_name = name
    gamestate.current = gamestate.states[name]
    pvt.assign(love, gamestate.current)
    gamestate.current.load(args)
end

return gamestate
