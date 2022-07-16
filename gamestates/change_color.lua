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

local function exit()
	gamestate.switch("settings_menu")
end

local function load_sprite(target)
	local game_conf = utils.table_read_from_conf(files.game_conf)
	if game_conf then
		local color_saved = game_conf[target]
		gs.selected_sprite = love.graphics.newImage(files["spr_" .. color_saved])
	else
		print("Failed to read game.conf")
	end
end

local function sprite_dimension(w,h)
	gs.selected_sprite_pos.x = 3*w/4
	gs.selected_sprite_pos.y = h/2
	gs.selected_sprite_rot = -math.pi/2
	gs.selected_sprite_scale = utils.min(w,h)/(3*gs.selected_sprite:getWidth())
end

local function save(target, value)
	local game_conf = utils.table_read_from_conf(files.game_conf)
	game_conf[target] = value
	utils.table_write_to_file(game_conf, files.game_conf)
	load_sprite(target)
end

--------------------------------------------------------------------------------

function gs.load(args)
	local target = args

	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()

	load_sprite(target)
	gs.selected_sprite_offset = {}
	gs.selected_sprite_offset.x = gs.selected_sprite:getWidth()/2
	gs.selected_sprite_offset.y = gs.selected_sprite:getHeight()/2
	gs.selected_sprite_pos = {}
	sprite_dimension(w, h)

	gs.title = text_box.new(
		strings.color_title,
		"huge",
		0,
		0,
		w,
		"center",
		color.yellow)

	gs.instructions = text_box.new(
		strings.color_instructions,
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
		w/2,
		"center",
		color.gray,
		color.red)

	local colors = utils.table_read_from_conf(files.available_colors)
	for key, value in ipairs(colors) do
		gs.selection_box:add_selection(value, function() save(target, value) end)
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
	love.graphics.draw(
		gs.selected_sprite,
		gs.selected_sprite_pos.x,
		gs.selected_sprite_pos.y,
		gs.selected_sprite_rot,
		gs.selected_sprite_scale,
		gs.selected_sprite_scale,
		gs.selected_sprite_offset.x,
		gs.selected_sprite_offset.y
	)
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
	gs.selection_box:resize(0, h*1/4, w/2)
	sprite_dimension(w, h)
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs
