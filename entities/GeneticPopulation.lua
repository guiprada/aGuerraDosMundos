local Population = require "entities.Population"
local qpd = require "qpd.qpd"

local GeneticPopulation = {}
GeneticPopulation.__index = GeneticPopulation
qpd.table.assign_methods(GeneticPopulation, Population)

function GeneticPopulation:new(class, active_size, population_size, new_table, reset_table, o)
	local o = o or {}
	setmetatable(o, self)

	o._class = class
	o._active_size = active_size
	o._population_size = population_size
	o._random_init = population_size
	o._new_table = o._new_table
	o._reset_table = reset_table

	o._population = {}
	o._history = {}
	o._history_fitness_sum = 0
	o._count = 0

	for i = 1, o._active_size do
		o._population[i] = o._class:new(o._new_table)
		o._population[i]:reset(o:get_reset_table())
		o._count = o._count + 1
	end

	return o
end

function GeneticPopulation:add_to_history(this)
	local this_history = this:get_history()

	if #self._history > math.floor(self._population_size/10) then
		local lowest, lowest_index = qpd.table.get_lowest(self._history, "_fitness")

		if this_history._fitness > lowest._fitness then
			self._history_fitness_sum = self._history_fitness_sum - lowest._fitness

			self._history[lowest_index] = this_history
			self._history_fitness_sum = self._history_fitness_sum + this_history._fitness
		end
	else
		table.insert(self._history, this_history)
		self._history_fitness_sum = self._history_fitness_sum + this_history._fitness
	end
end

local function roulette(population, total_fitness)
	local total_fitness = total_fitness or qpd.table.sum(population, "_fitness")
	local randFloat = total_fitness * qpd.random.random()
	local sum = 0
	for i = 1, #population do
		local this = population[i]
		sum = sum + this._fitness
		if (sum > randFloat) then
			return this
		end
	end
end

function GeneticPopulation:selection()
	local everybody = qpd.table.clone(self._history)
	qpd.table.merge(everybody, self._population)
	local mom = roulette(everybody)
	local dad = roulette(everybody)
	if not (mom and dad) then
		print("Error in population selection!")
		mom = mom or self._history[#self._population]
		dad = dad or self._history[#self._history]
	end

	return mom, dad
end

function GeneticPopulation:replace(i)
	self._count = self._count + 1
	self:add_to_history(self._population[i])

	if self._random_init > 0 then
		self._random_init = self._random_init - 1
		self._population[i]:reset(self:get_reset_table())
	else
		-- find parents
		local mom, dad = self:selection()

		-- cross
		self._population[i]:crossover(mom, dad, self:get_reset_table())
	end
end

function GeneticPopulation:add_active()
	self._active_size = self._active_size + 1
	local i = self._active_size
	self._population[i] = self._class:new(self._new_table)

	if self._random_init > 0 then
		self._random_init = self._random_init - 1
		self._population[i]:reset(self:get_reset_table())
	else
		-- find parents
		local mom, dad = self:selection()
		-- cross
		self._population[i]:crossover(mom, dad, self:get_reset_table())
	end
end

return GeneticPopulation