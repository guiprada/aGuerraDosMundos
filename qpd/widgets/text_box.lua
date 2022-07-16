local text_box = {}

local utils = require "qpd.utils"
local love_utils = require "qpd.love_utils"
local fonts = require "qpd.services.fonts"
local color = require "qpd.color"

--------------------------------------------------------------------------------

function text_box.get_height(self)
	local height = love_utils.calculate_text_height(
		self.text,
		fonts[self.font_name],
		self.width)

	return height
end

--------------------------------------------------------------------------------

function text_box.draw(self)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(color.unpack(self.color))
	love.graphics.printf(
		self.text,
		fonts[self.font_name],
		self.x,
		self.y,
		self.width,
		self.align)

	love.graphics.setColor(r, g, b, a)
end

function text_box.reset(self, text, font_name, x, y, width, align, color)
	self.font_name = font_name
	self.width = width
	self.text = text
	self.x = x
	self.y = y
	self.align = align or "center"
	self.color = color or {1, 1, 1}
end

function text_box.resize(self, x, y, width)
	self.x = x
	self.y = y
	self.width = width
end

--------------------------------------------------------------------------------

function text_box.new(text, font_name, x, y, width, align, color)
	local o = {}

	-- methods
	utils.assign_methods(o, text_box)

	o:reset(text, font_name, x, y, width, align, color)

	return o
end

return text_box
