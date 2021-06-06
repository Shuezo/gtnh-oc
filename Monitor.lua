
-------------------------------------------Variables-------------------------------------------
local GUI = {}

local component = require("component")
local Power = require("Power")

local gpu = component.gpu
local x, y = 0, 0
local x, y = gpu.getResolution()

-------------------------------------------Functions-------------------------------------------

function Clear()
    gpu.fill(1, 1, x, y, " ")
end --clears the screen

function GUI.setupResolution()
	--Use the resolution to help position all of the UI elements
	--Also sets the resolution to the maximum that is possible
	local maxW, maxH = gpu.maxResolution()
	local w, h = gpu.getResolution()
	if (w ~= maxW) and (h ~= maxH) then
		gpu.setResolution(maxW, maxH)
		x, y = gpu.getResolution()
		return true
	elseif (w == maxW and h == maxH) then
		x, y = gpu.getResolution()
		return true
	else
		return false
	end
end --setupResolution

-------------------------------------------Main-------------------------------------------
