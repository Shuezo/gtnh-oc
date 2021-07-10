--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 2.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local Power = {}

local component = require("component")
local math      = require("math")
local Functions = require("Util\\Functions")
local GtMachine = require("Components\\GtMachine")

local reactor  = component.proxy("5ca155e9-ba43-4b65-8ba7-2b76d2e8b458")
local chest    = component.proxy("fa458337-2bdd-4161-94f1-c126ce8571ef")
local redstone = component.proxy("ac6e4538-fea3-44e0-ac6d-9820e915bc7e")

local bat = GtMachine:new("6bb64abc-8dfd-498f-9cf5-b7c62c11c2fa")

local NUM_RODS = 14

local batData = {
                    isOn        = false,
                    energyOut   = 0,
                    energyIn    = 0,
                    currCharge  = 0,
                    maxCharge   = 0,
                    ref         = {0,0},    -- 1st is current, 2nd is also current (unless changed)
                    time        = ""
                }

----------Main Functions----------

-- to be called in slower function
function Power.updateBatData() --pulls battery data from battery buffer
    local c, m, i, o = bat:sensorInfo({3,"a"}, {3,"e"}, {5}, {7})
    local tmpData = batData

    tmpData.currCharge  = c
    tmpData.maxCharge   = m
    tmpData.energyIn    = i
    tmpData.energyOut   = o
    tmpData.ref[1]      = c

    --Check if the buffer is out of batteries (or just really small, and never turn it on)
    if tmpData.maxCharge < 10000000  then --Arbitrary number, the size of 1 battery will be more than this
        tmpData.currCharge = tmpData.maxCharge
    end

    if tmpData.energyIn > 0 or reactor.producesEnergy() then
        tmpData.isOn = true
    else
        tmpData.isOn = false
    end

    batData = tmpData

end --end updateBatData

-- to be called in faster function to update CalcData
function Power.calcBatData() --manipulates battery data from battery buffer
    local tmpData = batData
    
    if tmpData.ref[1] ~= tmpData.ref[2] then
        tmpData.ref[2] = tmpData.ref[1]
        tmpData.currCharge = tmpData.ref[1]
    else
        tmpData.currCharge = tmpData.currCharge + (tmpData.energyIn - tmpData.energyOut) * 10 -- updates once every 0.5 seconds = 10 ticks
    end

    if tmpData.currCharge >= tmpData.maxCharge * 0.99 then
        if reactor.producesEnergy() then -- probably becomes a bit laggy, only really need to check if in manual mode
            tmpData.isOn = true
        else
            tmpData.isOn = false
        end

        Power.saveRef(tmpData)
        Power.updateBatData()
        Power.reactorPower() --if in manual mode, don't do this
    else
        Power.saveRef(tmpData)
    end

    Power.timeRemaining()

end -- end calcBatData

function Power.saveRef(dat) --Syncs calculated data with incomming data from APIs
    local ref = batData.ref[1]
    batData = dat
    batData.ref[2] = ref -- ref[1] saved to ref[2]
end --end saveRef

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
end --end GetData

------ Calculations -------

function Power.checkBatteryLevel()
    return Power.checkCurrentCharge() / Power.checkMaxCharge()
end -- end checkBatteryLevel

function Power.timeRemaining() -- calculates time remaining for battery to fill/empty
    local t = 0 --initialized time
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
        t = "No load                          "
    else
        t = (f - c) / u / 20 --time=(maxCharge-currentCharge/Usage)*conversion from ticks to seconds
        s = t % 60
        m = (t % 3600) / 60
        h = t / 3600
        t = string.format("%.0fh %.0fm %.0fs to full    ", h, m, s)
    end

    batData.time = t
    
end --end timeRemaining

---- Reactor control ----
function Power.reactorPower() -- checks reactor power status
    local reactorOn = batData.isOn
    if not reactorOn and Power.checkBatteryLevel() < 0.9 then
        Power.reactorOn()
    elseif reactorOn and Power.checkBatteryLevel() >= 0.99 then
        Power.reactorOff()
    end
end --end reactorPower

function Power.reactorOff() -- turns reactor off via redstone
    local redstoneOff = { 0,  0,  0,  0,  0,  0}
    redstone.setOutput(redstoneOff)
    batData.isOn = false
end --end reactorOff

function Power.reactorOn() -- turns reactor on via redstone
    local redstoneOn  = {15, 15, 15, 15, 15, 15}
    redstone.setOutput(redstoneOn)
    batData.isOn = true
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
    local a = ( 100 - chest.getStackInSlot(2,21)["damage"] ) * NUM_RODS --get durability of fuel in reactor (durability of 1 rod, multiplies by num of rods)
    local b = chest.getStackInSlot(4,4)["size"] * 100 --get amount of fuel rods in buffer
    local c = chest.getStackInSlot(4,3)["size"] * 100 --get amount of spent fuel rods
    return  (a + b) / (NUM_RODS + b + c)
end --end checkFuelRem


return Power
