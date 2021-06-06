--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 0.1
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local Graphic = {}

local component = require("component")
local term = require("term")
local Power = require("Power")

local gpu = component.gpu
local x, y = 0, 0
local white = 0xFFFFFF --Main Color
local black = 0x000000 --Accessory Color

------------Functions------------

function Graphic.clearScreen()
	local w, h = gpu.getResolution()
	gpu.fill(1, 1, w, h, " ")
end --clears the screen

function Graphic.setupResolution()
	--Use the resolution to help position all of the UI elements
	--Also sets the resolution to the maximum that is possible
	local maxW, maxH = gpu.maxResolution()
	local w, h = gpu.getResolution()
	if (w ~= maxW) and (h ~= maxH) then
		gpu.setResolution(maxW, maxH)
		local x, y = gpu.getResolution()
		return true
	elseif (w == maxW and h == maxH) then
		local x, y = gpu.getResolution()
		return true
	else
		return false
	end
end --end setupResolution

function Graphic.drawFrame()
	gpu.setForeground(black)
	gpu.setBackground(white)
	gpu.fill(1, 1, 50, 1, " ") --top
	gpu.fill(1, 16, 50, 1, " ")  --bottom
	gpu.fill(1, 2, 2, 14, " ")  --left
	gpu.fill(49, 2, 2, 14, " ")  --right

	gpu.setForground(white)
	gpu.setBackground(black)
	gpu.fill(3, 2, 46, 14, " ") --center, black
end --end charFrame

function Graphic.drawLabel()
	local w, h = gpu.getResolution()
	local x = 10
	local y = 4
	gpu.set(1,1,"------------ Power Monitoring  System ------------")
	gpu.set(x,y,"Status")
		y=y+1
	gpu.set(x-4,y,"--------------------------------------")
		y=y+1
	gpu.set(x,y,"Output")
		y=y+1
	gpu.set(x,y,"Heat")
		y=y+1
	gpu.set(x-4,y,"--------------------------------------")
		y=y+1
	gpu.set(x,y,"Battery")
		y=y+1
	gpu.set(x,y,"Usage")
		y=y+1
	gpu.set(x-4,y,"--------------------------------------")
		y=y+1
	gpu.set(x,y,"Remaining")
		y=y+1
	Graphic.drawFrame(white, black, x-4, y, x+32, y+2)
end --end drawLabel

function Graphic.drawData()
	local energy = Power.energyUsage()
	local rem = Power.timeRemaining()
	local status = Power.checkStatus()
	local output = Power.checkEnergy()
	local heat = Power.checkHeatPercent()
	local bat = Power.checkBatteryPercent()

	local w, h = gpu.getResolution()
	local x = w-25
	local y = 4
	
	if status == true then gpu.set(x,y,"ON    ") else gpu.set(x,y,"OFF    ") end
		y=y+1
	--Adding a space
		y=y+1
	gpu.set(x,y, string.format("%.0f EU/t    ", output))
		y=y+1
	gpu.set(x,y,heat)
		y=y+1
	--Adding a space
		y=y+1
	gpu.set(x,y,bat)
		y=y+1
	if energy > 0 then gpu.set(x,y,string.format("+%.0f EU/t    ", energy)) else gpu.set(x,y,string.format("%.0f EU/t    ", energy)) end
		y=y+1
	--Adding a space
		y=y+1
	gpu.set(x,y,rem)
		y=y+1
end --end drawData

function Graphic.drawFrame(color, fill, x1, y1, x2, y2)
	local width  = x2 - x1
	local height = y2 - y1

	gpu.setBackground(color)
	gpu.fill(x1, y1, width, height, " ")
	
	gpu.setBackground(fill)
	if not ((x1 == x2    or
	         x1 == x2-1  or
			 x1 == x2+1) and
			(y1 == y2    or
			 y1 == y2-1  or
	         y1 == y2-2 )) 
	then
		gpu.fill(x1+1, y1+1, width-1, height-1, " ")
	end
end --end drawFrame

return Graphic