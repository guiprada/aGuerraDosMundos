local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------
local function exit()
	qpd.gamestate.switch("settings_menu")
end

local function save(value)
	local game_conf = qpd.table.read_from_conf(qpd.files.game_conf)
	game_conf.difficulty = value
	print(value)
	qpd.table.write_to_file(game_conf, qpd.files.game_conf)
	exit()
end

--------------------------------------------------------------------------------
function gs.load(args)

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	gs.title = qpd.text_box.new(
		qpd.strings.difficulty_title,
		"huge",
		0,
		0,
		w,
		"center",
		qpd.color.yellow)

	gs.instructions = qpd.text_box.new(
		qpd.strings.difficulty_instructions,
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

	local difficulties = qpd.table.read_from_conf(qpd.files.available_difficulty)
	for key, value in ipairs(difficulties) do
		gs.selection_box:add_selection(value, function() save(key) end)
	end

	gs.actions = {}
	gs.actions[qpd.keymap.keys.exit] = exit
	gs.actions[qpd.keymap.keys.up] = function () gs.selection_box:up() end
	gs.actions[qpd.keymap.keys.down] = function () gs.selection_box:down() end
	gs.actions[qpd.keymap.keys.select] =  function () gs.selection_box:select() end
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
	qpd.fonts.resize(w, h)
	gs.title:resize(0, 0, w)
	gs.instructions:resize(0, h*7/8, w)
	gs.selection_box:resize(0, h*1/4, w)
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs