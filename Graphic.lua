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
local string    = require("string")
local Power = require("Power")
local Cleanroom = require("Cleanroom")

local gpu = component.gpu

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

------------Generic Functions------------

function Graphic.clearScreen()
	gpu.setBackground(COLOR.black)
	gpu.fill(1, 1, W, H, " ")
end --clears the screen

function Graphic.setupResolution()
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

function Graphic.drawFrame(clr, x1, y1, x2, y2)
	local powerBarWidth  = x2 - x1 + 1
	local height = y2 - y1 + 1
	local bg = gpu.getBackground()

	gpu.setBackground(clr)
	gpu.fill(x1, y1, powerBarWidth, height, " ")
	
	gpu.setBackground(bg)

	if powerBarWidth > 2 or height > 2 then
		gpu.fill(x1+1, y1+1, powerBarWidth-2, height-2, " ")
	end

end --end drawFrame

function Graphic.drawBox(clr, x1, y1, x2, y2)
	local powerBarWidth  = x2 - x1 + 1
	local height = y2 - y1 + 1
	local bg = gpu.setBackground(clr)

	gpu.fill(x1, y1, powerBarWidth, height, " ")
	gpu.setBackground(bg)
end --end drawBox

function Graphic.drawTitle(text)
	gpu.setBackground(COLOR.darkGrey)
	gpu.setForeground(COLOR.darkAqua)
	gpu.fill(1,1,W,1," ")
	gpu.set(W/2-string.len(text)/2,1,text)
	gpu.setBackground(COLOR.black)
	gpu.setForeground(COLOR.white)
end --end drawTitle

------------Power Functions------------

function Graphic.drawPowerLabel(x, y)
	gpu.set(x,y,"Reactor Status")
	y=y+1
	gpu.set(x,y,"Reactor Output")
	y=y+2
	gpu.set(x,y,"Power Usage")
end --end drawLabel

function Graphic.updatePowerData(x, y)
	local energy = Power.energyUsage()
	local rem = Power.timeRemaining()
	local status = Power.checkStatus()
	local output = Power.checkEnergy()
	--local heat = Power.checkHeatPercent()
	--local storage = Power.checkStorage()
	--local fuel = Power.checkFuelRem()

	if Power.reactorStatus == true then
		gpu.setForeground(COLOR.green)
		gpu.set(x,y,"ON    ")
		gpu.setForeground(COLOR.white)
		gpu.set(x+20,y,rem)
	else
		gpu.setForeground(COLOR.red)
		gpu.set(x,y,"OFF    ")
		gpu.setForeground(COLOR.white)
		gpu.fill(x+20,y,20,1," ")
	end
		y=y+1
		
	gpu.set(x,y, string.format("%.0f EU/t    ", output))
		y=y+1
		y=y+1
	
	if energy > 0 then gpu.set(x,y,string.format("+%.0f EU/t    ", energy)) else gpu.set(x,y,string.format("%.0f EU/t    ", energy)) end
	--gpu.set(10,H-4, string.format(fuel.." Fuel Remaining"))
	--gpu.set(W-26,H-4, string.format(storage.." in buffer"))

	--Graphic.updatePowerBar() --updates power bar on tick
end --end updateData

function Graphic.updatePowerBar(x, y, powerBarWidth)
	local powerLevel = Power.checkBatteryLevel()
	local fillWidth = math.floor(powerBarWidth * powerLevel)
	local bat = Power.checkBatteryPercent()


	if fillWidth > 0 then
		gpu.setBackground(COLOR.green)
		gpu.fill(x, y, fillWidth, 1, " ")
	end

	if fillWidth < 0 then
		gpu.setBackground(COLOR.red)
		gpu.fill(x, y, powerBarWidth, 1, " ")
	end

	gpu.setBackground(COLOR.black)
	local textX = Graphic.centerText((x + powerBarWidth)/2, bat)
	gpu.set(textX,y,bat)

	gpu.setBackground(COLOR.black)
end --end UpdatePowerBar

function Graphic.drawExit(x,y)
	local bg = gpu.setBackground(COLOR.red)
	local fg = gpu.setForeground(COLOR.white)

	gpu.fill(x,y,1,1,"X")
	
	gpu.setBackground(bg)
	gpu.setForeground(fg)
end --end drawExit

------------Cleanroom Functions------------

function Graphic.updateCleanroomStatus(x, y)
	if Cleanroom.getProblems() == '0' then
		gpu.set(x,y,"Cleanroom is ")
		gpu.setForeground(COLOR.green)
		gpu.set(x,y+1,"     OK      ")
		gpu.setForeground(COLOR.white)
	else
		gpu.set(x,y,"Cleanroom has")
		gpu.setForeground(COLOR.red)
		gpu.set(x,y+1,"  Problems!  ")
		gpu.setForeground(COLOR.white)
	end
end --end drawLabel

---------------Text Util---------------

function Graphic.centerText(x, text)
	local xLeft = x - string.len(text)/2
	return xLeft
end --end centerText

return Graphic