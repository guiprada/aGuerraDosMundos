local tilemap = {}

local qpd_table = require "qpd.table"
local qpd_matrix = require "qpd.matrix"
local qpd_value = require "qpd.value"

--------------------------------------------------------------------------------

function tilemap.new(x, y, matrix, draw_functions)
	local o = {}
	o.x = x
	o.y = y
	o.matrix = matrix
	o.draw_functions = draw_functions

	o.tile_width = #matrix[1]
	o.tile_height = #matrix

	qpd_table.assign_methods(o, tilemap)
	return o
end

--------------------------------------------------------------------------------

function tilemap.draw(self, tilesize, matrix_start_x, matrix_start_y, matrix_end_x, matrix_end_y)
	if matrix_start_x and matrix_start_y and matrix_end_x and matrix_end_y then
		--print(matrix_end_x - matrix_start_x, matrix_end_y - matrix_start_y)
		for n_column = matrix_start_y, matrix_end_y, 1 do
			local this_column = self.matrix[n_column]
			for n_line = matrix_start_x, matrix_end_x, 1 do
				local value = this_column[n_line]
				local func = self.draw_functions[value]
				if func then
					local this_x = (n_line - 1) * tilesize + self.x
					local this_y = (n_column - 1)* tilesize + self.y
					func(   this_x,
							this_y,
							tilesize)
				elseif value ~= nil and value~=0 then
					print("draw function for: " .. value .. " not found!")
				end
			end
		end
	else
		for n_line, line in ipairs(self.matrix) do
			for n_column, value in ipairs(line) do
				local func = self.draw_functions[value]
				if func then
					func(
						(n_column - 1) * tilesize + self.x,
						(n_line - 1)* tilesize + self.y,
						tilesize)
				else
					if value ~= 0 then
						print("draw function for: " .. value .. " not found!")
					end
				end
			end
		end
	end
end

function tilemap.change_matrix(self, new_val, x, y)
	self.matrix[y][x] = qpd_value.clamp(new_val, 0, #self.draw_functions)
end

function tilemap.save(self, filepath)
	qpd_matrix.write_to_file(self.matrix, filepath, ',')
end

function tilemap.add_top(self)
	for i = #self.matrix, 1, -1 do
		self.matrix[i+1] = self.matrix[i]
	end
	self.matrix[1] = {}
	for i = 1, #self.matrix[2], 1 do
		self.matrix[1][i] = 0
	end
end

function tilemap.add_bottom(self)
	local new_index = #self.matrix + 1
	self.matrix[new_index] = {}
	for i = 1, #self.matrix[1], 1 do
		self.matrix[new_index][i] = 0
	end
end

function tilemap.add_right(self)
	local new_index = #self.matrix[1] + 1
	for i = 1, #self.matrix, 1 do
		self.matrix[i][new_index] = 0
	end
end

function tilemap.add_left(self)
	for i = 1, #self.matrix, 1 do
		table.insert( self.matrix[i], 1, 0)
	end
end

return tilemap