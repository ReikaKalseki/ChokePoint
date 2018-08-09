require "simplex"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	local rx = dx/32*Config.terrainScale
	local ry = dy/32*Config.terrainScale
	
	local f = 0.1
	local f2 = 0.25
	
	local ox = (SimplexNoise.Noise2DCompound(rx*f, ry*f, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local oy = (SimplexNoise.Noise2DCompound(rx*f+53487, ry*f-102478, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	
	local hx = 0.95+math.sin(rx+ox)
	local hy = 0.95+math.sin(ry+oy)
	
	local bump = (SimplexNoise.Noise2DCompound(rx*f2-98456, ry*f2+289745, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	
	local h = math.min(hx, hy)
	
	h = h+math.max(0, bump-0.35)
	
	return h >= 0 and 0 or (h < -0.04 and 2 or 1)
end

--[[



--]]