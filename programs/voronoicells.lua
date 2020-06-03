require "voronoi"
require "simplex"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	dx = dx*1.5*Config.terrainScale
	dy = dy*1.5*Config.terrainScale
	local f0 = 0.003
	local f0b = 0.024
	local f = 0.007
	local f2 = 0.039/5
	local f3 = 0.126/5
	local f4 = 0.13
	local dx2 = dx+3489
	local dy2 = dy-3429
	local dx3 = dx+56721
	local dy3 = dy-87349
	local wobble = SimplexNoise.Noise2D(dx*f0, dy*f0)+0.06*SimplexNoise.Noise2D(dx*f0b, dy*f0b)
	local noise = GetValue(dx*f+wobble, dy*f+wobble, 0)
	local simplex_bridges = SimplexNoise.Noise2D(dx*f2, dy*f2)+0.25*SimplexNoise.Noise2D(dx2*f3, dy2*f3)
	local simplex_offset = SimplexNoise.Noise2D(dx3*f4, dy3*f4)
	noise = noise+simplex_offset*0.03
	return (noise < 0.05*Config.riverSize and simplex_bridges < 0.3) and 1 or 0
end

--[[



--]]