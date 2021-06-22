--[[
Date: 2021/06/16 
Author: A. Jones & S. Huezo
Version: 1.1
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local Cleanroom = {}

local component = require("component")
local math      = require("math")
local string    = require("string")
local Functions = require("Functions")

local controller = component.proxy("989841fe-0184-4c2d-b793-583f0f63b8d4")

------------Functions------------

function Cleanroom.status()
    return controller.isMachineActive()
end --end check if machine is on

function Cleanroom.getProblems()
    return string.sub(controller.getSensorInformation()[5], 14, 14)
end --end getProblems (cleanroom controller)

return Cleanroom