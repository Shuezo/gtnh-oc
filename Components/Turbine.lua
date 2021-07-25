--[[
Date: 2021/07/11 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
local Config    = require("Config")
------------Variables------------
local component = require("component")
local math      = require("math")
local Functions = require("Util\\Functions")
local GtMachine = require("Components\\GtMachine")

-------------------------------------------------------------------------
local Turbine   = GtMachine:new(Config.LG_GAS_TURBINE_A)
local redstone  = component.proxy(Config.REDSTONE_TURBINE)
-------------------------------------------------------------------------

Turbine.data  = {
                isOn        = nil,
                output      = 0,
                durability  = 100,
                problems    = nil,
                }

function Turbine.updateData()
    Turbine.data.isOn       = Turbine.isMachineActive()
    Turbine.data.output     = Turbine.checkOutput()
    Turbine.data.durability = Turbine.checkDurability()
    Turbine.data.problems   = Turbine:hasProblems()
end --end updateData

---- Turbine Telemetry ----

function Turbine.checkOutput() --returns unformatted string with EU output
    return tonumber(string.sub(Turbine.getSensorInformation()[1], 27, 30))
end --end checkOutput

function Turbine.checkDurability() --returns unformattted string representing percentile durability (0-100)
    if string.len(Turbine.getSensorInformation()[7]) == 25
    then return 100 - tonumber(string.sub(Turbine.getSensorInformation()[7], 20, 21))
    else return 100 - tonumber(string.sub(Turbine.getSensorInformation()[7], 20, 20))
    end
end --end checkDurability

---- Turbine Logic Control ----

function Turbine.switch() --logic for turning off the turbine
    if Turbine.data.durability <= Config.TURBINE_SAFETY_THRESHOLD then
        redstone.setOutput({ 0,  0,  0,  0,  0,  0})
        Turbine.data.isOn = false
    else redstone.setOutput({ 15,  15,  15,  15,  15,  15})
    end
end --end safetySwitch

return Turbine