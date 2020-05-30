require "simplex"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	local f = 0.0153
	local f0 = 0.001423
	local a = (SimplexNoise.Noise2DCompound(dx*f0+34872, dy*f0+238030, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local b = (SimplexNoise.Noise2DCompound(dx*f0+53487, dy*f0-102478, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local ux = dx*dy/dx*a
	local uy = dy*dx/dy*b
	local wavX = math.sin(ux*f)
	local wavY = math.sin(uy*f)
	local t = 0.15
	local waterX = math.abs(wavX) < t
	local waterY = math.abs(wavY) < t
	local water = waterX or waterY
	return water and 1 or 0
end

--[[



--]]