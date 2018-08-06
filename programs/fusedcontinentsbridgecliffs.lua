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
--[[
local function bridge(dx, dy)
	local x = round(dx, -3)
	local y = round(dy, -3)
	local mx = dx-x
	local my = dy-y
	local ret = 0
	local dd = math.sqrt(mx*mx+my*my)
	--game.print(dx .. " > " .. x .. " > " .. mx .. " ; " .. dy .. " > " .. y .. " > " .. my .. " ;; " .. dd)
	local maxd = 250
	if dd <= maxd then
		local f = (1-dd/maxd)--^0.75
		local ang = math.atan2(my, mx)
		if (ang+360)%30 < 6 then
			--game.print(dx .. " , " .. dy .. " > " .. f)
			ret = ret + f
		end
	end
	return ret
end
--]]
local function bridge(dx, dy)
	local x = roundArbitrary(dx, 700)
	local y = roundArbitrary(dy, 700)
	local mx = dx-x
	local my = dy-y
	local dd = math.sqrt(mx*mx+my*my)
	--game.print(dx .. " > " .. x .. " > " .. mx .. " ; " .. dy .. " > " .. y .. " > " .. my .. " ;; " .. dd)
	local maxd = 250
	if dd <= maxd then
		local f = (1-dd/maxd)--^0.75
		return f
	end
	return 0
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

local function cliff(x, y)
	local rx = roundArbitrary(x, 500)
	local ry = roundArbitrary(y, 500)
	local f = 1/750
	for dx = rx-500,rx+500,500 do
		for dy = ry-500,ry+500,500 do
			local cx = dx+200*SimplexNoise.Noise2DCompound(dx*f*Config.terrainScale+243897, dy*f*Config.terrainScale+92834, {}, {})
			local cy = dy+200*SimplexNoise.Noise2DCompound(dx*f*Config.terrainScale-34589, dy*f*Config.terrainScale+239844, {}, {})
			local d = 1
			--game.print(x .. " & " .. y .. " > " .. rx .. " & " .. ry)
			if math.abs(x-cx) < d or math.abs(y-cy) < d then
				return true
			end
		end
	end
	return false
end

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	if cliff(dx, dy) then
		return 5
	end
	local rx = dx/750
	local ry = dy/750
	local val = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale, ry*Config.terrainScale, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	local val2 = (SimplexNoise.Noise2DCompound(rx/5.7+892347, ry/5.7-93854, {5.2, 13.3, 26.1, 54.7, 87.9}, {0.8, 0.6, 0.4, 0.25, 0.1})) --range from -1 to +1
	local val3 = (SimplexNoise.Noise2DCompound(rx*2.1+34567, ry*2.1-367578, {1.6, 3.7, 9.1, 13.2, 35.3}, {0.75, 0.5, 0.35, 0.18, 0.07})) --range from -1 to +1
	local br = bridge(dx, dy)+isNearRespawn(dx, dy)
	if math.abs(val2)-br <= 0.35 then
		val2 = math.min(math.abs(val2), math.abs(val3))
	end
	if math.abs(val) < 0.85 and math.abs(val2)-br > 0.125 then
		local ret = (math.abs(val) < 0.72 and math.abs(val2)-br > 0.25 and SimplexNoise.Noise2DCompound(rx*1.3, ry*1.3, {1.7, 4.3, 9.1}, {0.75, 0.6, 0.3}) <= 0.5) and 2 or 1
		--not until there are usable transition sprites: https://i.imgur.com/7xJTiNP.jpg
		--if SimplexNoise.Noise2DCompound((rx-273845)/5.9, (ry+127649)/5.9, {1.8, 3.9, 7.7}, {0.9, 0.6, 0.4}) < -0.5 then
		--	ret = ret+2
		--end
		return ret
	end
	return 0
end

--[[

>>>eNptUDFoFEEUnbm9yZ53QVJco4YjxbUHoiIWkh24QjA2lpZzu3Pr
4GY2zsxqcoJncYqFmCZNrNJqoW0EEcFKUAhYiQjGNEIsAgELQc6ZvZn
d4/DD/Hn/v/nz3/8ALAAfVAEEpxs9kq0zRTupoJ7nVcOUJPquh2mPJM
pmdbS2RoWNToQii3QBMw/nIiqpUNWKV41Yftcpp6sbnR6R5rEf01VbV
4vTJLIYxYJIWUHefCzSjEedu0RRYR4xkXJXkFDiCuqchbdoYqO52xkR
amDyIlMsKeRLwiOjQbLkTiEYSZVyAxrqZipY5gT5irlWSAlKJUJoXmU
8loo6opEJwsuS2oDx0GIAR8fi6oNRC5gzHoKz47E5Gu0BkB9tEECdcI
bChPX7R2AJH4EdDCF8tm3seQAnfBNbACx4fOAyzIKtfQuu/bUAv3Jg0
1HfMDyf23FQgnvNl1f2B0r3sl/WcAkm5MiQEHa6i4c/Lv55C3dbDw+v
794P4JuNF13+6OuyJn0zVaVwkwleBzPCwffAUl8C+OmjsV8BRKaiaRy
+pN27Fb3FhZMa7TzRbmkROGnLuNxIP7ffbpIDBz4Hs3O0MbxsPm8ZVz
cub1gogxbewBPiVMnq0nNgun1UDvfBdXw/1XpGQ9tpuID/M8JMpj21+
FxmVLifXiFCb3DPdxEeYs/wxZ/dM8On/wD0WMeB<<<

--]]