--[[
Ported from libnoise. As usual with noise code I have incorporated, '--' comments are theirs.
--]]

VoronoiNoise = {}

local X_NOISE_GEN = 1
local Y_NOISE_GEN = 31337
--local Z_NOISE_GEN = 263
local SEED_NOISE_GEN = 1013

local SQRT_3 = math.sqrt(3)

local function IntValueNoise3D (x, y, seed)
  -- All constants are primes and must remain prime in order for this noise function to work correctly.
  local n = (
  X_NOISE_GEN    * x
  + Y_NOISE_GEN    * y
  --+ Z_NOISE_GEN    * z
  + SEED_NOISE_GEN * seed)

  n = bit32.band(n, 0x7fffffff)

  n = bit32.bxor(bit32.rshift(n, 13), n)

  local a = (n * (n * n * 60493 + 19990303) + 1376312589)

  return bit32.band(a, 0x7fffffff)
end

local function ValueNoise3D (x, y, seed)
  return 1.0 - (IntValueNoise3D (x, y, seed) / 1073741824.0)
end

function GetValue(x, y, seed)
  local xInt = math.floor(x)
  local yInt = math.floor(y)

  local minDist = 2147483647.0
  local minDist2 = 2147483647.0
  local xCandidate1 = 0
  local yCandidate1 = 0
  local xCandidate2 = 0
  local yCandidate2 = 0

  -- Inside each unit cube, there is a seed point at a random position.  Go through each of the nearby cubes until we find a cube with a seed point that is closest to the specified position.
  for dy = -2,2 do
    for dx = -2,2 do

      -- Calculate the position and distance to the seed point inside of this unit cube.
      local xCur = dx+xInt
      local yCur = dy+yInt
      local xPos = xCur + ValueNoise3D (xCur, yCur, seed)
      local yPos = yCur + ValueNoise3D (xCur, yCur, seed+1)
      local xDist = xPos - x
      local yDist = yPos - y
      local dist = xDist * xDist + yDist * yDist

      if dist < minDist1 then -- This seed point is closer to any others found so far, so record this seed point.
        minDist1 = dist
        xCandidate1 = xPos
        yCandidate1 = yPos
      end
      if dist < minDist2 and dist ~= minDist1 then
        minDist2 = dist
        xCandidate2 = xPos
        yCandidate2 = yPos
      end
    end
  end

  local value

  -- Determine the distance to the nearest seed point.
  local xDist = xCandidate - x
  local yDist = yCandidate - y
  value = (math.sqrt (xDist * xDist + yDist * yDist)) * SQRT_3 - 1.0

  -- Return the calculated distance with the displacement value applied.
  return value-- + ValueNoise3D ( math.floor (xCandidate), math.floor (yCandidate), seed)
end

return VoronoiNoise
