local timer = {}

local utils = require "qpd.utils"

--------------------------------------------------------------------------------

function timer.reset(self, duration, callback)
    self.duration = duration or self.duration
    self.callback = callback or self.callback
    self._timer = self.duration
end

function timer.update(self, dt)
    self._timer = self._timer - dt
    if self._timer <= 0 then
        self.callback()
    end
end

function timer.get_timer(self)
    return self._timer
end

--------------------------------------------------------------------------------

function timer.new(duration, callback)
    local o = {}

    utils.assign_methods(o, timer)

    o:reset(duration, callback)
    return o
end

return timer
