local gs = {}

local gamestate = require "qpd.gamestate"

local fonts = require "qpd.services.fonts"
local keymap = require "qpd.services.keymap"

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------

function gs.load()
	-- define keyboard actions
	gs.actions = {}
	gs.actions[keymap.keys.exit] = function () love.event.quit(0) end
end

function gs.draw()
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
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs