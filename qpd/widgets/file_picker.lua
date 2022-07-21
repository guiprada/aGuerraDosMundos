local file_picker = {}

local qpd_table = require "qpd.table"
local love_utils = require "qpd.love_utils"
local qpd_fonts = require "qpd.services.fonts"
local qpd_color = require "qpd.color"

--------------------------------------------------------------------------------
function file_picker.down(self)
	if self._selected then
		if self._selected < #self._selections then
			self._selected = self._selected + 1
		else
			self._selected = 1
		end
	end
end

function file_picker.up(self)
	if self._selected then
		if self._selected > 1 then
			self._selected = self._selected - 1
		else
			self._selected = #self._selections
		end
	end
end

function file_picker.file_picked(self, pick)

end

function file_picker.select(self)
	if self._selected then
		local pick = self._path .. self._selections[self._selected].text
		if love.filesystem.isDirectory(pick) then
			-- rebuild file_picker
		elseif love.filesystem.isFile(pick) then
			self._return_callback(pick)
		end
	end
end

function file_picker.add_selection(self, text)
	local new_index = #self._selections + 1
	if new_index == 1 then
		self._selected = 1
	end
	self._selections[new_index] = {text = text}

	return self._selections[new_index]
end

--------------------------------------------------------------------------------
function file_picker.get_height(self)
	local total_height = 0
	for i = 1, #self._selections, 1 do
		local this_height = love_utils.calculate_text_height(
			self._selections[i].text,
			qpd_fonts[self.font_name],
			self.width)
		total_height = total_height + this_height
	end

	return total_height
end

function file_picker.get_n_selections(self)
	return #self._selections
end

function file_picker.get_selected(self)
	return self._selected
end
--------------------------------------------------------------------------------

function file_picker.draw(self)
	local r, g, b, a = love.graphics.getColor()
	local last_height = self.y
	for i = 1, #self._selections, 1 do
		if( i == self._selected ) then
			love.graphics.setColor(qpd_color.unpack(self.color_selected))
		else
			love.graphics.setColor(qpd_color.unpack(self.color))
		end
		love.graphics.printf(
			self._selections[i].text,
				qpd_fonts[self.font_name],
				self.x,
				last_height,
				self.width,
				self.align)

		local this_height = love_utils.calculate_text_height(
			self._selections[i].text,
			qpd_fonts[self.font_name],
			self.width)

		last_height = last_height + this_height
	end
	love.graphics.setColor(r, g, b, a)
end

function file_picker.reset(
	self,
	font_name,
	x,
	y,
	width,
	align,
	color,
	color_selected)

	-- public
	self.font_name = font_name
	self.x = x
	self.y = y
	self.width = width
	self.align = align or self.align or "center"
	self.color = color or self.color or {1,1,1}
	self.color_selected = color_selected or self.color_selected or {1,0,0}

	-- private

	self._selections = {}
	self._self_selected = nil -- will be started by file_picker.add_selection
end

function file_picker.resize(self, x, y, width)
	self.x = x
	self.y = y
	self.width = width
end
--------------------------------------------------------------------------------

function file_picker.new(font_name, x, y, width, align, color, color_selected, path, return_callback)
	local o = {}

	-- methods
	qpd_table.assign_methods(o, file_picker)

	o:reset(font_name, x, y, width, align, color, color_selected)

	o._path = path
	o._return_callback = return_callback
	local items = love.filesystem.getDirectoryItems(path)
	for _, item in ipairs(items) do
		o.add_selection(item)
	end

	return o
end

return file_picker
