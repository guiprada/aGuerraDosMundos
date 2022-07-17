local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------

function gs.load(message, go_again_gamestate)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	gs.player = {}

	gs.title = qpd.text_box.new(
		qpd.strings[message .. "_title"],
		"huge",
		0,
		0,
		w,
		"center",
		qpd.color.yellow)

	gs.text = qpd.text_box.new(
		qpd.strings[message],
		"huge",
		0,
		h/8,
		w,
		"center",
		qpd.color.red)

	gs.instructions = qpd.text_box.new(
		qpd.strings.message_instructions,
		"regular",
		0,
		h*7/8,
		w,
		"center",
		qpd.color.raywhite)

	gs.actions = {}
	-- action to key functions
	gs.actions[qpd.keymap.keys.exit] =
		function ()
			qpd.gamestate.switch("menu")
		end
	gs.actions[qpd.keymap.keys.select] =
		function ()
			qpd.gamestate.switch(go_again_gamestate)
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
	qpd.fonts.resize(w, h)
	gs.title:resize(0, 0, w)
	gs.text:resize(0, h/8, w)
	gs.instructions:resize( 0, h*7/8, w)
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs