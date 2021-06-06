
local component = require("component")
local gpu = component.gpu

local x, y = gpu.getResolution()

local Functions = {}

local reactor = component.proxy("de831599-fabb-44a5-ac3c-4ac71a2f16f5")
local chest = component.proxy("fa458337-2bdd-4161-94f1-c126ce8571ef")
local bat = component.proxy("e4ecc183-dfe1-4fd0-a68f-56589d54902b")

function Clear()
    gpu.fill(1, 1, x, y, " ")
end --clears the screen



-------------------------------------------Battery Calculations-------------------------------------------

function Functions.checkCurrentCharge()
	local i = 1
	local total = 0
    
	repeat
		total = total + bat.getBatteryCharge(i)
		i = i + 1
	until bat.getBatteryCharge(i) == nil
	
	return total
end --end checkCurrentCharge

function Functions.checkMaxCharge()
	local i = 1
	local total = 0
    
	repeat
		total = total + bat.getMaxBatteryCharge(i)
		i = i + 1
	until bat.getMaxBatteryCharge(i) == nil
	
	return total
end --end checkMaxCharge

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
function Functions.energyUsage()
    return Functions.checkEnergy() - bat.getEUOutputAverage()
end --end energyUsage

function Functions.checkBatteryLevel()
	return Functions.checkCurrentCharge() / Functions.checkMaxCharge()
end

-------------------------------------------Meter Functions-------------------------------------------

print(Functions.checkStatus())
print(Functions.checkHeatLevel())
print((Functions.checkBatteryLevel() * 100) .. "%")
print(Functions.energyUsage())