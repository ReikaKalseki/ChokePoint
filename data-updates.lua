require "__DragonIndustries__.sprites"

data.raw.tile["water-shallow"].collision_mask = table.deepcopy(data.raw.tile.water.collision_mask)
swapSprites(data.raw.tile["water-mud"], data.raw.tile["water-shallow"])
--[[
    {
      "water-tile",
      "item-layer",
      "resource-layer",
      "player-layer",
      "doodad-layer"
    }
	--]]