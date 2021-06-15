--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local Graphic = {}

local component = require("component")
local term = require("term")
local Power = require("Power")

local gpu = component.gpu
local w, h = gpu.getResolution()

local color = { blue 		= 0x4286F4,
				darkAqua	= 0x3392FF,
				purple 		= 0xB673d6,
				red 		= 0xC14141,
				green 		= 0x0DA841,
  				black 		= 0x000000,
				white 		= 0xFFFFFF,
				grey 		= 0x252525,
				lightGrey 	= 0xBBBBBB,
				darkGrey 	= 0x262626 }

------------Functions------------

function Graphic.clearScreen()
	gpu.setBackground(color.black)
	gpu.fill(1, 1, w, h, " ")
end --clears the screen

function Graphic.setupResolution()
	--Use the resolution to help position all of the UI elements
	--Also sets the resolution to the maximum that is possible
	local maxW, maxH = gpu.maxResolution()
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

function Graphic.drawFrame(clr, x1, y1, x2, y2)
	local width  = x2 - x1 + 1
	local height = y2 - y1 + 1
	local bg = gpu.getBackground()
	gpu.setBackground(clr)
	gpu.fill(x1, y1, width, height, " ")
	
	gpu.setBackground(bg)

	if width > 2 or height > 2 then
		gpu.fill(x1+1, y1+1, width-2, height-2, " ")
	end
end --end drawFrame

function Graphic.drawBox()
	gpu.setBackground(color.darkGrey)
	gpu.fill(1,h-3,w,4," ")
	gpu.setBackground(color.black)
end --end drawBox

function Graphic.drawTitle(text)
	gpu.setBackground(color.darkGrey)
	gpu.setForeground(color.darkAqua)
	gpu.fill(1,1,w,1," ")
	gpu.set(w/2-string.len(text)/2,1,text)
	gpu.setBackground(color.black)
	gpu.setForeground(color.white)
end --end drawTitle

function Graphic.drawLabel(x, y)
	gpu.set(x,y,"Reactor Status")
	y=y+1
	gpu.set(x,y,"Reactor Output")
	y=y+2
	gpu.set(x,y,"Power Usage")
end --end drawLabel

function Graphic.updateData()
	local energy = Power.energyUsage()
	local rem = Power.timeRemaining()
	local status = Power.checkStatus()
	local output = Power.checkEnergy()
	--local heat = Power.checkHeatPercent()
	local bat = Power.checkBatteryPercent()
	--local storage = Power.checkStorage()
	--local fuel = Power.checkFuelRem()

	local x = 30
	local y = 3

	if Power.reactorStatus == true then
		gpu.setForeground(color.green)
		gpu.set(x,y,"ON    ")
		gpu.setForeground(color.white)
		gpu.set(x+20,y,rem)
	else
		gpu.setForeground(color.red)
		gpu.set(x,y,"OFF    ")
		gpu.setForeground(color.white)
		gpu.fill(x+20,y,20,1," ")
	end
		y=y+1
	gpu.set(x,y, string.format("%.0f EU/t    ", output))
		y=y+1
	gpu.setBackground(color.darkGrey)
	gpu.set(w/2-4,h-2,bat)
	gpu.setBackground(color.black)
		y=y+1
	if energy > 0 then gpu.set(x,y,string.format("+%.0f EU/t    ", energy)) else gpu.set(x,y,string.format("%.0f EU/t    ", energy)) end
	--gpu.set(10,h-4, string.format(fuel.." Fuel Remaining"))
	--gpu.set(w-26,h-4, string.format(storage.." in buffer"))

	Graphic.updatePowerBar() --updates power bar on tick
end --end updateData

function Graphic.updatePowerBar(powerBarX, powerBarY, powerBarWidth)
	local powerLevel = Power.checkBatteryLevel()
	local fillWidth = math.floor(powerBarWidth * powerLevel)
	local emptyWidth = powerBarWidth - fillWidth - 1

	local pos
	if fillWidth > 0 then
		gpu.setBackground(color.green)
		for pos=powerBarX,powerBarX+fillWidth do
			gpu.set(pos, powerBarY, " ")
		end
	end

	if emptyWidth > 0 then
		gpu.setBackground(color.red)
		for pos=powerBarX+fillWidth+1,powerBarX+powerBarWidth do
			gpu.set(pos,powerBarY, " ")
		end
	end

	gpu.setBackground(color.black)
end --end UpdatePowerBar

return Graphic