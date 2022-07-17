local love_utils = {}

local qpd_table = require "qpd.table"

function love_utils.set_mode(settings)
	-- love.window.setMode errors out if width or height are present
	-- so we clone the original settings and remove them

	local new_settings = qpd_table.clone(settings)
	local width = new_settings.width
	new_settings.width = nil
	local height = new_settings.height
	new_settings.height = nil

	love.window.setMode(width, height, new_settings)
end

function love_utils.calculate_text_height(text, font, wrap)
	-- n_lines
	local _, lines = font:getWrap(text, wrap)
	local n_lines = #lines
	-- calculate height
	return font:getHeight() * n_lines
end

return love_utils
