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

local batData =	{
					isOn 		= false,
					energyOut 	= 0,
					energyIn	= 0,
					currCharge 	= 0,
					maxCharge  	= 0,
					isNew	 	= true, 	-- true when data is new (for calcData)
					time		= ""
				}

----------Main Functions----------

-- to be called in slower function
function Power.updateBatData()
	local tmp
	local dat = bat.getSensorInformation()

	batData.isNew = true
	tmp = string.match(dat[3],"§a.+§r EU /")
	tmp = string.gsub(tmp,"[§arEU/, ]","")
	batData.currCharge = tonumber(tmp)

	tmp = string.match(dat[3],"§e.+§r")
	tmp = string.gsub(tmp,"[§er,]","")
	batData.maxCharge = tonumber(tmp)

	tmp = string.gsub(dat[5],"[EUt,/ ]","")
	batData.energyIn = tonumber(tmp)

	tmp = string.gsub(dat[7],"[EUt,/ ]","")
	batData.energyOut = tonumber(tmp)

	--Check if the buffer is out of batteries (or just really small, and never turn it on)
	if batData.maxCharge < 10000000  then --Arbitrary number, the size of 1 battery will be more than this
		batData.currCharge = batData.maxCharge
	end

	if batData.energyIn > 0 or reactor.producesEnergy() then
		batData.isOn = true
	else
		batData.isOn = false
	end

end --end updateBatData

-- to be called in faster function to update CalcData
function Power.calcBatData()
	
	if batData.isNew then
		batData.isNew = false
	else
		batData.currCharge = batData.currCharge + Power.energyUsage() * 10 -- updates once every 0.5 seconds = 10 ticks
	end

	if batData.currCharge >= batData.maxCharge * 0.999 then
		if reactor.producesEnergy() then
			batData.isOn = true
		end
		Power.updateBatData()
		Power.reactorPower()
	end
end -- end calcBatData

-------- GET functions ---------

function Power.isReactorOn()
    return batData.isOn
end --end checkStatus

function Power.checkEnergy()
    return batData.energyIn
end --end checkEnergy

function Power.checkHeatLevel()
    return reactor.getHeat() / reactor.getMaxHeat()
end --end checkHeat

function Power.checkCurrentCharge()
	return batData.currCharge
end --end checkCurrentCharge

function Power.checkMaxCharge()
	return batData.maxCharge
end --end checkMaxCharge

function Power.energyUsage()
    return Power.checkEnergy() - batData.energyOut
end --end energyUsage

function Power.getData()
	return batData
end

------ Calculations -------

function Power.checkBatteryLevel()
	return Power.checkCurrentCharge() / Power.checkMaxCharge()
end -- end checkBatteryLevel

function Power.timeRemaining()
	local t = 0 --placeholder for time
	local m = 0 --calculated minutes
	local s = 0 --caluclated seconds
	local h = 0 --calculated hours
	local dat = batData
	local c = dat.currCharge
	local u = dat.energyIn - dat.energyOut
	local f = dat.maxCharge

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

---- Reactor control ----
function Power.reactorPower()
	local reactorOn = Power.isReactorOn()
	if not reactorOn and Power.checkBatteryLevel() < 0.995 then
		Power.reactorOn()
	elseif reactorOn and Power.checkBatteryLevel() >= 0.999 then
		Power.reactorOff()
	end
end --end reactorPower

function Power.reactorOff()
	local redstoneOff = { 0,  0,  0,  0,  0,  0}
	redstone.setOutput(redstoneOff)
end --end reactorOff

function Power.reactorOn()
	local redstoneOn  = {15, 15, 15, 15, 15, 15}
	redstone.setOutput(redstoneOn)
end --end reactorOn

------- Energy Reserves -------

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

function Power.checkFuelRem() --returns a value between 1 in 100 representing fuel remaining in reactor
	return ( 100 - chest.getStackInSlot(2,20)["damage"] ) / 100
end --end checkFuelRem

-------Helper Functions-------
function Power.average(t)
	local sum = 0
	for _,v in pairs(t) do -- Get the sum of all numbers in t
		sum = sum + v
	end
	return sum / #t
end



return Power
