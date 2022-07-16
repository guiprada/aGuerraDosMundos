local timer = {}

local utils = require "qpd.utils"

--------------------------------------------------------------------------------

function timer.reset(self, duration, callback)
	self.enabled = true
	self.duration = duration or self.duration
	self.callback = callback or self.callback
	self._timer = self.duration
end

function timer.update(self, dt)
	self._timer = self._timer - dt
	if self.enabled and self._timer <= 0 then
		self.callback()
		self.enabled = false
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
	o.enabled = false
	return o
end

return timer
