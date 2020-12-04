local utils = {}

function utils.run_tests()
    print("Starting qpd.utils.run_tests()") 

    -- test clamp
    assert(
        utils.clamp(5, 1, 10) == 5,
        "error on utils.clamp, test 1")        
    assert(
        utils.clamp(0, 1, 10) == 1,
        "error on utils.clamp, test 2")    
    assert(
        utils.clamp(11, 1, 10) == 10,
        "error on utils.clamp, test 3")

    -- test normalize
    local x, y = utils.normalize(1, 1)
    assert(
        x == 1/(2^(1/2)) and y == 1/(2^(1/2)),
        "error on utils.normalize, test 1")

    local x, y = utils.normalize(-1, 2)
    assert(
        x == -1/(5^(1/2)) and y == 2/(5^(1/2)),
        "error on utils.normalize, test 2")

    local x, y = utils.normalize(100, -1)
    assert(
        x == 100/(10001^(1/2)) and y == -1/(10001^(1/2)),
        "error on utils.normalize, test 3")

    local x, y = utils.normalize(-10, -10)
    assert(
        x == -10/(200^(1/2)) and y == -10/(200^(1/2)),
        "error on utils.normalize, test 4")

    local x, y = utils.normalize(0, 0)
    assert(
        x == 0 and y == 0,
        "error on utils.normalize, test 5")
 
    local x, y = utils.normalize(0, 1)
    assert(
        x == 0 and y == 1,
        "error on utils.normalize, test 6")

    -- test max
    assert(
        utils.max(5, 1) == 5,
        "error on utils.max, test 1")
    assert(
        utils.max(1, 5) == 5,
        "error on utils.max, test 2")
    assert(
        utils.max(-5, 1) == 1,
        "error on utils.max, test 3")
    assert(
        utils.max(1, -5) == 1,
        "error on utils.max, test 4")
    assert(
        utils.max(-5, -1) == -1,
        "error on utils.max, test 5")
    assert(
        utils.max(-1, -5) == -1,
        "error on utils.max, test 6")
    
    -- test min
    assert(
        utils.min(5, 1) == 1,
        "error on utils.min, test 1")
    assert(
        utils.min(1, 5) == 1,
        "error on utils.min, test 2")
    assert(
        utils.min(-5, 1) == -5,
        "error on utils.min, test 3")
    assert(
        utils.min(1, -5) == -5,
        "error on utils.min, test 4")
    assert(
        utils.min(-5, -1) == -5,
        "error on utils.min, test 5")
    assert(
        utils.min(-1, -5) == -5,
        "error on utils.min, test 6")

    -- test round_2_dec
    assert(
        utils.round_2_dec(5) == 5,
        "error on utils.round_2_dec, test 1")
    assert(
        utils.round_2_dec(5.12345) == 5.12,
        "error on utils.round_2_dec, test 2")
    assert(
        utils.round_2_dec(5.125) == 5.13,
        "error on utils.round_2_dec, test 3")    
    
    assert(
        utils.round_2_dec(-5) == -5,
        "error on utils.round_2_dec, test 4")
    assert(
        utils.round_2_dec(-5.12345) == -5.12,
        "error on utils.round_2_dec, test 5")
    assert(
        utils.round_2_dec(-5.125) == -5.13,
        "error on utils.round_2_dec, test 6")
        
    assert(
        utils.round_2_dec(5.124999999999999) == 5.12,
        "error on utils.round_2_dec, test 7")       
    assert(
        utils.round_2_dec(5.125000000000000000000000000000000000000) == 5.13,
        "error on utils.round_2_dec, test 8")

    -- test number_2_bool
    assert(
        utils.number_2_bool(0) == false,
        "error on utils.number_2_bool, test 1")
    assert(
        utils.number_2_bool(1) == true,
        "error on utils.number_2_bool, test 2")
    assert(
        utils.number_2_bool(5) == nil,
        "error on utils.number_2_bool, test 3")     

    -- test string_2_bool
    assert(
        utils.string_2_bool("false") == false,
        "error on utils.string_2_bool, test 1")
    assert(
        utils.string_2_bool("true") == true,
        "error on utils.string_2_bool, test 2")
    assert(
        utils.string_2_bool(5) == nil,
        "error on utils.string_2_bool, test 3")   
    assert(
        utils.string_2_bool(true) == nil,
        "error on utils.string_2_bool, test 4")
    assert(
        utils.string_2_bool("Zaratrusta") == nil,
        "error on utils.string_2_bool, test 5")   

    -- test string_maybe_bool
    assert(
        utils.string_maybe_bool("false") == false,
        "error on utils.string_maybe_bool, test 1")
    assert(
        utils.string_maybe_bool("true") == true,
        "error on utils.string_maybe_bool, test 2")
    assert(
        utils.string_maybe_bool(5) == 5,
        "error on utils.string_maybe_bool, test 3")   
    assert(
        utils.string_maybe_bool(true) == true,
        "error on utils.string_maybe_bool, test 4")
    assert(
        utils.string_maybe_bool("Zaratrusta") == "Zaratrusta",
        "error on utils.string_maybe_bool, test 5")

    -- test utils.check_collision
    -- check_collision_quad() is just a wrapper for check_collision()
    local A = {x = 0, y = 0, w = 1, h = 1}
    local B = {x = 0.5, y = 0.5, w = 1, h = 1}
    local C = {x = -0.5, y = -0.5, w = 1, h = 1}
    local D = {x = 1, y = 1, w = 1, h = 1}
    assert(
        utils.check_collision_quad(A, B) == true,
        "error on utils.check_collision, test 1")
    assert(
        utils.check_collision_quad(B, C) == true,
        "error on utils.check_collision, test 2")
    assert(
        utils.check_collision_quad(C, D) == false,
        "error on utils.check_collision, test 3")

    -- if we got here maybe things are ok
    print("qpd.utils.run_tests() says ok!")
