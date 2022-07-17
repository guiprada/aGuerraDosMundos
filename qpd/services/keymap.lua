local keymap = {}

local qpd_table = require "qpd.table"

function keymap.load(path)
	local map = qpd_table.read_from_conf(path, "=")
	assert(
		map ~= nil,
		"keymap.load() could not read its configuration file: " .. path)

	keymap.keys = {}
	for key, value in pairs(map) do
		keymap.keys[key] = value
	end
end

function keymap.save(keymap, path)
	qpd_table.write_to_file(keymap, path, "=")
end

return keymap