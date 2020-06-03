--[[
Ported from libnoise. As usual with noise code I have incorporated, '--' comments are theirs.
--]]

VoronoiNoise = {}

-- All constants are primes and must remain prime in order for this noise function to work correctly.
local X_NOISE_GEN = 1
local Y_NOISE_GEN = 31337
--local Z_NOISE_GEN = 263
local SEED_NOISE_GEN = 1013

local SQRT_3 = math.sqrt(3)

VoronoiNoise.seedBase = 0

local function multiplyHash(hash, factor)
	return bit32.band(hash*factor, 0x7fffffff)
end

local function addToHash(hash, add)
	return bit32.band(hash+add, 0x7fffffff)
end

local function IntValueNoise3D (x, y, seed)

	local n0 = addToHash(0, SEED_NOISE_GEN)
	n0 = multiplyHash(n0, seed)
	local n1 = addToHash(0, X_NOISE_GEN)
	n1 = multiplyHash(n1, x)
	local n2 = addToHash(0, Y_NOISE_GEN)
	n2 = multiplyHash(n2, y)
	local n = addToHash(n1, n2)
	n = addToHash(n, n0)

  n = bit32.bxor(bit32.rshift(n, 13), n)
  
  local a = multiplyHash(n, n)
  a = multiplyHash(a, 60493)
  a = addToHash(a, 19990303)
  a = multiplyHash(a, n)
  a = addToHash(a, 1376312589)

  return a
end

local function ValueNoise3D (x, y, seed)
  return 1.0 - (IntValueNoise3D (x, y, seed) / 1073741824.0)
end

function GetValue(x, y)
  local xInt = math.floor(x)
  local yInt = math.floor(y)
  
  local points = {}

  -- Inside each unit cube, there is a seed point at a random position.  Go through each of the nearby cubes until we find a cube with a seed point that is closest to the specified position.
  for dy = -2,2 do
    for dx = -2,2 do

      -- Calculate the position and distance to the seed point inside of this unit cube.
      local xCur = dx+xInt
      local yCur = dy+yInt
      local xPos = xCur + ValueNoise3D (xCur, yCur, VoronoiNoise.seedBase)
      local yPos = yCur + ValueNoise3D (xCur, yCur, VoronoiNoise.seedBase+1)
      local xDist = xPos - x
      local yDist = yPos - y
      local dist = xDist * xDist + yDist * yDist

      table.insert(points, {src = {xCur, yCur}, result = {xPos, yPos}, dist = dist})
    end
  end
  
  table.sort(points, function(point1, point2) return point1.dist < point2.dist end)
  
  local candidate1 = points[1].result
  local candidate2 = points[2].result

  local mid = {(candidate1[1]+candidate2[1])/2, (candidate1[2]+candidate2[2])/2}
  local dx = candidate2[1]-candidate1[1]
  local dy = candidate2[2]-candidate1[2]
  local invslope = -dx/dy
  local midp2 = {mid[1]+1, mid[2]+invslope}
  local dLx = midp2[1]-mid[1]
  local dLy = midp2[2]-mid[2]
  
  --[ https://wikimedia.org/api/rest_v1/media/math/render/svg/be2ab4a9d9d77f1623a2723891f652028a7a328d --]
  local num = dLy*x-dLx*y+midp2[1]*mid[2]-midp2[2]*mid[1]
  local denom = dLx*dLx+dLy*dLy
  local dist = math.abs(num)/math.sqrt(denom)
  
  return dist
end

return VoronoiNoise
