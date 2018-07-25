require "simplex"

function runTile(dx, dy)
	local rx = dx/768
	local ry = dy/768
	local val = (SimplexNoise.Noise2DCompound(rx, ry, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.125, 0.08, 0.05})) --range from -1 to +1
	if math.abs(val) < 0.82 then
		return 2
	end
	return 0
end