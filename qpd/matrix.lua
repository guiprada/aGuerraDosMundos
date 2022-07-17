local matrix = {}

local qpd_array = require "qpd.array"

function matrix.read_from_string(str, separator)
	-- The functions reads any alfanumeric value and the dot,
	-- if the value can be parsed to a number or a boolean it will be,
	-- it is a string otherwise.

	local matrix = {}
	local n_line = 0
	local separator = separator or ','

	local match_line = "(.-)\n"

	for line in str:gmatch(match_line) do
		if line ~= "" then
			n_line = n_line + 1
			matrix[n_line] = qpd_array.read_from_string(line, separator)
		end
	end

	return matrix
end

function matrix.read_from_file(filepath, separator)
	-- The functions reads any alfanumeric value and the dot,
	-- if the value can be parsed to a number or a boolean it will be,
	-- it is a string otherwise.
	local matrix = {}
	local n_line = 0
	local separator = separator or ','

	local file, err = io.open(filepath, 'r')
	if not file or err then
		print(err)
		matrix = nil
	else
		for line in file:lines() do
			if line ~= "" then
				n_line = n_line + 1
				matrix[n_line] = qpd_array.read_from_string(line, separator)
			end
		end
		file:close()
	end

	return matrix, err
end

function matrix.write_to_file(matrix, filepath, separator)
	local separator = separator or ' '

	local file, err

	if filepath then
		file, err = io.open(filepath, "w+")
	end

	if not file or err then
		print("Error writing matrix to file")
	else
		for _, line in ipairs(matrix) do
			for index_c, item in ipairs(line) do
				if index_c == #line then -- last one
					file:write(item)
				else
					file:write(item, separator, ' ')
				end
			end
			file:write('\n')
		end
		file:close()
	end

	return err
end

return matrix