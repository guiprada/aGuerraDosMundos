local particle = {}

local qpd_table = require "qpd.table"

function particle.reset(self)
	self.timer = love.math.random(self.min_duration, self.max_duration)
	self.max_timer = self.timer

	self.x =
		self.spawn_rect.x + love.math.random(1, self.spawn_rect.width)

	self.y =
		self.spawn_rect.y + love.math.random(1, self.spawn_rect.height)

	self.color = {}
	self.color.r = love.math.random()
	self.color.g = love.math.random()
	self.color.b = love.math.random()
	self.color.a = 1
end

function particle.update(self, dt)
	if self.timer > 0 then
		self.timer = self.timer - dt
	else
		particle.reset(self)
	end
end

function particle.draw(self)
	local decay = (self.timer/self.max_timer)
	local r, g, b, a = love.graphics.getColor()
	love.graphics.setColor(
		self.color.r,
		self.color.b,
		self.color.b,
		self.color.a * decay)

	love.graphics.circle('fill', self.x, self.y, self.max_size * decay)
	love.graphics.setColor(r, g, b, a)
end

--------------------------------------------------------------------------------

function particle.new(settings)
	local o = {}

	o.spawn_rect = settings.spawn_rect or {
		x = 0,
		y = 0,
		width = love.graphics.getWidth(),
		height = love.graphics.getHeight()}

	o.max_size = love.math.random(1, settings.max_size)

	o.min_duration = settings.min_duration
	o.max_duration = settings.max_duration

	-- methods
	qpd_table.assign_methods(o, particle)

	o:reset()
	return o
end

return particle
