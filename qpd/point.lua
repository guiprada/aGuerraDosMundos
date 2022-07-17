local point = {}

function point.distance(p1_x, p1_y, p2_x, p2_y)
	-- Calculates the distance between points p1 and p2.
	return ((p1_x - p2_x)^2 + (p1_y - p2_y)^2 )^0.5
end

function point.distance2(p1, p2)
	return point.distance(p1.x, p1.y, p2.x, p2.y)
end

function point.middle_point(p1_x, p1_y, p2_x, p2_y)
	-- Calculates the middle point between p1 and p2.
	local middle_x = (p1_x + p2_x)/2
	local middle_y = (p1_y + p2_y)/2

	return middle_x, middle_y
end

function point.middle_point2(p1, p2)
	return point.middle_point(p1.x, p1.y, p2.x, p2.y)
end

function point.normalize(x, y)
	local norm = (x^2 + y^2)^(1/2)
	if norm ~= 0 then
		return x/norm, y/norm
	else
		return 0, 0
	end
end

function point.normalize2(p)
	return point.normalize(p.x, p.y)
end

function point.lerp(p1_x, p1_y, p2_x, p2_y, distance)
	local p_x, p_y = p2_x - p1_x, p2_y - p1_y
	p_x, p_y = point.normalize(p_x, p_y)
	p_x, p_y = p_x * distance, p_y * distance
	if point.distance(p1_x, p1_y, p2_x, p2_y) <= distance then
		return p2_x, p2_y, true
	else
		return p1_x + p_x, p1_y + p_y, false
	end
end

function point.lerp2(p1, p2, distance)
	return point.lerp(p1.x, p1.y, p2.x, p2.y)
end

function point.lerp_rotation(o1, o2, step)
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

return point