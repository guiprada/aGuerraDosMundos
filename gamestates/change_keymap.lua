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

--------------------------------------------------------------------------------

local function wait_action_key(action)
	gs.waiting_for_key = true
	gs.choosen_action = action
	gs.instructions_get_key.text = strings.keymap_wait .. action
end

local function load_actions()
	gs.actions[keymap.keys.exit] =
		function () gamestate.switch("settings_menu") end
	gs.actions[keymap.keys.up] = function () gs.selection_box:up() end
	gs.actions[keymap.keys.down] = function () gs.selection_box:down() end
	gs.actions[keymap.keys.select] =  function () gs.selection_box:select() end
end

--------------------------------------------------------------------------------

function gs.load()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	--fonts.resize(w, h)
	gs.waiting_for_key = false

	-- local copy of keymap
	gs.keymap = utils.table_read_from_conf(files.keymap_conf, "=")

	gs.title = text_box.new(
		strings.keymap_title,
		"huge",
		0,
		0,
		w,
		"center",
		color.yellow)

	gs.instructions = text_box.new(
		strings.keymap_instructions,
		"regular",
		0,
		h*7/8,
		w,
		"center",
		color.raywhite)

	gs.instructions_get_key = text_box.new(
		"",
		"regular",
		0,
		h*1/2,
		w,
		"center",
		color.raywhite)

	gs.header = text_box.new(
		strings.keymap_act_key,
		"big",
		0,
		h*1/8,
		w,
		"center",
		color.magenta)

	gs.selection_box = selection_box.new(
		"regular",
		0,
		h*1/6,
		w,
		"center",
		color.gray,
		color.red)

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
		keymap.save(gs.keymap, files.keymap_conf)
		-- update selection text
		gs.selection[gs.choosen_action].text = table.concat({
			gs.choosen_action,
			" : ",
			gs.keymap[gs.choosen_action]})

		-- reload map
		keymap.load(files.keymap_conf)
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
	fonts.resize(w, h)
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
