--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 0.1
Usage: To be used in conjunction with Monitor.lua
]]--
-------------------------------------------Variables-------------------------------------------
local GUI = {}

local component = require("component")
local term = require("term")

local gpu = component.gpu
local x, y = 0, 0
local x, y = gpu.getResolution()
local color1 = 0x99B2F2 --Main Color
local color2 = 0x5A5A5A --Accessory Color
local black = 0

--[[local colors = {
	white = 0xF0F0F0,
	orange = 0xF2B233,
	magenta = 0xE57FD8,
	lightBlue = 0x99B2F2,
	yellow = 0xDEDE6C,
	lime = 0x7FCC19,
	pink = 0xF2B2CC,
	gray = 0x4C4C4C,
	lightGray = 0x999999,
	cyan = 0x4C99B2,
	purple = 0xB266E5,
	blue = 0x3366CC,
	brown = 0x7F664C,
	green = 0x57A64E,
	red = 0xCC4C4C,
	black = 0,
} ]]--This is just for reference

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

function GUI.bar(color1, posX, posY, sizeW, sizeH)
	gpu.setBackground(color1)
	gpu.fill(posX, posY, sizeW, sizeH, " ")
end --end bar

function GUI.drawFrame()
    GUI.bar(color2, x/10, y/20*6-1, 50, 9)

    term.setCursor(x/10+1, y/10-1)
	GUI.bar(0x5A5A5A, x/10, y/10-1, x/10*8, 1)
	term.write("Power Level")
	term.setCursor(x/10+1, y/10*2-1)
	GUI.bar(0x5A5A5A, x/10, y/10*2-1, x/10*8, 1)
	term.write("Heat Level")
end

return GUI