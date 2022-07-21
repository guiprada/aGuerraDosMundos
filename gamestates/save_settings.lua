local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------
local function save_settings(settings)
	-- settings have already been applied, so just save
	qpd.window.save(settings, qpd.files.window_conf)
	qpd.gamestate.switch("settings_menu")
end

local function fallback_settings()
	-- settings have only been applied, not saved, so just apply the saved
	-- settings
	qpd.window.apply(qpd.window.get_settings())
	qpd.fonts.resize()
	qpd.gamestate.switch("settings_menu")
end

local function timer_out()
	fallback_settings()
end

--------------------------------------------------------------------------------
function gs.load(new_settings)
	assert(new_settings, "save_settings gamestate received wrong settings")

	qpd.window.apply(new_settings)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	qpd.fonts.resize(w, h)


	gs.timer = qpd.timer.new(10, timer_out)
	gs.timer:reset()

	gs.instructions = qpd.text_box.new(
		qpd.strings.save_settings_instructions,
		"regular",
		0,
		h*1/4,
		w,
		"center",
		qpd.color.offwhite)

	gs.fallback_timer_text_box =  qpd.text_box.new(
		nil,
		"regular",
		0,
		h*3/4,
		w,
		"center",
		qpd.color.red)

	gs.actions = {}
	gs.actions[qpd.keymap.keys.select] =
		function ()
			save_settings(new_settings)
		end
	gs.actions[qpd.keymap.keys.exit] =
		function ()
			fallback_settings()
		end
end

function gs.draw()
	gs.fallback_timer_text_box.text = table.concat({
		qpd.strings.save_settings_timer,
		math.floor(gs.timer:get_remaining_time())})

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
	qpd.fonts.resize(w, h)
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