end

--------------------------------------------------------------------- prototypes

function utils.assign_methods(self, class)
    for key, value in pairs(class) do        
        if type(class[key]) == "function" and key ~= "new" then
            self[key] = class[key]
        end
    end
end

------------------------------------------------------------------------- values

function utils.clamp(value, min_value, max_value)
    -- Clamps value between min_value and max_value.
    if value > max_value then
        return max_value
    elseif value < min_value then
        return min_value
    end

    return value
end

function utils.max(x, y)
    -- Returns the greatest value amongst x and y.

    return x > y and x or y
end

function utils.min(x, y)
    -- Returns the smallest value amongst x and y.
    return x < y and x or y
end

function utils.round(x)
    if x>0 then
        if math.fmod(x, 1) >= 0.5 then return math.ceil(x)
        else return math.floor(x) end
    else
        if math.fmod(x, 1) >= 0.5 then return math.floor(x)
        else return math.ceil(x) end
    end
end

function utils.round_2_dec(value)
    -- Rounds floating point number to 2 decimal places.
    if ( value >= 0 ) then
        local rounded = math.floor(value*100)/100        
        
        if (1000*value - 1000*rounded) >= 5 then
            rounded = rounded + 0.01
        end        
        
        return rounded
    else
        local rounded = math.ceil(value*100)/100     
           
        if (1000*value - 1000*rounded) <= -5 then
            rounded = rounded - 0.01
        end        
        
        return rounded		
	end
end

function utils.number_2_bool(value)
    -- Converts a "C" style boolean number to a Boolean type.
    -- O is converted to false, 1 is converted to true, else it returns nil.
    if value == 0 then
        return false
    elseif value == 1 then
        return true
    end

    return nil
end

function utils.string_2_bool(value)
    -- Converts a boolean string to a Boolean type.
    -- "false" is converted to false, "true" is converted to true,
    -- returns nil for any other value.

    if(value == "true")then
        return true
    elseif(value == "false")then
        return false
    end

    return nil
end

function utils.string_maybe_bool(value)
    -- Converts a boolean string to a Boolean type.
    -- "false" is converted to false, "true" is converted to true,
    -- returns the same value for any other value.
    if value == "true" then
        return true
    elseif value == "false" then
        return false
    end

    return value
end

---------------------------------------------------------------------- collision

function utils.check_collision(x1,y1,w1,h1, x2,y2,w2,h2)
    -- Checks if the quads are in collision.
    return  x1 <= x2+w2 and x2 <= x1+w1 and y1 <= y2+h2 and y2 <= y1+h1
end

function utils.check_collision_quad(h1, h2)
    return utils.check_collision(h1.x, h1.y, h1.w, h1.h, h2.x, h2.y, h2.w, h2.h)
end

function utils.check_collision_center(x1, y1, s1, x2, y2, s2)
    return utils.check_collision(   x1 - s1/2, y1 - s1/2, s1, s1,
                                    x2 - s2/2, y2 - s2/2, s2, s2)
end

function utils.check_collision_circle(x1, y1, r1, x2, y2, r2)
    local distance = utils.distance({x = x1, y = y1},{x = x2, y = y2})
    return (r1+r2) > distance
end
------------------------------------------------------------------------- points

