local gs = {}

local qpd = require "qpd.qpd"

--------------------------------------------------------------------------------
local function change_player_color()
	qpd.gamestate.switch("change_color", "player_color")
end

local function change_friend_color()
	qpd.gamestate.switch("change_color", "friend_color")
end

local function change_difficulty()
	qpd.gamestate.switch("change_difficulty")
end

local function change_language()
	qpd.gamestate.switch("change_language")
end

local function change_resolution()
	qpd.gamestate.switch("change_resolution")
end

local function change_keymap()
	qpd.gamestate.switch("change_keymap")
end

local function change_setting(indexer)
	local new_settings = qpd.window.get_settings()

	if type(qpd.window.settings[indexer]) == 'boolean' then
		new_settings[indexer] = not qpd.window.settings[indexer]
	else
		local new_value = 0
		if qpd.window.settings[indexer] == 0 then
			new_value = 1
		end
		new_settings[indexer] = new_value
	end
	qpd.gamestate.switch("save_settings", new_settings)
end

local function change_fullscreen()
	change_setting("fullscreen")
end

local function change_vsync()
	change_setting("vsync")
end

local function change_msaa()
	change_setting("msaa")
end

local function reset_settings()
	os.remove(qpd.files.window_conf)
	qpd.gamestate.switch("love")
end

--------------------------------------------------------------------------------
function gs.load()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	--qpd.fonts.resize(w, h)

	gs.title = qpd.text_box.new(
		qpd.strings.settings_menu_title,
		"huge",
		0,
		0,
		w,
		"center",
		qpd.color.yellow)

	gs.instructions = qpd.text_box.new(
		qpd.strings.settings_menu_instructions,
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
		qpd.strings.settings_menu_change_player_color,
		change_player_color)
	gs.selection_box:add_selection(
		qpd.strings.settings_menu_change_friend_color,
		change_friend_color)
	gs.selection_box:add_selection(
		qpd.strings.settings_menu_change_difficulty,
		change_difficulty)
	gs.selection_box:add_selection(
		qpd.strings.settings_menu_change_language,
		change_language)
	gs.selection_box:add_selection(
		qpd.strings.settings_menu_change_resolution,
		change_resolution)
	gs.selection_box:add_selection(
		qpd.strings.settings_menu_change_keymap,
		change_keymap)
	gs.selection_box:add_selection(
		qpd.strings.settings_menu_fullscreen ..
		tostring(qpd.window.settings.fullscreen),
		change_fullscreen)
	gs.selection_box:add_selection(
		table.concat({
			qpd.strings.settings_menu_vsync,
			tostring(qpd.value.number_to_bool(qpd.window.settings.vsync))}),
		change_vsync)
	-- gs.selection_box:add_selection(
	--     table.concat({
	--         qpd.strings.settings_menu_msaa,
	--         tostring(utils.number_to_bool(qpd.window.settings.msaa))}),
	--     change_msaa)
	gs.selection_box:add_selection( qpd.strings.settings_menu_reset, reset_settings)

	gs.actions = {}
	gs.actions[qpd.keymap.keys.exit] = function () qpd.gamestate.switch("menu") end
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
	gs.instructions:resize( 0, h*7/8, w)
	gs.selection_box:resize(0, h*1/4, w)
end

function gs.unload()
	-- the callbacks are saved by the gamestate
	gs = {}
end

return gs