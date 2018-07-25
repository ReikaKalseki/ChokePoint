require "simplex"
require "config"

local spawns = {}

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function roundArbitrary(val, multiple)
	local down = val-val%multiple
	local up = down+multiple
	local ddown = math.abs(val-down)
	local dup = math.abs(val-up)
	return ddown < dup and down or up
end

local function isNearRespawn(x, y)
	if #spawns == 0 and game.tick < 60 then
		for i = 1,#game.players do
			spawns[#spawns+1] = game.players[i].position
		end
	end
	
	local maxd = 30
	
	for i = 1,#spawns do
		local spawn = spawns[i]
		local dx = x-spawn.x
		local dy = y-spawn.y
		local dd = math.sqrt(dx*dx+dy*dy)
		if dd <= maxd then
			return 1-dd/maxd
		end
	end
	return 0
end

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	local rx = dx/600
	local ry = dy/600
	
	local q = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale, ry*Config.terrainScale, {0.4}, {1})) --range from -1 to +1
	if q > 0.5 then
		return 0
	end
	
	local val = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale, ry*Config.terrainScale, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	local val2 = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale+53487, ry*Config.terrainScale-102478, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	local val3 = (SimplexNoise.Noise2DCompound(rx*3*Config.terrainScale-89356, ry*3*Config.terrainScale+98352, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	
	local off = 0.125*math.sin(0.05*math.sqrt(dx*dx+dy*dy))+0.1
	
	local eval = math.abs(val)-off
	local eval2 = math.abs(val2)+off
	
	if eval < 0.2 and math.abs(eval2) > 0.25 then
		return (eval < 0.1 and math.abs(eval2) > 0.4 and val3 <= 0) and 2 or 1
	end
	return 0
end

--[[

>>>eNptUzFoVDEYTjyvd+3pXYdbhFI6dD0RK+KgfU86OOgiTo6593Kv
obmXa15y551gHao4CDq46OSqg64VRAQnQaHgJCJYuwh1EAoOgtQkL8m
7Hgby3/f9f/78/5/vHgCzYAkAUCpdqLWRvEEEbjGOS6XS0Yghqn5nIt
ZGVFivYr0e5pZNR1zGKoHog/WYcNFCso15QlJz2HjamCRjjKJorWCcD
VLPIo5R198Uy0wMOctMIeNJOB4qUjOkJ3mP6ljVUI5jjwVK/bE+YRQL
X2KwqibUDKe4O2y1kbl+qsPZCOukSoK7drhqwmjsxk44yjLVvNSsljP
VjsmxtItkfyzKKDH0mKUcpckY9+1P5zzvv5ETIfm6ZCQbO+/nsHyIKW
WDnDOZxq0BEpjrtglnqRuBYuRHSEm0hqllU+sScTHSfi4FoU71eobUX
YdENB4vYs6ciDlzIhrmRTTskIjG40Q0pBDRUCuiwVZEgwsRDfUiZoT2
/Z+xnAlmOq6JVcaJdDpWBHHvURZKskw/mpBpkgnsAjWp5ClSjvcZjZQ
jcorXvcOJ3vAer2zhKsYakTSylwLY2L+2fntzHuh9sAFOHRzordC2+g
L11h8igMrhVjmipNMBYOGi3hDCJ4/1ehbAPN4MLQAW3Nt1HmLBox0Lr
vy1IHzpwAMX+hrCJbP2gwLcbL64tDMSqpa9shoWIA9u6iCErZW5ve9n
/7yBW/N39q5u3Qrg6+HzlfTul2UVrKgEeMSbfIJXwUTj4FtgQ58D+PG
DXj8DWNYZTW3Cc8q8vayeZ7au0NP7yizMAdfacli8SMes326SXQc+BZ
NzLIbwvL58XpsZbUxB3xm08HqYB04UUZV6GoyXj4vh3ruK78ZKT/Sw6
Ho4E/5nhAnP4tjDmzZjb36UfBPqBbcrjoUbYQkU61fwsNk4+Q/G2mrr
<<<

--]]