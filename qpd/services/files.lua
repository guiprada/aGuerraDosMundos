local files = {}

local qpd_table = require "qpd.table"

function files.load(path)
	local file_paths = qpd_table.read_from_conf(path, "=")
	assert(
		file_paths,
		"files.load() could not read its configuration file: " .. path)

	for key, value in pairs(file_paths) do
		files[key] = value
	end
end

return files