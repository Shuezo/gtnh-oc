--2021 / 06 / 05
--Revision 0.1

-------------------------------------------Libraries-------------------------------------------
local component = require("component")
local event = require("event")
local tty = require("tty")
local term = require("term")
local thread = require("thread")
local computer = require("computer")
local gpu = component.gpu

-------------------------------------------Variables-------------------------------------------
local x, y = 0, 0                                          --Initialize resolution components
local maxSleepTime = 100
local currentStep = 0
local realTime1 = 0
local mcTime1 = 0
local x, y = gpu.getResolution()

local powerList = {}	                                   --Will store a bunch of power level values
local heatList = {}		                                   --Will store a bunch of heat level values

local GUI = {}
local Functions = {}

--Set Component ID's
local reactor = component.de831599-fabb-44a5-ac3c-4ac71a2f16f5
local chest = component.fa458337-2bdd-4161-94f1-c126ce8571ef
local bat = component.e4ecc183-dfe1-4fd0-a68f-56589d54902b

-------------------------------------------Admin Functions-------------------------------------------
--House Keeping Functions

function clear()
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

-------------------------------------------Measure Functions-------------------------------------------

--Reactor
function Functions.checkStatus()
    return reactor.producesEnergy()
end --end checkStatus

function Functions.checkEnergy()
    return reactor.getReactorEUOutput()
end --end checkEnergy

function Functions.checkHeatLevel()
    return reactor.getHeat() / reactor.getMaxHeat()
end --end checkHeat


--Battery Buffer
function Functions.checkEnergyLevel()
    return bat.getStoredEU() / bat.getEUCapacity()
end --end checkEnergyLevel

function Functions.energyUsage()
    return Functions.checkEnergy() - bat.getEUOutputAverage()
end --end energyUsage

-------------------------------------------Meter Functions-------------------------------------------

print(Functions.checkStatus())
print(Functions.checkHeatLevel())
print(Functions.checkEnergyLevel())
print(Functions.energyUsage())






--[[
function GUI.bar(color1, posX, posY, sizeW, sizeH)
	gpu.setBackground(color1)
	gpu.fill(posX, posY, sizeW, sizeH, " ")
end --end bar

function GUI.drawBars()
	local widthEnergy = (x/10*8-2) * checkEnergyLevel()
	local widthHeat = (x/10*8-2) * checkHeatLevel()
	local energyChange = currentStoredPower()
	local heatChange = currentHeatLevel()
	table.insert(powerList, 1, checkEnergyLevel())
	table.insert(heatList, 1, checkHeatLevel())
	
	gpu.setBackground(0x5A5A5A)
	
	--Powerlevel wording
	term.setCursor(x/10+13, y/10-1)
	term.write("   ")
	term.setCursor(x/10+13, y/10-1)
	term.write(math.floor(checkEnergyLevel()*100))
	term.setCursor(x/10+16, y/10-1)
	term.write("%")
	
	--Temperature level wording
	term.setCursor(x/10+13, y/10*2-1)
	term.write("   ")
	term.setCursor(x/10+13, y/10*2-1)
	term.write(math.floor(checkHeatLevel()*100))
	term.setCursor(x/10+16, y/10*2-1)
	term.write("%")
	
	energyChange = energyChange - currentStoredPower()
	if energyChange < 0 then
		GUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	elseif energyChange >= 0 then
		--GUI.bar(0x5A5A5A, x/10, y/10, x/10*8, 3)
		GUI.bar(0x5A5A5A, x/10+1, y/10+1, x/10*8-2, 1)
		GUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	else
		GUI.bar(0xCC4C4C, x/10+1, y/10+1, widthEnergy, 1)
	end
	
	heatChange = heatChange - currentHeatLevel()
	if heatChange < 0 then
		GUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	elseif heatChange >= 0 then
		--rGUI.bar(0x5A5A5A, x/10, y/10*2, x/10*8, 3)
		GUI.bar(0x5A5A5A, x/10+1, y/10*2+1, x/10*8-2, 1)
		GUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	else
		GUI.bar(0xF2B233, x/10+1, y/10*2+1, widthHeat, 1)
	end
	
	gpu.setForeground(0xF0F0F0)
	gpu.setBackground(0x5A5A5A)
end --end drawBars
--]]