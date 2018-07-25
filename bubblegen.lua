require "simplex"

function runTile(dx, dy)
	local rx = dx/512
	local ry = dy/512
	local val = (SimplexNoise.Noise2DCompound(rx, ry, {1.5, 2, 3, 4, 7, 15, 25, 40}, {0.95, 0.9, 0.75, 0.55, 0.4, 0.25, 0.125, 0.05})+1)*500 --range from 0 to 1000
	local val2 = SimplexNoise.Noise2DCompound(-rx*3.7, ry*3.7, {2, 3, 7, 15, 40}, {0.9, 0.75, 0.4, 0.25, 0.05})
	local val3 = SimplexNoise.Noise2DCompound(-rx*1.4, ry*1.4, {1.5, 3, 6, 12}, {0.8, 0.65, 0.3, 0.15})
	local d = 0--rand(-10, 10)
	if val < 500+d*10 and (math.abs(val2) >= 0.333 or val3 < -0.667) then
		return 2
	end
	return 0
end