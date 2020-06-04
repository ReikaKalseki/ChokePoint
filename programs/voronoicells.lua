require "voronoi"
require "simplex"
require "config"

--returns: 0 for land, 1 for normal water, 2 for deep water, 3 for normal green water, 4 for deep green water, 5 for cliff, 6 for "water-shallow" which is traversible
function runTile(dx, dy)
	dx = dx/2.5*Config.terrainScale
	dy = dy/2.5*Config.terrainScale
	local f0 = 0.0035*3
	local f0b = 0.024*3
	local f = 0.007
	local f2 = 0.039/5
	local f3 = 0.126/5
	local f4 = 0.13
	local dx2 = dx+3489
	local dy2 = dy-3429
	local dx3 = dx+56721
	local dy3 = dy-87349
	local wobble = 0.4*(SimplexNoise.Noise2D(dx*f0, dy*f0)+0.06*SimplexNoise.Noise2D(dx*f0b, dy*f0b))
	local noise = GetValue(dx*f+wobble, dy*f+wobble)
	local simplexBridges = SimplexNoise.Noise2D(dx*f2, dy*f2)+0.25*SimplexNoise.Noise2D(dx2*f3, dy2*f3)
	simplexBridges = simplexBridges/6+0.14
	local simplexOffset = SimplexNoise.Noise2D(dx3*f4, dy3*f4)
	noise = noise+simplexOffset*0.03
	local spawnZone = math.max(0, 1-(dx*dx+dy*dy)*0.02)
	local baseNoise = noise+spawnZone*0.3
	local thresh = 0.05*Config.riverSize
	local value = baseNoise+math.max(simplexBridges, 0)*1
	if value < thresh then
		return 1
	elseif value < thresh+0.025 then
		return 6
	else
		return 0
	end
end

--[[



--]]