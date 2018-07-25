--local noise = require("noise")

--[[

local delta = 500

data.raw.tile.water.autoplace.peaks[1].elevation_max_range = data.raw.tile.water.autoplace.peaks[1].elevation_max_range+delta
data.raw.tile.deepwater.autoplace.peaks[1].elevation_max_range = data.raw.tile.deepwater.autoplace.peaks[1].elevation_max_range+delta
data.raw.tile["water-green"].autoplace.peaks[1].elevation_max_range = data.raw.tile["water-green"].autoplace.peaks[1].elevation_max_range+delta
data.raw.tile["deepwater-green"].autoplace.peaks[1].elevation_max_range = data.raw.tile["deepwater-green"].autoplace.peaks[1].elevation_max_range+delta
--]]

local function printTable(val, pad)
	if not pad then pad = {} end
	for k,v in pairs(val) do
		pad[#pad+1] = k
		local s = tostring(#pad)
		for _,val in pairs(pad) do s = s .. ":" .. val end
		if type(v) == "table" then
			printTable(v, pad)
		else
			log(s .. " > " .. tostring(v))
		end
		table.remove(pad, #pad)
	end
end

--printTable(data.raw["noise-expression"]["default-elevation"].expression)

--[[
data.raw["noise-expression"]["default-elevation"].expression = noise.define_noise_function( function(x,y,tile,map)
      return 1000000
    end)
	
	
data.raw["noise-expression"]["large-seas-elevation"].expression = noise.define_noise_function( function(x,y,tile,map)
      return 1000000
    end)
--]]

--"default-elevation", "large-seas-elevation", "rings"
--[[
local function zeroNoiseProfile(profile)
	log("Zeroing noise system '" .. profile .. "'")
	data.raw["noise-expression"][profile].expression = noise.define_noise_function( function(x,y,tile,map)
      return 0
    end)
end

zeroNoiseProfile("rings")
zeroNoiseProfile("large-seas-elevation")
--zeroNoiseProfile("default-elevation")

local next_expression_number = 1

local id_expression = function(expr)
  if (expr.type == "literal-number") then
    return "literal-number:" .. expr.literal_value
  elseif expr.type == "variable" then
    -- only valid as long as we're not allowing new variables in local scopes;
    -- if we do, the same name could mean different things at different
    -- points in the same procedure
    return "variable:" .. expr.variable_name
  else
    -- Would be better to use a hash but
    -- at least this will allow the compiler to identify
    -- explicitly duplicated expressions
    local id = "expr#" .. next_expression_number
    next_expression_number = next_expression_number + 1
    return id
  end
end

local function tneMINE(v)
  if type(v) == "number" then
    return tneMINE{
      type = "literal-number",
      literal_value = v
    }
  elseif type(v) == "table" then
    local noise_expression_metatable = {
      __add = function(lhs, rhs)
        return tneMINE{
          type = "function-application",
          function_name = "add",
          arguments = { tneMINE(lhs), tneMINE(rhs) }
        }
      end,
      __sub = function(lhs, rhs)
        return tneMINE{
          type = "function-application",
          function_name = "subtract",
          arguments = { tneMINE(lhs), tneMINE(rhs) }
        }
      end,
      __mul = function(lhs, rhs)
        return tneMINE{
          type = "function-application",
          function_name = "multiply",
          arguments = { tneMINE(lhs), tneMINE(rhs) }
        }
      end,
      __div = function(lhs, rhs)
        return tneMINE{
          type = "function-application",
          function_name = "divide",
          arguments = { tneMINE(lhs), tneMINE(rhs) }
        }
      end,
      __pow = function(lhs, rhs)
        return tneMINE{
          type = "function-application",
          function_name = "exponentiate",
          arguments = { tneMINE(lhs), tneMINE(rhs) }
        }
      end,
    }
    if v.type ~= nil then
      setmetatable(v, noise_expression_metatable)
      if v.expression_id == nil then
        v.expression_id = id_expression(v)
      end
      return v
    else
      error("Can't turn table without 'type' property into noise expression")
    end
  else
    error("Can't turn "..type(v).." into noise expression")
  end
end--]]
--[[
data.raw["noise-expression"]["default-elevation"].expression = noise.define_noise_function( function(x,y,tile,map)


	local meta = getmetatable(x)
	
	meta.__unm = function(val)
        return val
      end 
	  
	  setmetatable(x, meta)
	  
	  x = tneMINE(x)
	  printTable(x)

	return x*2+y--math.floor((-x)/100)*100
		
    end)
--]]
--data.raw.tile.water.autoplace = nil
--data.raw.tile.deepwater.autoplace = nil
--data.raw.tile["water-green"].autoplace = nil
--data.raw.tile["deepwater-green"].autoplace = nil

--for k,v in pairs(data.raw["noise-expression"]) do log("Zeroing noise exp " .. k) v.expression = noise.define_noise_function( function(x,y,tile,map) return 0 end) end