local Population = {}
Population.__index = Population

function Population:new(class, population_size, new_table, reset_table, o)
	local o = o or {}
	setmetatable(o, self)

	o._class = class
	o._population_size = population_size
	o._reset_table = reset_table

	o._count = 0
	o._population = {}

	for i = 1, population_size do
		o._population[i] = class:new(new_table)
		o._population[i]:reset(o._reset_table)
		o._count = o._count + 1
	end

	return o
end

function Population:draw()
	for i = 1, #self._population do
		self._population[i]:draw()
	end
end

function Population:replace(i)
	self._count = self._count + 1

	self._population[i]:reset(self._reset_table)
end

function Population:update(dt, ...)
	for i = 1, #self._population do
		local this = self._population[i]
		if this._is_active == false then
			self:replace(i)
		else
			this:update(dt, ...)
		end
	end
end

function Population:get_population()
	return self._population
end

function Population:get_reset_table()
	return self._reset_table
end

function Population:get_count()
	return self._count
end

return Population