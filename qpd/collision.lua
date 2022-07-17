local collision = {}

local qpd_point = require "qpd.point"

function collision.check(x1,y1,w1,h1, x2,y2,w2,h2)
	-- Checks if the quads are in collision.
	return  x1 <= x2+w2 and x2 <= x1+w1 and y1 <= y2+h2 and y2 <= y1+h1
end

function collision.check_quad(h1, h2)
	return collision.check(h1.x, h1.y, h1.w, h1.h, h2.x, h2.y, h2.w, h2.h)
end

function collision.check_center(x1, y1, s1, x2, y2, s2)
	return collision.check(	x1 - s1/2, y1 - s1/2, s1, s1,
							x2 - s2/2, y2 - s2/2, s2, s2)
end

function collision.check_circle(x1, y1, r1, x2, y2, r2)
	local distance = qpd_point.distance(x1, y1, x2, y2)
	return (r1+r2) > distance
end

return collision