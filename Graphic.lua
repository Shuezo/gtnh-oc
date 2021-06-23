--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.2
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local Graphic = {}

local component = require("component")
local term = require("term")
local string    = require("string")

local Functions = require("Functions")
local Power = require("Power")
local GtMachine = require("GtMachine")

local Cleanroom = GtMachine:new("989841fe-0184-4c2d-b793-583f0f63b8d4")
local EBF = GtMachine:new("c1b4311d-993d-4d9b-8da0-71c97f8e003b")

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

function Graphic.SplashScreen(textA, textB)
	Graphic.drawBox(COLOR.darkGrey, 1, 1, W, H)
	Graphic.drawExit(W, 1)
	Graphic.drawFrame(COLOR.lightGrey, COLOR.darkGrey, W/2-10, H/2-3, W/2+10, H/2+2)
	gpu.setForeground(COLOR.green)
	gpu.setBackground(COLOR.darkGrey)
	gpu.set(Functions.centerText(W/2, textA),H/2-1, textA)
	gpu.set(Functions.centerText(W/2, textB),H/2, textB)
	gpu.setForeground(COLOR.white)
	gpu.setBackground(COLOR.black)
end

function Graphic.buffer()
	--set buffer to not 0
	--display data on buffer
	--wait until data loads
	--remove 
	gpu.setActiveBuffer()
end

function Graphic.drawFrame(clr, fill, x1, y1, x2, y2)
	local barWidth  = math.abs(x2 - x1) + 1
	local height = math.abs(y2 - y1) + 1
	local bg = gpu.getBackground()
	
	gpu.setBackground(clr)
	gpu.fill(x1, y1, barWidth, height, " ")
	gpu.setBackground(fill)

	if barWidth > math.abs(2) or height > math.abs(2) then
		gpu.fill(x1+1, y1+1, barWidth-2, height-2, " ")
	end
	gpu.setBackground(bg)
end --end drawFrame

function Graphic.drawBox(clr, x1, y1, x2, y2)
	local barWidth = math.abs(x2 - x1) + 1
	local height = math.abs(y2 - y1) + 1
	local bg = gpu.getBackground()

	gpu.setBackground(clr)
	gpu.fill(x1, y1, barWidth, height, " ")
	
	gpu.setBackground(bg)
end --end drawBox

function Graphic.drawTitle(text)
	gpu.setBackground(COLOR.darkGrey)
	gpu.setForeground(COLOR.darkAqua)
	gpu.fill(1,1,W,1," ")
	gpu.set(Functions.centerText(W/2, text),1,text)
	gpu.setBackground(COLOR.black)
	gpu.setForeground(COLOR.white)
end --end drawTitle

function Graphic.drawExit(x,y)
	local bg = gpu.setBackground(COLOR.red)
	local fg = gpu.setForeground(COLOR.white)

	gpu.fill(x,y,1,1,"X")
	
	gpu.setBackground(bg)
	gpu.setForeground(fg)
end --end drawExit

------------Power Functions------------

function Graphic.updatePowerData()
	local batData 	= Power.getData()
	
	local energy 	= batData.energyIn - batData.energyOut
	local rem 		= batData.time
	local output 	= batData.energyIn
	local status 	= batData.isOn

	--local heat = Power.checkHeatpercent()
	--local storage = Power.checkStorage()
	--local fuel = Power.checkFuelRem()

	gpu.set(8,H-5, "Reactor is ")
	if status == true then
		gpu.setForeground(COLOR.green)
		gpu.set(19,H-5,"ON ")
		gpu.setForeground(COLOR.white)
		Graphic.drawBox(COLOR.green, 3, H-5, 6, H-4)
	else
		gpu.setForeground(COLOR.red)
		gpu.set(19,H-5,"OFF")
		gpu.setForeground(COLOR.white)
		Graphic.drawBox(COLOR.red, 3, H-5, 6, H-4)
	end
			
	gpu.set(8,H-4, string.format("Output: %.0f EU/t    ", output))
	--if energy > 0 then gpu.set(55,H-4,string.format("Net: +%.0f EU/t    ", energy)) else gpu.set(x,y,string.format("Net: %.0f EU/t    ", energy)) end

	gpu.setBackground(COLOR.darkGrey)
	--gpu.setForeground(COLOR.white)
	gpu.set(4,H-2,"Battery Buffer: " .. rem)

	gpu.setBackground(COLOR.black)
end --end updateData


--[[Graphic.updatePowerBar(level, X, Y, barWidth)

	level: 		Value to calculate bar fill and set label 
	X:			Hor Bar Position
	Y: 			Vertical Bar Position
	barWidth: 	Width of bar

]]--
function Graphic.updatePowerBar(level, x, y, barWidth, fillColor, emptyColor)
	local fillWidth = math.ceil(barWidth * level)
	local percent = Functions.getPercent(level)
	local textX = Functions.centerText((x + barWidth)/2, percent)
	local emptyWidth = barWidth - fillWidth

	if fillWidth > 0 then
		gpu.setBackground(fillColor)
		for pos=x,x+fillWidth do
			if pos>=textX and pos<textX+string.len(percent) then
				gpu.set(pos, y, string.sub(percent,1+pos-textX,1+pos-textX))
			else
				gpu.set(pos,y," ")
			end
		end
	end

	if emptyWidth > 0 then
		gpu.setBackground(emptyColor)
		for pos=x+fillWidth+1,x+barWidth do
			if pos>=textX and pos<textX + string.len(percent) then
				gpu.set(pos, y, string.sub(percent,pos-textX+1,pos-textX+1))
			else
				gpu.set(pos,y," ")
			end
		end
	end

	gpu.setBackground(COLOR.black)
end --end UpdatePowerBar

------------Cleanroom Functions------------

function Graphic.updateCleanroomStatus(x, y)
	gpu.setBackground(COLOR.darkGrey)
	gpu.setForeground(COLOR.darkAqua)
	gpu.set(x,y," Cleanroom ")
	gpu.setForeground(COLOR.white)
	gpu.set(x,y+1,"  Status:  ")
	if Cleanroom:getProblems() == '0' and Cleanroom:status() == true then
		gpu.setForeground(COLOR.green)
		gpu.set(x,y+2,"    OK     ")
	elseif Cleanroom:getProblems() == '0' and Cleanroom:status() == false then
		gpu.setForeground(COLOR.red)
		gpu.set(x,y+1," Inactive! ")
	else
		gpu.setForeground(COLOR.red)
		gpu.set(x,y+1," Problems! ")
	end
	gpu.setForeground(COLOR.white)
	gpu.setBackground(COLOR.black)
end --end drawLabel

------------EBF Functions------------

function Graphic.updateEBFStatus(x, y)
	gpu.setBackground(COLOR.darkGrey)
	gpu.setForeground(COLOR.darkAqua)
	gpu.set(x,y,"    EBF    ")
	gpu.setForeground(COLOR.white)
	if EBF:getProblems() ~= '0' then
		gpu.setForeground(COLOR.red)
		gpu.set(x,y+1," Problems! ")
		return
	else
		if EBF:status() == true then
			local tally = 0
			local task = EBF:craftingStatus()
			gpu.set(x,y+1,"  Active:  ")
			gpu.set(x,y+2,task)
		else
			gpu.set(x,y+1," Inactive. ")
			gpu.set(x,y+2,"           ")
		end
	end
	gpu.setForeground(COLOR.white)
	gpu.setBackground(COLOR.black)
end

return Graphic