function utils.distance(p1, p2)
    -- Calculates the distance between points p1 and p2.
    return ( (p1.x - p2.x)^2 + (p1.y - p2.y)^2 )^0.5
end

function utils.middle_point(p1, p2)
    -- Calculates the middle point between p1 and p2.
	local middle = {}
	middle.x = (p1.x + p2.x)/2
	middle.y = (p1.y +p2.y)/2
	return middle
end

function utils.normalize( x, y)
    local norm = (x^2 + y^2)^(1/2)
    if norm ~= 0 then
        return x/norm, y/norm
    else
        return 0, 0
    end
end

function utils.lerp(p1, p2, distance)
    local p = {x = p2.x - p1.x, y = p2.y - p1.y}
    p.x, p.y = utils.normalize(p.x, p.y)
    p.x, p.y = p.x * distance, p.y * distance
    if utils.distance(p1, p2) <= distance then
        return p2.x, p2.y, true
    else
        return p1.x + p.x, p1.y + p.y, false
    end
end

function utils.lerp_rotation(o1, o2, step)
    -- shortest_angle=((((end - start) % 360) + 540) % 360) - 180;
    -- return start + (shortest_angle * amount) % 360;
    -- from https://stackoverflow.com/questions/2708476/rotation-interpolation

    local shortest_angle = (math.fmod((math.fmod(o2-o1, 2*math.pi) + 3*math.pi), 2*math.pi)) - math.pi
    if math.abs(shortest_angle) < step then
        return o2, true
    else
        return (o1 + math.fmod(shortest_angle * step, 2*math.pi)), false
    end
end

------------------------------------------------------------------------- tables

function utils.tables_average( tables, indexer)
	-- Returns the average of parameter indexer of a list of tables.
    -- tables is an table of tables
	local length = #tables
	local average = 0

    for _, value in pairs(tables) do
        average = average + values[indexer]/lenght
    end

	return average
end

function utils.tables_std_deviation(tables, indexer)
    -- Returns the std_deviation of parameter indexer of a list of tables.
    -- tables is an table of tables
	local lenght = #tables
	local sum = 0

	local average = utils.average( tables, indexer )

    for key, value in pairs(tables) do
        sum = sum + (value[indexer] - average)^2
    end

	local std_dev = sum^(1/2)
	return std_dev
end

-- function utils.tables_get_highest(tables, indexer)
--     -- Returns the table with highest value in the indexer parameter.
--     -- tables is an table of tables
-- 	local lenght = #tables
-- 	local highest = 1
-- 	for i=1, lenght, 1 do
-- 		if(tables[i][indexer]> tables[highest][indexer])then
-- 			highest = i
-- 		end
-- 	end
-- 	return tables[highest]
-- end

-- function utils.tables_get_lowest(tables, indexer)
--     -- Returns the table with lowest value in the indexer parameter.
--     -- tables is an table of tables
-- 	local lenght = #tables
-- 	local lowest = 1
-- 	for i=1, lenght, 1 do
-- 		if(tables[i][indexer] < tables[lowest][indexer])then
-- 			lowest = i
-- 		end
-- 	end
-- 	return tables[lowest]
-- end

-- function utils.tables_get_n_best(tables, indexer, n)
--     -- Returns n tables with highest values in the indexer parameter.
--     -- tables is an table of tables.
--     -- this is not eficient at all!!!
-- 	local copy = {}
-- 	for i=1, #tables, 1 do
-- 		copy[i]= tables[i]
-- 	end
-- 	local highest_stack = {}

