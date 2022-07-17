local qpd = require "qpd.qpd"

function love.load()
	love.graphics.setDefaultFilter("nearest","nearest")
	love.keyboard.setKeyRepeat(true)

	-- starting files service, should be the first one because we need the
	-- filepaths to start the other services
	qpd.files.load("qpd/services/files.conf")

	-- starting the keymap service
	qpd.keymap.load(qpd.files.keymap_conf)

	--starting the window service
	qpd.window.load(qpd.files.window_conf)
	qpd.window.apply()

	-- starting the fonts service, should be started after window service
	-- to get the proper screen dimensions
	qpd.fonts.load(qpd.files.fonts_conf)

	-- starting the strings service
	local string_conf = qpd.table.read_from_conf(qpd.files.strings_conf, "=")

	local strings_index
	if string_conf then
		strings_index = string_conf[string_conf.choosen]
	else
		print("Failed to load strings_conf")
	end

	qpd.strings.load(qpd.files[strings_index])

	-- set window title, should be done after the strings service has started
	love.window.setTitle(qpd.strings.title)

	-- register the states with the gamestate library
	qpd.gamestate.register("love", love)
	qpd.gamestate.register("menu", require "gamestates.menu")
	qpd.gamestate.register("war_of_the_worlds", require "gamestates.war_of_the_worlds")
	qpd.gamestate.register("extinction", require "gamestates.extinction")
	qpd.gamestate.register("settings_menu", require "gamestates.settings_menu")
	qpd.gamestate.register("save_settings", require "gamestates.save_settings")
	qpd.gamestate.register("change_resolution", require "gamestates.change_resolution")
	qpd.gamestate.register("change_keymap", require "gamestates.change_keymap")
	qpd.gamestate.register("change_language", require "gamestates.change_language")
	qpd.gamestate.register("tilemap_editor", require "gamestates.tilemap_editor")
	qpd.gamestate.register("change_color", require "gamestates.change_color")
	qpd.gamestate.register("change_difficulty", require "gamestates.change_difficulty")
	qpd.gamestate.register("message", require "gamestates.message")

	qpd.run_tests()

	-- detect first time run
	local has_run = io.open(qpd.files.has_run)
	if has_run then
		-- go to menu
		qpd.gamestate.switch("menu")
	else
		--create has_run file
		has_run = io.open(qpd.files.has_run, 'w')
		if has_run then
			has_run:close()
		end
		-- go to language menu
		qpd.gamestate.switch("change_language", "first_boot")
	end
end
