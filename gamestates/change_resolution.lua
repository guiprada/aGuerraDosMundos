local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------
local function save(w, h)
	local new_settings = qpd.window.get_settings()
	new_settings.width = w
	new_settings.height = h
	qpd.gamestate.switch("save_settings", new_settings)
end

local function save_current()
	save(love.graphics.getWidth(), love.graphics.getHeight())
end

--------------------------------------------------------------------------------
function gs.load()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	gs.title = qpd.text_box.new(
		qpd.strings.resolution_title,
		"huge",
		0,
		0,
		w,
		"center",
		qpd.color.yellow)

	gs.current = qpd.text_box.new(
		table.concat({qpd.strings.resolution_current, w, " x ", h}),
		"regular",
		0,
		h*1/6,
		w,
		"center",
		qpd.color.magenta)

	gs.saved = qpd.text_box.new(
		qpd.strings.resolution_saved ..
		qpd.window.settings.width .. " x " ..
		qpd.window.settings.height,
		"regular",
		0,
		h*1/6 +
		gs.current:get_height(),
		w,
		"center",
		qpd.color.magenta)

	gs.instructions = qpd.text_box.new(
		qpd.strings.resolution_instructions,
		"regular",
		0,
		h*7/8,
		w,
		"center",
		qpd.color.offwhite)

	gs.selection_box = qpd.selection_box.new(
		"big",
		0,
		h*1/4,
		w,
		"center",
		qpd.color.gray,
		qpd.color.red)

	gs.selection_box:add_selection(
		qpd.strings.resolution_save_current,
		save_current)

	gs.resolutions =
				qpd.table.read_from_conf(qpd.files.available_resolutions, "x")
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
	gs.actions[qpd.keymap.keys.exit] =
		function ()
			qpd.gamestate.switch("settings_menu")
		end

	gs.actions[qpd.keymap.keys.up] = function () gs.selection_box:up() end
	gs.actions[qpd.keymap.keys.down] = function () gs.selection_box:down() end
	gs.actions[qpd.keymap.keys.select] =  function () gs.selection_box:select() end
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
	qpd.fonts.resize(w, h)
	gs.title:resize(0, 0, w)
	gs.current.text = table.concat({qpd.strings.resolution_current, w, " x ", h})
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
