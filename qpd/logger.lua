local logger = {}
logger.__index = logger

function logger:new(file_path, columns, autoflush_limit, o)
	local o = o or {}
	setmetatable(o, self)

	o._file_path = file_path

	local file, err = io.open(o._file_path, "w")
	if file then
		o._file = file
	else
		print("[ERROR] - logger:new() - Error creating file:", o._file_path,". io.open() returned:", err)
		return nil
	end

	o._columns = columns
	for i = 1, #columns do
		local this_column = columns[i]
		if i == 1 then
			o._file:write(this_column)
		else
			o._file:write(", ", this_column)
		end
	end
	o._file:write("\n")
	o._file:flush()

	if autoflush_limit then
		o._autoflush_limit = autoflush_limit
	end

	o._dirty_counter = 0

	return o
end

function logger:log(log_table)
	for i = 1, #self._columns do
		local this_column = self._columns[i]

		local this_value = log_table[this_column] or "null"
		if i == 1 then
			self._file:write(this_value)
		else
			self._file:write(", ", this_value)
		end
	end
	self._file:write("\n")
	self._dirty_counter = self._dirty_counter + 1

	if self._autoflush_limit then
		if self._dirty_counter > self._autoflush_limit then
			self:flush()
		end
	end
end

function logger:flush()
	self._file:flush()
	self._dirty_counter = 0
end

return logger