-- 	local limit = n
-- 	if (#tables < limit) then
-- 		limit = #tables
-- 	end
-- 	for i=1, limit, 1 do
-- 		local new_top_index = utils.get_highest_index(copy, indexer)
-- 		table.insert(highest_stack, tables[new_top_index])
-- 		table.remove(copy, new_top_index)
-- 	end
-- 	return highest_stack
-- end

-------------------------------------------------------------------------- table

-- function utils.table_remove_value(this_table, value)
--     -- will remove all ocurences of value in the table
-- 	for i, item in pairs(this_table) do
-- 		if item == value then
-- 			table.remove(this_table, i)
-- 		end
-- 	end
-- end

function utils.table_read_from_data(filepath, separator)
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
    if err then
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
    end

    if file then io.close(file) end

    return  new_table, err
end

function utils.table_read_from_conf(filepath, separator)
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
    if err then
        print(err)
        new_table = nil
    else
        for line in file:lines() do
            if line ~= "" then
                local key, value =  string.match(line, match_string)
                key = tonumber(key) or key

                value = tonumber(value) or utils.string_maybe_bool(value)
                new_table[key] = value
            end
        end
    end

    if file then io.close(file) end

    return  new_table, err
end

function utils.table_write_to_file(this_table, filepath, separator)
    local separator = separator or '='

    local out_file, err = io.open(filepath, "w+")
    if err then
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
    end

    if out_file then io.close(out_file) end

    return err
end

function utils.table_set(source, dest)
    for k, value in pairs(source) do
        if(type(value) == "table")then
            dest[k] = {}
            utils.table_set(value, dest[k])
        else
            dest[k] = value
        end
    end
end

function utils.table_clone(source)
    local clone = {}
    utils.table_set(source, clone)

    return clone
end

function utils.table_print(this_table)
    for key, value in pairs(this_table) do
        if type(value) == "table" then
            print("{ ")
            utils.table_print(value)
            print(" }")
        else
            print(key, ": ", tostring(value))
        end
    end
end

------------------------------------------------------------------------- arrays

function utils.array_shuffler(array)
    -- shuffles an array

    math.randomseed( os.time() )
	for i=1,#array, 1 do
		local j = math.random(1, #array)
		array[i], array[j] = array[j], array[i]
	end
end

function utils.array_read_from_string(str, separator)
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
        array[index] = tonumber(item) or utils.string_maybe_bool(item)
    end

    return array
end

function utils.array_print(array, separator)
    local separator = separator or ','
    for index, value in ipairs(array) do
        if index == #array then
            io.write(tostring(value), '\n')
        else
            io.write(tostring(value), separator)
        end
    end
end

function utils.array_print_types(array, separator)
    local separator = separator or ','
    for index, value in ipairs(array) do
        if index == #array then
            io.write(tostring(value), ' type:', type(value), '\n')
        else
            io.write(tostring(value), ' type: ', type(value), separator, ' ')
        end
    end
end

--------------------------------------------------------------------------matrix

function utils.matrix_read_from_string(str, separator)
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
            matrix[n_line] = utils.array_read_from_string(line, separator)
        end
    end

    return matrix
end

function utils.matrix_read_from_file(filepath, separator)
    -- The functions reads any alfanumeric value and the dot,
    -- if the value can be parsed to a number or a boolean it will be,
    -- it is a string otherwise.
    local matrix = {}
    local n_line = 0
    local separator = separator or ','

    local file, err = io.open(filepath, 'r')
    if err then
        print(err)
        matrix = nil
    else
        for line in file:lines() do
            if line ~= "" then
                n_line = n_line + 1
                matrix[n_line] = utils.array_read_from_string(line, separator)
            end
        end
    end

    if file then file:close() end
    
    return matrix, err
end

function utils.matrix_write_to_file(matrix, filepath, separator)
    local separator = separator or ' '
    local file_opened = false
    
    local file = 0
    local saved_output = 0 

    if filepath then
        file = assert(io.open(filepath, "w+"))

        saved_output = io.output()
        io.output(file)
        file_opened = true
    end

    for index_l, line in ipairs(matrix) do
        for index_c, item in ipairs(line) do
            if index_c == #line then -- last one
                io.write(item)
            else
                io.write(item, separator, ' ')
            end
        end
        io.write('\n')
    end

    if file_opened == true then        
        io.output(saved_output)
        if file then file:close() end
    end

    return err
end

function utils.matrix_print(matrix, separator)
    local separator = separator or ' '
    utils.matrix_write_to_file(matrix, nil, separator)
end
--------------------------------------------------------------------------grid

function utils.point_to_grid(x, y, tilesize)		
	grid_x = math.floor(x / tilesize) + 1--lua arrays start at 1
	grid_y = math.floor(y / tilesize) + 1 --lua arrays start at 1
	return grid_x, grid_y
end

function utils.grid_to_center_point(x, y, tilesize)
	center_x = (x-1)*tilesize + math.ceil(tilesize/2)
	center_y = (y-1)*tilesize + math.ceil(tilesize/2)
	return center_x, center_y
end

function utils.grid_check_unobstructed(grid, origin, angle, distance, tilesize, maybe_step)
    -- we go tile by tile
    local step = maybe_step or tilesize
    local step_x = math.cos( angle ) * step
    local step_y = math.sin( angle ) * step

    local acc_distance = 0

    local current_cell = {}
    local x, y = origin.x, origin.y
    while acc_distance < distance do
        current_cell.x, current_cell.y = utils.point_to_grid(x, y, tilesize)
        if grid:is_colliding_grid(current_cell.x, current_cell.y) then
            return false
        end
        acc_distance = acc_distance + tilesize
        x, y = x + step_x, y + step_y
    end
    return true
end

utils.run_tests()
return utils