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
local LSC       = require("Components\\LSC")

------------------------------------------------------------------------
local Reactor  = component.proxy("5ca155e9-ba43-4b65-8ba7-2b76d2e8b458")
local chest    = component.proxy("fa458337-2bdd-4161-94f1-c126ce8571ef")
local redstone = component.proxy("ac6e4538-fea3-44e0-ac6d-9820e915bc7e")
------------------------------------------------------------------------

local NUM_RODS = 14 --total number of fuel rods across all reactors in setup
local ON_THRESHOLD = 0.90 --enter as a decimal value
local OFF_THRESHOLD = 0.99

Reactor.data = {
                isOn = false,
                output = 0,
                fuel = 0,
                heat = 0,
                }

function Reactor.updateData()
    Reactor.data.isOn       = Reactor.checkStatus()
    Reactor.data.output     = Reactor.checkOutput()
    Reactor.data.fuel       = Reactor.checkFuelRem()
    Reactor.data.heat       = nil
end --end updataBatData

---- Reactor control ----
function Reactor.checkStatus() --returns true or false if reactor is running or not.
    if Reactor.producesEnergy() then
        Reactor.data.isOn = true
    else
        Reactor.data.isOn = false
    end
end --end checkStatus

function Reactor.on() -- turns reactor on via redstone
    local redstoneOn  = {15, 15, 15, 15, 15, 15}
    redstone.setOutput(redstoneOn)
    Reactor.data.isOn = true
end --end on

function Reactor.off() -- turns reactor off via redstone
    local redstoneOff = { 0,  0,  0,  0,  0,  0}
    redstone.setOutput(redstoneOff)
    Reactor.data.isOn = false
end --end off

function Reactor.switch() -- turns on and off the reactor depending on stored charge levels
    if not Reactor.data.isOn and LSC.data.Pcharge < ON_THRESHOLD then
        Reactor.on()
    elseif Reactor.data.isOn and LSC.data.Pcharge >= OFF_THRESHOLD then
        Reactor.off()
    end
end --end switch


------- Other Functions -------
function Reactor.checkHeatLevel()
    return Reactor.getHeat() / Reactor.getMaxHeat()
end --end checkHeat

function Reactor.checkOutput()
    return Reactor.getReactorEUOutput()
end --end checkOutput


------- Energy Reserves -------
function Reactor.checkFuelRem() --returns a value between 1 in 100 representing fuel remaining in reactor
    local a = ( 100 - chest.getStackInSlot(2,21)["damage"] ) * NUM_RODS --get durability of fuel in reactor (durability of 1 rod, multiplies by num of rods)
    local b = chest.getStackInSlot(4,4)["size"] * 100 --get amount of fuel rods in buffer
    local c = chest.getStackInSlot(4,3)["size"] * 100 --get amount of spent fuel rods
    return  (a + b) / (NUM_RODS + b + c)
end --end checkFuelRem

return Reactor