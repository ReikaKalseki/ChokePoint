require "simplex"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy, offsetX, offsetY)
	local sz = 36--40--48--64--32
	local rx = (dx--[[-150*0--]])/sz*Config.terrainScale
	local ry = (dy--[[+150*0--]])/sz*Config.terrainScale
	
	local f = 0.1
	local f2 = 0.25
	
	local ox = (SimplexNoise.Noise2DCompound(rx*f, ry*f, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local oy = (SimplexNoise.Noise2DCompound(rx*f+53487, ry*f-102478, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	
	local hx = 0.95+math.sin(rx+ox)
	local hy = 0.95+math.sin(ry+oy)
	
	local bumpx = math.sin(rx*4.7-ox*1.46-297854)
	local bumpy = math.sin(ry*4.3-oy*1.51+98345)
	--game.print(dx .. " > " .. bumpx)
	
	local db = (SimplexNoise.Noise2DCompound(rx*f2-983456, ry*f2+308234, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local od = 0.42+0.04*db --ranges from 0.38 to 0.46
	
	local h = math.min(hx, hy)+math.max(0, (bumpx+bumpy)/2-od)
	
	return h >= 0 and 0 or (h < -0.04 and 2 or 1)
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