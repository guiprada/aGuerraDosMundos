local camera = {}
local utils = require "qpd.utils"

local pvt = {} -- private functions

--------------------------------------------------------------------------------

function pvt.apply(self)
    love.graphics.push()

    -- back up scissor values
    self._bsx, self._bsy, self._bsw, self._bsh = love.graphics.getScissor()

    love.graphics.setScissor(self._v_x, self._v_y, self._v_w, self._v_h)

	-- center it
    love.graphics.translate(
        self._v_x+self._v_w/2,
        self._v_y+self._v_h/2)

    -- and transform
    love.graphics.scale(self._scale, self._scale)
    love.graphics.translate(
        -self._drift_x,
        -self._drift_y)
end

function pvt.unapply(self)
    love.graphics.pop()
    love.graphics.setScissor(self._bsx, self._bsy, self._bsw, self._bsh)
end

------------------------------------------------------------------------- public

function camera.draw(self, func)
    pvt.apply(self)
    func()
    pvt.unapply(self)
end

function camera.get_viewport(self)
    return self._v_x, self._v_y, self._v_w, self._v_h
end

function camera.set_scale(self, new_scale)
    self._scale = utils.clamp(new_scale, self._min_scale, self._max_scale)
end

function camera.get_scale(self)
    return self._scale
end

function camera.set_center(self, x, y)
    self._drift_x = x
    self._drift_y = y
end

function camera.get_center(self)
    return  self._drift_x, self._drift_y
end

function camera.get_visible_quad(self)    
    local start_x = self._drift_x - self._w/2--/self._scale
    local start_y = self._drift_y - self._h/2--/self._scale
    local end_x = self._drift_x + self._w/2--/self._scale
    local end_y = self._drift_y + self._h/2--/self._scale

    return start_x, start_y, end_x, end_y
end

function camera.move(self, x, y)
    self._drift_x = utils.clamp(
        self._drift_x + x,
        self._v_x + (self._v_w/2)/self._scale,
        self._v_w - (self._v_w/2)/self._scale)                              
                                
    self._drift_y = utils.clamp(
        self._drift_y + y,
        self._v_y + (self._v_h/2)/self._scale,
        self._v_h - (self._v_h/2)/self._scale)                              
    
end

--------------------------------------------------------------------------------

function camera.new(w, h, min_scale, max_scale)
    local o = {}

    utils.assign_methods(o, camera)

    o:reset(w, h, min_scale, max_scale)

    return o
end

function camera.reset(self, w, h, min_scale, max_scale)

    self._drift_x = w/2
    self._drift_y = h/2
    self._offset_x = 0
    self._offset_y = 0
    self._w = w
    self._h = h
    self._scale = 1
    self._min_scale = min_scale or self._min_scale or 1
    self._max_scale = max_scale or self._max_scale or 1

    camera.set_viewport(
        self,
        0,
        0,
        love.graphics.getWidth(),
        love.graphics.getHeight())
end

function camera.set_viewport(self, x, y, w, h)
    self._v_x = x
    self._v_y = y
    self._v_w = w
    self._v_h = h
end

return camera
