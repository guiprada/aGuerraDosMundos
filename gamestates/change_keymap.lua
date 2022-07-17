local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------
local function wait_action_key(action)
	gs.waiting_for_key = true
	gs.choosen_action = action
	gs.instructions_get_key.text = qpd.strings.keymap_wait .. action
end

local function load_actions()
	gs.actions[qpd.keymap.keys.exit] =
		function () qpd.gamestate.switch("settings_menu") end
	gs.actions[qpd.keymap.keys.up] = function () gs.selection_box:up() end
	gs.actions[qpd.keymap.keys.down] = function () gs.selection_box:down() end
	gs.actions[qpd.keymap.keys.select] =  function () gs.selection_box:select() end
end

--------------------------------------------------------------------------------
function gs.load()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	--qpd.fonts.resize(w, h)
	gs.waiting_for_key = false

	-- local copy of keymap
	gs.keymap = qpd.table.read_from_conf(qpd.files.keymap_conf, "=")

	gs.title = qpd.text_box.new(
		qpd.strings.keymap_title,
		"huge",
		0,
		0,
		w,
		"center",
		qpd.color.yellow)

	gs.instructions = qpd.text_box.new(
		qpd.strings.keymap_instructions,
		"regular",
		0,
		h*7/8,
		w,
		"center",
		qpd.color.raywhite)

	gs.instructions_get_key = qpd.text_box.new(
		"",
		"regular",
		0,
		h*1/2,
		w,
		"center",
		qpd.color.raywhite)

	gs.header = qpd.text_box.new(
		qpd.strings.keymap_act_key,
		"big",
		0,
		h*1/8,
		w,
		"center",
		qpd.color.magenta)

	gs.selection_box = qpd.selection_box.new(
		"regular",
		0,
		h*1/6,
		w,
		"center",
		qpd.color.gray,
		qpd.color.red)

	gs.selection = {}
	local order = {
		"up",
		"down",
		"left",
		"right",
		"zoom_in",
		"zoom_out",
		"save",
		"select",
		"action",
		"exit",
		"delete",
		"next_sprite",
		"previous_sprite",
		"add_top",
		"add_bottom",
		"add_right",
		"add_left"}

	for key, value in ipairs(order) do
		gs.selection[value] = gs.selection_box:add_selection(
			table.concat({value, " : ", gs.keymap[value]}),
			function() wait_action_key(value) end)
	end

	gs.actions = {}
	load_actions()
end

function gs.draw()
	gs.title:draw()

	if gs.waiting_for_key == true then
		gs.instructions_get_key:draw()
	else
		gs.header:draw()
		gs.instructions:draw()
		gs.selection_box:draw()
	end
end

function gs.keyreleased(key, scancode)
	if gs.waiting_for_key == true then
		-- assign new key
		gs.keymap[gs.choosen_action] = key
		-- save
		qpd.keymap.save(gs.keymap, qpd.files.keymap_conf)
		-- update selection text
		gs.selection[gs.choosen_action].text = table.concat({
			gs.choosen_action,
			" : ",
			gs.keymap[gs.choosen_action]})

		-- reload map
		qpd.keymap.load(qpd.files.keymap_conf)
		-- map changed, so reload actions
		load_actions()
		-- get out
		gs.waiting_for_key = false
	else
		local func = gs.actions[key]

		if func then
			func()
		end
	end
end

function gs.resize(w, h)
	qpd.fonts.resize(w, h)
	gs.title:resize(0, 0, w)
	gs.instructions:resize( 0, h*7/8, w)
	gs.instructions_get_key:resize(0, h*1/2, w)
	gs.header:resize(0, h*1/8, w)
	gs.selection_box:resize(0, h*1/4, w)
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs
