-- Guilherme Cunha Prada 2020
local GridActor = require "entities.GridActor"
local Pill = GridActor:new()
Pill.__index = Pill

local pill_type_name = "pill"

local qpd = require "qpd.qpd"

function Pill.init(grid, got_pill_update_callback, time_left_update_callback)
	Pill.pills_active = true
	Pill.grid = grid
	Pill.got_pill_update = got_pill_update_callback
	Pill.time_left_update = time_left_update_callback

	GridActor.register_type(pill_type_name)
end

local function pill_warning()
	-- STUB
end

local function timer_end_callback(pill)
	pill:effect_off()
end

function Pill:new(new_table, o)
	local o = GridActor:new(o or {})
	setmetatable(o, self)

	o._timer = qpd.timer.new(new_table.pill_time, timer_end_callback, o)

	o._type = GridActor.get_type_by_name(pill_type_name)

	o:reset()

	return o
end

function Pill:reset()
	GridActor.reset(self, Pill.grid:get_valid_cell())

	self._timer:reset()

	self._in_effect = false

	self.x = self.x + qpd.random.random(math.ceil(-GridActor.get_tilesize() * 0.17), math.ceil(GridActor.get_tilesize() * 0.17))
	self.y = self.y + qpd.random.random(math.ceil(-GridActor.get_tilesize() * 0.17), math.ceil(GridActor.get_tilesize() * 0.17))
end

function Pill:is_type(type_name)
	if type_name == pill_type_name then
		return true
	else
		return false
	end
end

function Pill:draw()
	if (Pill.pills_active) then
		love.graphics.setColor(138/255,43/255,226/255, 0.9)
		love.graphics.circle("fill", self.x, self.y, GridActor.get_tilesize() * 0.3)
	end
end

function Pill:collided(other)
	if (Pill.pills_active) then
		if other:is_type("player") then
			self:effect_on()
			-- if other.got_pill then
			-- 	other:got_pill()
			-- end
		end
	end
end

function Pill:update(dt, ...)
	GridActor.update(self, dt, ...)
	if Pill.pills_active then
		Pill.grid:update_collision(self)
	else
		if self:is_in_effect() then
			self._timer:update(dt)
			local remaining_time = self._timer:get_remaining_time()
			if (remaining_time< 1) then
				pill_warning()
			end
			Pill.time_left_update(remaining_time)
		end
	end
end

function Pill:time_left()
	return self._timer:get_remaining_time()
end

function Pill:is_in_effect()
	return self._in_effect
end

function Pill:effect_on()
	Pill.pills_active = false
	Pill.got_pill_update(true)
	self._in_effect = true
	self._timer:reset()
end

function Pill:effect_off()
	Pill.pills_active = true
	Pill.got_pill_update(false)
	self._in_effect = false
	self:reset()
	Pill.time_left_update(self._timer:get_remaining_time())
end

function Pill:is_active()
	return self._is_active
end

return Pill
