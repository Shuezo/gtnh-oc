--[[
Date: 2021/06/17 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local EBF = {}

local component = require("component")
local math      = require("math")
local string    = require("string")

local controller = component.proxy("c1b4311d-993d-4d9b-8da0-71c97f8e003b")

------------Functions------------

function EBF.status()
    return controller.isMachineActive()
end --end check if machine is on

function EBF.getProblems()
    return string.sub(controller.getSensorInformation()[5], 14, 14)
end --end getProblems (EBF controller)

function EBF.craftingStatus()
    return string.format( controller.getWorkProgress() / 20 .. "s / " .. controller.getWorkMaxProgress() / 20 .. "s")
end --end craftingStatus (of EBF controller)

return EBF