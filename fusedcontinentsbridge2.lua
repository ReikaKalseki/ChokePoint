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

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	local rx = dx/750
	local ry = dy/750
	local val = (SimplexNoise.Noise2DCompound(rx*Config.terrainScale, ry*Config.terrainScale, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06})) --range from -1 to +1
	local val2 = (SimplexNoise.Noise2DCompound(rx/5.7+892347, ry/5.7-93854, {5.2, 13.3, 26.1, 54.7, 87.9}, {0.8, 0.6, 0.4, 0.25, 0.1})) --range from -1 to +1
	local val3 = (SimplexNoise.Noise2DCompound(rx*2.1+34567, ry*2.1-367578, {1.6, 3.7, 9.1, 13.2, 35.3}, {0.75, 0.5, 0.35, 0.18, 0.07})) --range from -1 to +1
	local br = bridge(dx, dy)+isNearRespawn(dx, dy)
	if math.abs(val2)-br <= 0.35 then
		val2 = math.min(math.abs(val2), math.abs(val3))
	end
	--if math.abs(val) < 0.85 and math.abs(val2)-br > 0.125 then
		local web = SimplexNoise.Noise2DCompound(rx*1.3, ry*1.3, {1.7, 4.3, 9.1}, {0.75, 0.6, 0.3})
		if (math.abs(val) < 0.72 and math.abs(val2)-br > 0.25 and web <= 0.5) then
			local ret = (math.abs(val) < 0.57 and math.abs(val2)-br > 0.41 and web <= 0.23) and 2 or 1 --0.6, 0.4, 0.38, then 0.6, 0.42, 0.35
			return ret
		end
	--end
	return 0
end

--[[

>>>eNptUE8oREEY/75979m1JIe9KG0Oe90SkoPMyEHh4uj47JvVK97T
vLcHFA5LinJx4eTKgSslKSdFKSdJ+XNRHJRyUFozb2f2bZtffb9+M79
v5vsD0A5JMAGh1Sz49qxhGOmCPz/PeN7nTJyaC7zksLzvSqvJYQHjoZ
kwTMflYcI00sxjcwv5aTuQydYMt4MgYRkpl/ue+sEMbM8xhRmEvhdlh
ZyxwLKslhK3Pbc0pxIBy198bLWcBRmVFeiuVGQIdQsQhQACigsNqzDr
FosAXcMyEHFvV+KAYNXPUCVAiY1XfeMqsfOsxMSvEvRYi21tPVLsjfB
FYrGUORp9XgxFLfVlisaiapaliZgf6Xx/6f85x5Ps2vvkyTLBs4XDEW
/9YUiYSTlVokbVCU5JQ+PwRJR1T/DmWuKDoCVfZCTRAUEX42KL7W1C7
W8J6uoE3doQjTdSjPCtJ3nV4o40zpGjOCg/z0pKS4oK1jpDJado1eiI
XfG0B+rLO/FwV7riZV3phh5yuoc++s8IDTe5usVHbTo1ejNqTYgN3ib
1ia5QA2J8ktTmG/4BtVSRGw==<<<

>>>eNpjYBBgYGdgYWBk4GFJzk/MYWZm5krOLyhILdLNL0oF8jiTi0pT
UnXzM0FSbCmpxalFJSxMzCwpmWCaKzUvNbdSNymxGKSYNb0osbiYiZW
ZI7MoPw9qAktxYl4KUClrcUl+HlhVSVFqajErKyt3aVFiXmZpLlQhA2
PL5yKvhhY5BhD+X89g8P8/CANZFxgYwBgIGBkYgQIwwJqck5mW9oFBw
eEDwwIHRkbGWTNBYKU9I0RexAHKYIAyOh7DRDKhjCkPoQyfv1CGw3oY
ox8mddeB0RgMPtsjGNUi69wfVpUA7YIayeGAYEAkW0CSjIy6zjKvH5n
92se4Q671deCOOnvGPZWrnPPabtsBJdlBvmKCExAf7LRHczjDA3uo1E
17xrNnQOCNPSMrSIcIiHCwABIHvIGhKMAHZC3oARIKMgwwp9k5IEIkD
Qy+wXzyGMa4bI/uDxUHRhuQ4XIgggtEgC2Eu4wRyox0gEhIImSBWo0Y
kK1PQXjuJMzGw0hWo7lBBeYGEwcsXkATUUEKeLAzU+DEC2a4I4AheIE
dxnOod2BmQIAP9klMrOUAE5+S3A==<<<

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