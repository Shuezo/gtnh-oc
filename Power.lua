--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local Power = {}

local component = require("component")
local math      = require("math")

local reactor  = component.proxy("de831599-fabb-44a5-ac3c-4ac71a2f16f5")
local chest    = component.proxy("fa458337-2bdd-4161-94f1-c126ce8571ef")
local bat      = component.proxy("e4ecc183-dfe1-4fd0-a68f-56589d54902b")
local redstone = component.proxy("3c96c747-346c-422d-bae0-bc1918f43ea6")

reactorStatus = nil

----------Functions----------

--Parsing Data from the API for the reactor
function Power.checkStatus()
    return reactor.producesEnergy()
end --end checkStatus

function Power.checkEnergy()
    return reactor.getReactorEUOutput()
end --end checkEnergy

function Power.checkHeatLevel()
    return reactor.getHeat() / reactor.getMaxHeat()
end --end checkHeat

function Power.checkHeatPercent()
    return string.format("%.2f %%", Power.checkHeatLevel() * 100)
end

--Battery Buffer Calculations to get full charge (iterating through each battery until it reaches an empty slot)
function Power.checkCurrentCharge()
	local i = 1
	local total = 0
    
	repeat
		total = total + bat.getBatteryCharge(i)
		i = i + 1
	until bat.getBatteryCharge(i) == nil
	
	return total
end --end checkCurrentCharge

function Power.checkMaxCharge()
	local i = 1
	local total = 0
    
	repeat
		total = total + bat.getMaxBatteryCharge(i)
		i = i + 1
	until bat.getMaxBatteryCharge(i) == nil
	
	return total
end --end checkMaxCharge


--Parsing data from the API for the GT Battery Buffer and performing calculations using above
function Power.energyUsage()
    return Power.checkEnergy() - bat.getEUOutputAverage()
end --end energyUsage

function Power.checkBatteryLevel()
	return Power.checkCurrentCharge() / Power.checkMaxCharge()
end

function Power.checkBatteryPercent()
    return string.format("%.2f%%   ", Power.checkBatteryLevel() * 100)
end

function Power.timeRemaining()
	local t = 0 --placeholder for time
	local m = 0 --calculated minutes
	local s = 0 --caluclated seconds
	local h = 0 --calculated hours
	local c = Power.checkCurrentCharge()
	local u = Power.energyUsage()
	local f = Power.checkMaxCharge()

	if u < 0 then
		t = math.abs(c / u) / 20 --time=(currentCharge/Usage)*coversion from ticks to seconds
		s = t % 60
		m = (t % 3600) / 60
		h = t / 3600
		t = string.format("%.0fh %.0fm %.0fs to empty   ", h, m, s)
	elseif u == 0 then
		t = "N/A                          "
	else
		t = (f - c) / u / 20 --time=(maxCharge-currentCharge/Usage)*conversion from ticks to seconds
		s = t % 60
		m = (t % 3600) / 60
		h = t / 3600
		t = string.format("%.0fh %.0fm %.0fs to full   ", h, m, s)
	end

	return t
end --end timeRemaining

--Event handler to power on/off the reactor
function Power.reactorPower()
	if reactorStatus == false and Power.checkBatteryLevel() < 0.9 then
		Power.reactorOn()
	else
		Power.reactorOff()
	end
end --end reactorPower

function Power.reactorOff()
	local redstoneOff = { 0,  0,  0,  0,  0,  0}
	redstone.setOutput(redstoneOff)
	reactorStatus = false
end --end reactorOff

function Power.reactorOn()
	local redstoneOn  = {15, 15, 15, 15, 15, 15}
	redstone.setOutput(redstoneOn)
	reactorStatus = true
end --end reactorOn

function Power.checkStorage() --returns EU from durability of fuel rods in buffer chest
	local total = 0
	local output = ''
	local m = chest.getInventorySize(4)

	for i=1,m do
		if chest.getStackInSlot(4,i) ~= nil then
			total = total + ((100 - chest.getStackInSlot(4,i)["damage"]) * chest.getStackInSlot(4,i)["size"])
		else
		end
	end

	total = 192000 * total --192k EU per 1 durability of quad thorium rods.

	if total < 100000 then
		output = string.format("%.0f EU", total)
	elseif total >= 100000 and total < 1000000 then
		total = total / 1000
		output = string.format("%.0fK EU", total)
	elseif total >=1000000 and total < 1000000000 then
		total = total / 1000000
		output = string.format("%.0fM EU", total)
	elseif total > 1000000000 then
		total = total /  1000000000
		output = string.format("%.0fB EU", total)
	end
		
	return output
end --end checkStorage

function Power.checkFuelRem() --returns approx EU from durability remaining for fuel rods in reactor
	local total = 0
	local output = ''
	
	total = chest.getStackInSlot(2,20)["damage"]
	total = (100-total) * 10 * 192000 --10 fuel rods total, 192k EU per durability point

	if total < 1000000 then
		total = total / 1000
		output = string.format("%.0fK EU", total)
	elseif total >=1000000 and total < 1000000000 then
		total = total / 1000000
		output = string.format("%.0fM EU", total)
	elseif total > 1000000000 then
		total = total /  1000000000
		output = string.format("%.0fB EU", total)
	end

	return output
end --end checkFuelRem

return Power
