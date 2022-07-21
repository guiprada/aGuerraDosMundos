local Population = require "entities.Population"
local qpd = require "qpd.qpd"

local GeneticPopulation = {}
GeneticPopulation.__index = GeneticPopulation
qpd.table.assign_methods(GeneticPopulation, Population)

function GeneticPopulation:new(class, active_size, population_size, new_table, reset_table, o)
	local o = o or {}
	setmetatable(o, self)

	o._class = class
	o._population_size = population_size
	o._random_init = population_size
	o._reset_table = reset_table

	o._population = {}
	o._history = {}
	o._history_fitness_sum = 0
	o._count = 0

	for i = 1, active_size do
		o._population[i] = class:new(new_table)
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

function GeneticPopulation:selection()
	-- local mom = qpd.table.get_highest(self._population, "_fitness")
	local mom_table = self._population
	table.sort(mom_table, function(a,b) return a._fitness > b._fitness end)
	if mom_table[1]._fitness < mom_table[#mom_table]._fitness then
		print("error sorting by fitness")
	end
	local max_index = 5
	if max_index > #mom_table then
		max_index = #mom_table
	end
	local mom_index_list = {}
	for i = 1, max_index do
		mom_index_list[i] = i
	end

	local mom_index = qpd.random.choose_list(mom_index_list)
	local mom = mom_table[mom_index]

	local randFloatDad = self._history_fitness_sum * qpd.random.random()
	local sum = 0
	local dad
	for i = 1, #self._history do
		local this = self._history[i]
		sum = sum + this._fitness
		if (sum >= randFloatDad) then
			dad = this
		end
		if mom and dad then
			return mom, dad
		end
	end

	print("Error in population selection!")
	mom = mom or self._history[#self._history]
	dad = dad or self._history[#self._history]

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

return GeneticPopulation