local qpd_value = {}

function qpd_value.clamp(value, min_value, max_value)
	-- Clamps value between min_value and max_value.
	if value > max_value then
		return max_value
	elseif value < min_value then
		return min_value
	end

	return value
end

function qpd_value.max(x, y)
	-- Returns the greatest value amongst x and y.

	return x > y and x or y
end

function qpd_value.min(x, y)
	-- Returns the smallest value amongst x and y.
	return x < y and x or y
end

function qpd_value.round(x)
	if x>0 then
		if math.fmod(x, 1) >= 0.5 then return math.ceil(x)
		else return math.floor(x) end
	else
		if math.fmod(x, 1) >= 0.5 then return math.floor(x)
		else return math.ceil(x) end
	end
end

function qpd_value.round_to_dec(value)
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

function qpd_value.number_to_bool(value)
	-- Converts a "C" style boolean number to a Boolean type.
	-- O is converted to false, 1 is converted to true, else it returns nil.
	if value == 0 then
		return false
	elseif value == 1 then
		return true
	end

	return nil
end

function qpd_value.string_to_bool(value)
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

function qpd_value.string_maybe_bool(value)
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

return qpd_value