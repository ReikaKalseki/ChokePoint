require "simplex"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water, 5 for "mud water" which is traversible
function runTile(dx, dy)
	local dist = math.sqrt(dx*dx+dy*dy)
	local ang = math.atan2(dx, dy)
	local wave = math.sin(dist*0.05-32)
	local angwav = math.sin(ang)
	return math.abs(wave+angwav) < 0.1 and 1 or 0
end

--[[



--]]