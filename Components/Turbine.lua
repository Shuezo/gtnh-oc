--[[
Date: 2021/07/11 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local component = require("component")
local math      = require("math")
local Functions = require("Util\\Functions")
local GtMachine = require("Components\\GtMachine")

------------------------------------------------------------------------
local Turbine   = GtMachine:new("cc5ead40-5cd1-4df9-966a-671b41e20d38")
local redstone  = component.proxy("0f707138-4a56-4eae-9bab-44b9219a57c6")
------------------------------------------------------------------------

local safety_threshold = 2

Turbine.data = {
                isOn        = nil,
                output      = 0,
                problems    = 0,
                durability  = 0,
                }

function Turbine.updateData()
    Turbine.data.isOn       = Turbine:status()
    Turbine.data.output     = Turbine.checkOutput()
    Turbine.data.durability = Turbine.checkDurability()
end --end updateData

---- Turbine Telemetry ----

function Turbine.checkOutput() --returns string with EU output (unformatted)
    return string.sub(Turbine.getSensorInformation()[1], 27, 30) end

function Turbine.checkProblems() -- returns boolean if problems exist or not.
    if string.sub(Turbine.getSensorInformation()[2]) == '§aNo Maintenance Issues§r' then return false
    else return true end
end --end checkProblems

function Turbine.checkDurability() --returns unformattted string representing percentile durability (0-100)
    return string.sub(Turbine.getSensorInformation()[7], 20, 21) end


---- Turbine Logic Control ----

function Turbine.shutdown()
    local redstoneOff = { 0,  0,  0,  0,  0,  0}
    redstone.setOutput(redstoneOff)
    Turbine.data.isOn = false
end

function Turbine.safetySwitch()
    if Turbine.data.durability <= safety_threshold then Turbine.shutdown()
    else return end
end



return Turbine