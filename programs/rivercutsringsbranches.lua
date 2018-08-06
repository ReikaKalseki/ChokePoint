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
	local val = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale, ry*Config.terrainScale, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	local val2 = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale+53487, ry*Config.terrainScale-102478, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	
	local val3 = (SimplexNoise.Noise2DCompound(rx*3*Config.terrainScale-89356, ry*3*Config.terrainScale+98352, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	
	local valB = (SimplexNoise.Noise2DCompound(rx*4*Config.terrainScale+19285, ry*4*Config.terrainScale+87450, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	
	local off = 0.125*math.sin(0.05*math.sqrt(dx*dx+dy*dy))+0.1
	
	local eval2 = math.abs(val2)+off
	
	local evalA = math.abs(val)-off
	local evalB = math.abs(valB)-off
	if eval2 < 0.9925 then evalB = 1 end
	
	if (evalA < 0.2 or evalB < 0.15) and math.abs(eval2) > 0.25 then
		return (evalA < 0.1 and math.abs(eval2) > 0.4 and val3 <= 0) and 2 or 1
	end
	return 0
end

--[[



--]]