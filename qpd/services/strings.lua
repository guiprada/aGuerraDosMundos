local strings = {}

local qpd_table = require "qpd.table"

function strings.load(path)
	local read_strings = qpd_table.read_from_data(path)
	assert(
		read_strings,
		"strings.load() could not read its configuration file: " .. path)

	for key, value in pairs(read_strings) do
		strings[key] = value
	end
end

return strings