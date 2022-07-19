-- Guilherme Cunha Prada 2022

local random = {}

random.random = math.random

function random.seed(seed)
	math.randomseed(seed or os.time())
end

function random.choose(...)
	local choices = {...}
	local choice = math.random(1, #choices)
	return choices[choice]
end

function random.choose_list(choices_list)
	local choice = math.random(1, #choices_list)
	return choices_list[choice]
end

function random.zero_or_one()
	return random.choose(0, 1)
end

random.seed()

return random