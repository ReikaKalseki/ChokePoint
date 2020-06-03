local VORONOI_MAX_POINTS_PER_REGION = 2
local VORONOI_POINTS_RESOLUTION = 1024

    local function hash(x)
        local function lsl_xor(val)
            local tmp = bit32.rshift(val, 16)
            return bit32.bxor(tmp, val)
        end

        local magic = math.floor(0x45d9f3b)

        x = lsl_xor(x) * magic
        x = bit32.band(x, 0xffffffff)
        x = lsl_xor(x) * magic
        x = bit32.band(x, 0xffffffff)
        x = lsl_xor(x)
        x = bit32.band(x, 0xffffffff)

        return math.floor(x)
    end

    local function hash_xy(x, y)
        local h = hash(x)
        h = hash(bit32.bxor(h, y))
        return h
    end

function GetValue(x, y, seed)
  local h = hash_xy(x, y)
  local result_count = 1 + h % (VORONOI_MAX_POINTS_PER_REGION - 1)
  
  local points = {}

  
  for i=0,result_count do
            h = hash(h)
            local rx = (h % VORONOI_POINTS_RESOLUTION) / VORONOI_POINTS_RESOLUTION
            h = hash(h)
            local ry = (h % VORONOI_POINTS_RESOLUTION) / VORONOI_POINTS_RESOLUTION
			
			
      local xDist = rx - x
      local yDist = ry - y
      local dist = xDist * xDist + yDist * yDist

      table.insert(points, {src = {0, 0}, result = {rx, ry}, dist = dist})
        end
  
  table.sort(points, function(point1, point2) return point1.dist < point2.dist end)
  
  if true then return points[1].dist end
  
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
