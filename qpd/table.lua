local qpd_table = {}

local qpd_value = require "qpd.value"

function qpd_table.assign_methods(self, class)
	for key, value in pairs(class) do
		if type(class[key]) == "function" and key ~= "new" then
			self[key] = value
		end
	end
end

function qpd_table.average(tables, indexer)
	-- Returns the average of parameter indexer of a list of tables.
	-- tables is an table of tables
	local length = #tables
	local average = 0

	for _, value in pairs(tables) do
		average = average + value[indexer]/length
	end

	return average
end

function qpd_table.std_deviation(tables, indexer)
	-- Returns the std_deviation of parameter indexer of a list of tables.
	-- tables is an table of tables
	local lenght = #tables
	local sum = 0

	local average = qpd_table.average( tables, indexer )

	for key, value in pairs(tables) do
		sum = sum + (value[indexer] - average)^2
	end

	local std_dev = sum^(1/2)
	return std_dev
end

function qpd_table.read_from_data(filepath, separator)
	-- Creates a table from a file with format
	-- key separator value ==> new_table[key] = value
	-- Supports numbers and strings for keys and values,
	-- but keys cant be utf8 strings
	-- Supports multiline strings between quotes, double or single.
	-- Supports nested quotes as long as they are diferent from,
	-- the external one used.
	-- New lines are scaped and "\n" should be used to split lines.
	-- Separator should be different of magic characters ^$()%.[]*+-?
	-- or scaped width %
	-- default separator is '='

	local separator = separator or '='
	local new_table = {}

	local file, err = io.open(filepath, "r")
	if not file or err then
		print(err)
		new_table = nil
	else
		local next = file:read(1)
		while(next ~= nil)do
			-- find name
			local name =  ""
			while next ~= separator do
				name = name .. next
				next = file:read(1)
			end
			name = name:gsub("%s", "") -- trim

			-- find string first quote
			while next ~= '"' and next ~= '\'' do
				next = file:read(1)
			end
			local str = ""
			local delimiter = next -- save delimiter used

			next = file:read(1) -- advance
			while next ~= delimiter do
				if next == '\\' then -- unescape \n
					local next_next = file:read(1)
					if next_next == 'n' then
						str = str .. '\n'
					else
						str = str .. next
						file:seek("cur", -1) -- backtrack
					end
				elseif next == '\n' then -- escape '/n'
					--str = str .. ' ' do nothing
				else -- the rest
					str = str .. next
				end
				next = file:read(1) -- advance
			end
			new_table[name] = str
			next = file:read(1) -- advance
		end
		io.close(file)
	end

	return new_table, err
end

function qpd_table.read_from_conf(filepath, separator)
	-- Creates a table from a file with format
	-- key separator value ==> new_table[key] = value
	-- Supports numbers and strings for keys, but keys cant be utf8 strings
	-- Values can be strings, utf8 strings, numbers or booleans
	-- Separator should be different of magic characters ^$()%.[]*+-?
	-- or scaped width %
	-- default separator is '='

	local separator = separator or '='

	local match_string = table.concat({"%s*(%g+)%s*", separator, "%s*(.*)"})
	local new_table = {}

	local file, err = io.open(filepath, 'r')
	if not file or err then
		print(err)
		new_table = nil
	else
		for line in file:lines() do
			if line ~= "" then
				local key, value =  string.match(line, match_string)
				key = tonumber(key) or key

				value = tonumber(value) or qpd_value.string_maybe_bool(value)
				new_table[key] = value
			end
		end
		io.close(file)
	end

	return new_table, err
end

function qpd_table.write_to_file(this_table, filepath, separator)
	local separator = separator or '='

	local out_file, err = io.open(filepath, "w+")
	if not out_file or err then
		print(err)
	else
		for key, value in pairs(this_table) do
			local data = table.concat({
				key,
				" ",
				separator,
				" ",
				tostring(value),
				'\n'})

			out_file:write(data)
		end
		io.close(out_file)
	end

	return err
end

function qpd_table.clone(source, dest)
	local dest = dest or {}
	for k, value in pairs(source) do
		if(type(value) == "table")then
			dest[k] = {}
			qpd_table.table_set(value, dest[k])
		else
			dest[k] = value
		end
	end

	return dest
end

function qpd_table.print(this_table)
	for key, value in pairs(this_table) do
		if type(value) == "table" then
			print("{ ")
			qpd_table.print(value)
			print(" }")
		else
			print(key, ": ", tostring(value))
		end
	end
end

return qpd_table