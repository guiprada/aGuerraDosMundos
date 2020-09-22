local files = {}
local utils = require "qpd.utils" 

function files.load(path)
    local file_paths = utils.table_read_from_conf(path, "=")
    assert(
        file_paths,
        "files.load() could not read its configuration file: " .. path)

    for key, value in pairs(file_paths) do
        files[key] = value
    end
end

-- local this_path = ...
-- local this_folder = this_path:match("(.-)[^%.]+$")
-- this_folder = string.gsub(this_folder, "%.", "/")
-- files.load(this_folder .. "files.conf")

return files