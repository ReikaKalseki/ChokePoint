require "simplex"

function runTile(dx, dy)
	local rx = dx/750
	local ry = dy/750
	local val = (SimplexNoise.Noise2DCompound(rx, ry, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	local val2 = (SimplexNoise.Noise2DCompound(rx/5.7+892347, ry/5.7-93854, {5.2, 13.3, 26.1, 54.7, 87.9}, {0.8, 0.6, 0.4, 0.25, 0.1})) --range from -1 to +1
	if math.abs(val) < 0.82 and math.abs(val2) > 0.125 then
		return 2
	end
	return 0
end