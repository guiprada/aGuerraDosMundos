local color = {}

color.gray = {0.5, 0.5, 0.5}
color.darkgray = {0.3, 0.3, 0.3}
color.lightgray = {0.8, 0.8, 0.8}
color.brown = {0.5, 0.4, 0.3}
color.darkbrown = {0.3, 0.2, 0.2}
color.blue = {0.0, 0.5, 0.9}
color.darkblue = {0.0, 0.3, 0.7}
color.skyblue = {0.4, 0.7, 1.0}
color.green = {0.0, 0.9, 0.2}
color.darkgreen = {0.0, 0.5, 0.2}
color.purple = {0.8, 0.5, 1.0}
color.darkpurple = {0.4, 0.1, 0.5}
color.magenta = {1.0, 0.0, 1.0}
color.beige = {0.8, 0.7, 0.5}
color.orange = {1.0, 0.6, 0.0}
color.lime = {0.0, 0.6, 0.2}
color.pink = {1.0, 0.4, 0.8}
color.red = {0.9, 0.2, 0.2}
color.violet = {0.5, 0.2, 0.7}
color.maroon = {0.7, 0.1, 0.2}
color.gold = {1.0, 0.8, 0.0}
color.yellow = {1.0, 1.0, 0.0}
color.black = {0.0, 0.0, 0.0}
color.white = {1.0, 1.0, 1.0}
color.offwhite = {0.96, 0.96, 0.96}

function color.unpack(color)
	return color[1], color[2], color[3], color[4]
end

return color
