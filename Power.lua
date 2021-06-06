
-------------------------------------------Variables-------------------------------------------
local Power = {}

local component = require("component")

local reactor = component.proxy("de831599-fabb-44a5-ac3c-4ac71a2f16f5")
local chest = component.proxy("fa458337-2bdd-4161-94f1-c126ce8571ef")
local bat = component.proxy("e4ecc183-dfe1-4fd0-a68f-56589d54902b")

-------------------------------------------Functions-------------------------------------------

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
    return string.format("%.2f %%", Power.checkBatteryLevel() * 100)
end