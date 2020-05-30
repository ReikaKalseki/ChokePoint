require "simplex"
require "config"

--returns: 0 for land, 1 for shallow water, 2 for deep water, 3 for shallow green water, 4 for deep green water
function runTile(dx, dy)
	local sz = 36--40--48--64--32
	local rx = (dx--[[-150*0--]])/sz*Config.terrainScale
	local ry = (dy--[[+150*0--]])/sz*Config.terrainScale
	
	local f = 0.1
	local f2 = 0.25
	
	local ox = (SimplexNoise.Noise2DCompound(rx*f, ry*f, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local oy = (SimplexNoise.Noise2DCompound(rx*f+53487, ry*f-102478, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	
	local hx = 0.95+math.sin(rx+ox)
	local hy = 0.95+math.sin(ry+oy)
	
	local bumpx = math.sin(rx*4.7-ox*1.46-297854)
	local bumpy = math.sin(ry*4.3-oy*1.51+98345)
	--game.print(dx .. " > " .. bumpx)
	
	local db = (SimplexNoise.Noise2DCompound(rx*f2-983456, ry*f2+308234, {1.25, 1.5, 2, 3, 4, 6, 7, 10, 15, 25, 35, 60}, {0.8, 0.95, 0.9, 0.75, 0.66, 0.55, 0.4, 0.25, 0.15, 0.1, 0.08, 0.06}))
	local od = 0.025+0.01*db --ranges from 0.38 to 0.46
	
	local h = math.min(hx, hy)+math.max(0, (bumpx+bumpy)/15-od)
	
	return h >= 0 and 0 or (h < -0.045 and 2 or 1) --was -0.04
end

--[[

>>>eNptUz9oVDEcTnxer+3ptUMXoZQOXQ/Eijho35MODrqIk2Puvdxr
aO7lmpfceSdYhyoOBRcXnboqqGsFEcFJUCg4iQjWLkJFhIKDIDXJS/K
uh4Hkvu/3y+9fvnsATINFAEAQXKw1kbxJBG4wjoMgOB4zRNXvZMyaiA
prVazTwdyyiZjLRAUQfbGeEC4aSDYxT0lmLhtLE5N0iFEUr5aMs17mW
cwxavtMicxFn7PcFDKWlOO+IjVDOpJ3qPaNG8px4rFAmb/WJYxi4Uv0
VtSEmuEMt/uNJjLpx1qcDbAOqqa4bYcbTxlN3NgpR3mumpea1Qqm2jE
xlraR7A55GSWGnrCUoywd4r79iYIX/U8VREi+JhnJh+77OSzvY0pZr+
BMZkmjhwTmum3CWeZGoBj5ETISr2Jq2diaRFwMtJ1LQahTvZ4jleuIi
MbiRSyYE7FgTkTDvIiGHRHRWJyIhpQiGmpFNNiKaHApoqFexJzQrv8z
VnLBTMc1scI4kU7HqiDuPSpCSZbrRxMyS3OBnaMmlTxlyMkuo7EyxE7
xujc40ae8xStbmsqxBiSLbVIApw6ur93ZmAN6H66D04eHeiu0o75Avf
WHCKAyuFWJKWm1foGtCID5SxDCx4/0ehLCwj8TWQAsuL/nLMSCh7sWX
P1rQfTCgQfO9SWCi2YdhCW4NfP88u5AqFo25XhUgsK5oZ0QNpZn97+d
+/Mabs/d3b+2fTuEr/pPl7N7n5eUs6oC4DF/FBO8DEcaB19D6/oUwg/
v9foRwoqOmNFHdF4db66o55muK7S1qY75WeBaW4rKF2mZ9dtNsufAx3
B0joUIXtDJ5/QxqQ9T0HcGLbwRFY5TpVeFngHD5ZNyuHeu4tuh0iM9L
Lgezkb/GWHEsjD08KbNxB/fA9+EesGdqmPRehRov8+Zbj77+Q8KeG0u
<<<

--]]