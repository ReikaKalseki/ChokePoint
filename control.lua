require "__DragonIndustries__.tiles"

require "programs.voronoicells"
require "simplex"
require "voronoi"

CHUNK_SIZE = 32

--try this:
--lines on grid with very heavy perpendicular distortion (noisemap), with thickness determined by noisemap, often tapering below t=0 (chokepoint)

local ranTick = false

local chunksToGen = {}

local waterTypes = {"water", "deepwater", "water-green", "deepwater-green", "cliff", "water-shallow"}

function canPlaceAt(surface, x, y)
	return surface.can_place_entity{name = "cliff", position = {x, y}}-- and not isWaterEdge(surface, x, y)
end

function isWaterEdge(surface, x, y)
	if surface.get_tile{x-1, y}.valid and surface.get_tile{x-1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x+1, y}.valid and surface.get_tile{x+1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y-1}.valid and surface.get_tile{x, y-1}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y+1}.valid and surface.get_tile{x, y+1}.prototype.layer == "water-tile" then
		return true
	end
end

function isInChunk(x, y, chunk)
	local minx = math.min(chunk.left_top.x, chunk.right_bottom.x)
	local miny = math.min(chunk.left_top.y, chunk.right_bottom.y)
	local maxx = math.max(chunk.left_top.x, chunk.right_bottom.x)
	local maxy = math.max(chunk.left_top.y, chunk.right_bottom.y)
	return x >= minx and x <= maxx and y >= miny and y <= maxy
end

local function createCliff(surface, chunk, dx, dy)
	if --[[isInChunk(dx, dy, chunk) and ]]canPlaceAt(surface, dx, dy) then
		surface.create_entity{name = "cliff", position = {x = dx, y = dy}, force = game.forces.neutral}
	end
end

local function createWater(surface, chunk, dx, dy, tile_changes, waterType)
	local at = surface.get_tile{dx, dy}
	if isWaterTile(at) then
		if string.find(at.name, "deep", 1, true) and not string.find(waterType, "deep", 1, true) then
			return
		elseif not (string.find(at.name, "shallow", 1, true) or string.find(at.name, "mud", 1, true)) and string.find(waterType, "shallow", 1, true) then
			return
		end
	end
	table.insert(tile_changes, {name = waterType, position={dx, dy}})
	
	--[[
	if surface.get_tile{dx-1, dy}.valid and surface.get_tile{dx-1, dy}.prototype.layer ~= "water-tile" then
		surface.set_tiles({{name="water", position={dx-1, dy}}})
	end
	if surface.get_tile{dx+1, dy}.valid and surface.get_tile{dx+1, dy}.prototype.layer ~= "water-tile" then
		surface.set_tiles({{name="water", position={dx+1, dy}}})
	end
	if surface.get_tile{dx, dy-1}.valid and surface.get_tile{dx, dy-1}.prototype.layer ~= "water-tile" then
		surface.set_tiles({{name="water", position={dx, dy-1}}})
	end
	if surface.get_tile{dx, dy+1}.valid and surface.get_tile{dx, dy+1}.prototype.layer ~= "water-tile" then
		surface.set_tiles({{name="water", position={dx, dy+1}}})
	end
	--]]
end

local function controlChunk(surface, area, isRetro)
	--local rand = game.create_random_generator()
	local x = (area.left_top.x+area.right_bottom.x)/2
	local y = (area.left_top.y+area.right_bottom.y)/2
	--local dd = math.sqrt(x*x+y*y)
	--local seed = createSeed(surface, x, y)
	--
	--rand.re_seed(seed)	
	local seed = surface.map_gen_settings.seed
	seed = bit32.bxor(seed, Config.seedMix)
	SimplexNoise.seedP(seed)
	VoronoiNoise.seedBase = seed
	
	--log("Genning chunk " .. x .. " , " .. y)
	
		--[[
		for _,cliff in pairs(surface.find_entities_filtered({area = {{area.left_top.x, area.left_top.y}, {area.right_bottom.x, area.right_bottom.y}}, type="cliff"})) do
			cliff.destroy()
		end
		--]]
		
	local tile_changes = {}
	
	for dx = area.left_top.x,area.right_bottom.x do
		for dy = area.left_top.y,area.right_bottom.y do
			local ex = dx-Config.offsetX
			local ey = dy-Config.offsetY
			local class = runTile(ex, ey)
			if class > 0 then
				if class == 5 then
					createCliff(surface, area, dx, dy)
				else
					createWater(surface, area, dx, dy, tile_changes, waterTypes[class])
				end
			else
				if isRetro then
					table.insert(tile_changes, {name="grass-1", position={dx, dy}})
				end
			end
		end
	end
	
	if #tile_changes > 0 then
		surface.set_tiles(tile_changes)
	end	
end

--[[
script.on_event(defines.events.on_tick, function(event)
	if not ranTick and Config.retrogen then
		local surface = game.surfaces["nauvis"]
		for chunk in surface.get_chunks() do
			local x = chunk.x
			local y = chunk.y
			if surface.is_chunk_generated({x, y}) then
				local area = {
					left_top = {
						x = x*CHUNK_SIZE,
						y = y*CHUNK_SIZE
					},
					right_bottom = {
						x = (x+1)*CHUNK_SIZE,
						y = (y+1)*CHUNK_SIZE
					}
				}				
				table.insert(chunksToGen, area)
				--controlChunk(surface, area)
			end
		end
		ranTick = true
		
		--for name,force in pairs(game.forces) do
		--	force.rechart()
		--end
		
		--game.print("Ran load code")
	end
	if #chunksToGen > 0 then
		local area = chunksToGen[1]
		local surface = game.surfaces["nauvis"]
		controlChunk(surface, area, true)
		for name,force in pairs(game.forces) do
			force.chart(surface, area)
		end
		table.remove(chunksToGen, 1)
		game.print("Retrogenning chunk, " .. #chunksToGen .. " to go")
	end
end)
--]]

function cantorCombine(a, b)
	--a = (a+1024)%16384
	--b = b%16384
	local k1 = a*2
	local k2 = b*2
	if a < 0 then
		k1 = a*-2-1
	end
	if b < 0 then
		k2 = b*-2-1
	end
	return 0.5*(k1 + k2)*(k1 + k2 + 1) + k2
end

function createSeed(surface, x, y) --Used by Minecraft MapGen
	return bit32.band(cantorCombine(surface.map_gen_settings.seed, cantorCombine(x, y)), 2147483647)
end

script.on_event(defines.events.on_chunk_generated, function(event)
	if event.surface.name == "nauvis" then
		controlChunk(event.surface, event.area)	
	end
end)