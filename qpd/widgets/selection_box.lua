local selection_box = {}

local utils = require "qpd.utils"
local love_utils = require "qpd.love_utils"
local fonts = require "qpd.services.fonts"

--------------------------------------------------------------------------------

function selection_box.down(self)
    if self._selected then
        if self._selected < #self._selections then
            self._selected = self._selected + 1
        else
            self._selected = 1
        end
    end
end

function selection_box.up(self)
    if self._selected then
        if self._selected > 1 then
            self._selected = self._selected - 1
        else
            self._selected = #self._selections
        end
    end
end

function selection_box.select(self)
    if self._selected then
        self._selections[self._selected].callback()
    end
end

function selection_box.add_selection(self, text, callback)
    local new_index = #self._selections + 1
    if new_index == 1 then
        self._selected = 1
    end
    self._selections[new_index] = {text = text, callback = callback}

    return self._selections[new_index]
end

--------------------------------------------------------------------------------

function selection_box.get_height(self)
    local total_height = 0
    for i = 1, #self._selections, 1 do
        local this_height = love_utils.calculate_text_height(
            self._selections[i].text,
            fonts[self.font_name],
            self.width)        
        total_height = total_height + this_height
    end

    return total_height
end

function selection_box.get_n_selections(self)
    return #self._selections
end

function selection_box.get_selected(self)
    return self._selected
end
--------------------------------------------------------------------------------

function selection_box.draw(self)
    local r, g, b, a = love.graphics.getColor()
    local last_height = self.y
    for i = 1, #self._selections, 1 do
        if( i == self._selected ) then
            love.graphics.setColor(unpack(self.color_selected))
        else
            love.graphics.setColor(unpack(self.color))
        end
        love.graphics.printf(
            self._selections[i].text,
                fonts[self.font_name],
                self.x,
                last_height,
                self.width,
                self.align)

        local this_height = love_utils.calculate_text_height(
            self._selections[i].text,
            fonts[self.font_name],
            self.width)

        last_height = last_height + this_height
    end
    love.graphics.setColor(r, g, b, a)
end

function selection_box.reset(
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
    self._self_selected = nil -- will be started by selection_box.add_selection
end

function selection_box.resize(self, x, y, width)
    self.x = x
    self.y = y
    self.width = width
end

--------------------------------------------------------------------------------

function selection_box.new(font_name, x, y, width, align, color, color_selected)
    local o = {}

    -- methods
    utils.assign_methods(o, selection_box)
    -- o.draw = selection_box.draw
    -- o.add_selection = selection_box.add_selection
    -- o.up = selection_box.up
    -- o.down = selection_box.down
    -- o.select = selection_box.select    
    -- o.reset = selection_box.reset
    -- o.resize = selection_box.resize
    -- o.get_height = selection_box.get_height
    
    o:reset(font_name, x, y, width, align, color, color_selected)

    return o
end

return selection_box
