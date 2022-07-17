local array = {}

function array.shuffle(array)
	-- shuffles an array
	-- utils seeds the rng on load

	for i=1,#array, 1 do
		local j = math.random(1, #array)
		array[i], array[j] = array[j], array[i]
	end
end

function array.read_from_string(str, separator)
	-- Supports strings, booleans and numbers
	-- The functions reads any alfanumeric value and the dot,
	-- if the value can be parsed to a number or a boolean it will be,
	-- it is a string otherwise.

	local separator = separator or ','
	local match_string = table.concat({"%s*([%w%.]+)%s*", separator, '?'})

	local array = {}
	local index = 0

	for item in str:gmatch(match_string) do
		index = index + 1
		array[index] = tonumber(item) or qpd.value.string_maybe_bool(item)
	end

	return array
end

function array.print(array, separator)
	local separator = separator or ','
	for index, value in ipairs(array) do
		if index == #array then
			io.write(tostring(value), '\n')
		else
			io.write(tostring(value), separator)
		end
	end
end

function array.print_types(array, separator)
	local separator = separator or ','
	for index, value in ipairs(array) do
		if index == #array then
			io.write(tostring(value), ' type:', type(value), '\n')
		else
			io.write(tostring(value), ' type: ', type(value), separator, ' ')
		end
	end
end

return array