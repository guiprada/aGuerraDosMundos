local keymap = {}
local utils = require "qpd.utils"

function keymap.load(path)    
    local map = utils.table_read_from_conf(path, "=")
    assert(
        map ~= nil,
        "keymap.load() could not read its configuration file: " .. path)

    keymap.keys = {}
    for key, value in pairs(map) do
        keymap.keys[key] = value
    end
end

function keymap.save(keymap, path)
    utils.table_write_to_file(keymap, path, "=")
end

return keymap