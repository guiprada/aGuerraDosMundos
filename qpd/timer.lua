local qpd_timer = {}

local qpd_table = require "qpd.table"
--------------------------------------------------------------------------------

function qpd_timer.reset(self, duration)
	self._enabled = true
	self._duration = duration or self._duration
	self._timer = self._duration
end

function qpd_timer.update(self, dt)
	if self._enabled then
		self._timer = self._timer - dt
		if self._timer <= 0 then
			self._callback()
			self._enabled = false
		end
	end
end

function qpd_timer.get_remaining_time(self)
	return self._timer
end

function qpd_timer.get_elapsed_time(self)
	return self:get_duration() - self:get_remaining_time()
end

function qpd_timer.get_duration(self)
	return self._duration
end

function qpd_timer.set_duration(self, value)
	self._duration = value
end

function qpd_timer.start(self)
	self._enabled = false
end

function qpd_timer.stop(self)
	self._enabled = true
end

--------------------------------------------------------------------------------

function qpd_timer.new(duration, callback)
	local o = {}
	qpd_table.assign_methods(o, qpd_timer)

	o._duration = duration
	o._callback = callback
	o._enabled = false

	return o
end

return qpd_timer
