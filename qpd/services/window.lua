local window = {}

local qpd_table = require "qpd.table"
local love_utils = require "qpd.love_utils"

local defaults = {
	width = 0,
	height = 0,
	fullscreen = true,
	vsync = 1,
	msaa = 0,
	resizable = true,
	minwidth = 256,
	minheight = 144
}

function window.load(path)
	-- check if there is a window.conf
	local win_settings = qpd_table.read_from_conf(path, "=")

	-- if not, create one
	if win_settings == nil then -- create a window.conf
		win_settings = {}
	end

	-- check if all entries are valid
	local needs_saving = false
	for key, value in pairs(defaults) do
		if win_settings[key] == nil then
			win_settings[key] = defaults[key]

			-- width and height should be invalid togheter
			if key == "width" then
				win_settings.height = defaults.height
			elseif key == "height" then
				win_settings.width = defaults.width
			end

			needs_saving = true
		end
	end

	-- and them write if needed
	if needs_saving then
		window.save(win_settings, path)
	else
		-- just assign
		window.settings = win_settings
	end
end

function window.save(settings, path)
	qpd_table.write_to_file(settings, path, "=")
	-- and assign
	window.settings = settings
end

function window.get_settings()
	local settings = {}
	settings.width = window.settings.width
	settings.height = window.settings.height
	settings.fullscreen = window.settings.fullscreen
	settings.vsync = window.settings.vsync
	settings.msaa = window.settings.msaa
	settings.resizable = window.settings.resizable
	settings.minwidth = window.settings.minwidth
	settings.minheight = window.settings.minheight

	return settings
end

function window.apply(settings)
	local settings = settings or window.get_settings()
	love_utils.set_mode(settings)
end

return window