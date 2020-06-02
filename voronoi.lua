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

  local minDist1 = 2147483647.0
  local minDist2 = 2147483647.0
  local candidate1 = nil
  local candidate2 = nil
  
  local points = {}

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
        candidate1 = {xPos, yPos}
      end
      if dist < minDist2 and (xPos ~= candidate1[1] or yPos ~= candidate1[2]) then
        minDist2 = dist
        candidate2 = {xPos, yPos}
      end
    end
  end

  local mid = {(candidate1[1]+candidate2[1])/2, (candidate1[2]+candidate2[2])/2}
  local dx = candidate2[1]-candidate1[1]
  local dy = candidate2[2]-candidate1[2]
  local invslope = dy/dx
  local midp2 = {mid[1]+1, mid[2]+invslope}
  local dLx = midp2[1]-mid[1]
  local dLy = midp2[2]-mid[2]
  
  --[ https://wikimedia.org/api/rest_v1/media/math/render/svg/be2ab4a9d9d77f1623a2723891f652028a7a328d --]
  local num = dLy*y-dLx*x+midp2[1]*mid[2]-midp2[2]*mid[1]
  local denom = dLx*dLx+dLy*dLy
  local dist = math.abs(num)/math.sqrt(denom)
  
  return dist
end

return VoronoiNoise
