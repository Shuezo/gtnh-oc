--[[
Date: 2021/06/23 
Author: A. Jones & S. Huezo
Version: 2.0
Usage: Storage of generic functions and basic constants. To be used in conjunction with Monitor.lua
]]--
------------Initialization------------
local Functions = {}
local component = require("component")
local gpu = component.gpu
------------Constants------------
COLOR = { blue 		= 0x4286F4,
		  darkAqua	= 0x3392FF,
		  purple 	= 0xB673d6,
		  red 		= 0xC14141,
		  green 	= 0x0DA841,
		  black 	= 0x000000,
		  white 	= 0xFFFFFF,
		  grey 		= 0x252525,
		  lightGrey = 0xBBBBBB,
		  darkGrey 	= 0x262626 }
------------Helper Functions------------

function Functions.average(t) --average a set of numbers
	local sum = 0
	for _,v in pairs(t) do -- Get the sum of all numbers in t
		sum = sum + v
	end
	return sum / #t
end

function Functions.centerText(x, text) --center text at a point
	local xLeft = math.ceil(x - string.len(text)/2)
	return xLeft
end --end centerText

function Functions.getPercent(val, precision) --create a percent at a certain precision
	precision = precision or "0.2"
    return string.format("%".. precision .. "f%%", val * 100)
end

------------Graphic Functions------------

function Functions.clearScreen() --clears the screen
	gpu.setBackground(COLOR.black)
	gpu.fill(1, 1, W, H, " ")
end --end clearScreen

function Functions.setupResolution()
	--Use the resolution to help position all of the UI elements
	--Also sets the resolution to the maximum that is possible
	local maxW, maxH = gpu.maxResolution()
	if (W ~= maxW) and (H ~= maxH) then
		gpu.setResolution(maxW, maxH)
		local x, y = gpu.getResolution()
		W, H = x, y
		return true
	elseif (W == maxW and H == maxH) then
		local x, y = gpu.getResolution()
		W, H = x, y
		return true
	else
		return false
	end
end --end setupResolution

return Functions