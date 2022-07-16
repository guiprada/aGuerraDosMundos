local fonts = {}
local utils = require "qpd.utils"

function fonts.resize(w, h)
	local width = w or love.graphics.getWidth()
	local height = h or love.graphics.getHeight()

	local scale_width = width/fonts.default_width
	local scale_height = height/fonts.default_height

	local scale = scale_width
	if scale_height < scale_width then
		scale = scale_height
	end

	fonts.huge = love.graphics.newFont(
		fonts.font_file,
		fonts.font_size_huge*scale)

	fonts.big = love.graphics.newFont(
		fonts.font_file,
		fonts.font_size_big*scale)

	fonts.regular = love.graphics.newFont(
		fonts.font_file,
		fonts.font_size*scale)
	fonts.small = love.graphics.newFont(
		fonts.font_file,
		fonts.font_size_small*scale)
end

function fonts.load(path, w, h)
	assert(
		path,
		"fonts.load() received a nil path: " .. path)

	local font_settings = utils.table_read_from_conf(path, "=")
	assert(
		font_settings,
		"fonts.resize() could not read its configuration file: " .. path)

	fonts.default_width = font_settings.default_width
	fonts.default_height = font_settings.default_height
	fonts.font_file = font_settings.font_file
	fonts.font_size_huge = font_settings.font_size_huge
	fonts.font_size_big = font_settings.font_size_big
	fonts.font_size = font_settings.font_size
	fonts.font_size_small = font_settings.font_size_small

	fonts.resize(w, h)
end

return fonts
