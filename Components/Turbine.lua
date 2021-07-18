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

-------------------------------------------------------------------------
local Turbine   = GtMachine:new("cc5ead40-5cd1-4df9-966a-671b41e20d38")
local redstone  = component.proxy("cd5f5cfe-81e6-4ef6-b3bd-955ccb08f48a")
-------------------------------------------------------------------------

local SAFETY_THRESHOLD = 2

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
    Turbine.switch()
    return 100 - tonumber(string.sub(Turbine.getSensorInformation()[7], 20, 21))
end --end checkDurability

---- Turbine Logic Control ----

function Turbine.switch() --logic for turning off the turbine
    if Turbine.data.durability <= SAFETY_THRESHOLD then
        redstone.setOutput({ 0,  0,  0,  0,  0,  0})
        Turbine.data.isOn = false
    else redstone.setOutput({ 15,  15,  15,  15,  15,  15})
    end
end --end safetySwitch

return Turbine