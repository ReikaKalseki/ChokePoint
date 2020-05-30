require "voronoi"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	local f = 0.01
	local noise = GetValue(dx*f, dy*f, 0)
	return math.abs(noise) < 0.125 and 1 or 0
end

--[[



--]]