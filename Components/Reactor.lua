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
local LSC       = require("Components\\LSC")
local Config    = require("Config")

-------------------------------------------------------------------------
local Reactor   = component.proxy(Config.REACTOR_A)
local chest     = component.proxy(Config.REACTOR_INV)
local redstone  = component.proxy(Config.REDSTONE_REACTOR)
-------------------------------------------------------------------------

local NUM_RODS              = 14 --total number of fuel rods across all reactors in setup
local NUM_REACTORS          = 2 -- total number of reactors chained together simultaneaously outputing the same EU

Reactor.data  = {
                isOn        = nil,
                output      = 0,
                fuel        = 0,
                heat        = 0,
                }

function Reactor.updateData()
    Reactor.data.isOn       = Reactor.checkStatus()
    Reactor.data.output     = Reactor.checkOutput()
    Reactor.data.fuel       = Reactor.checkFuelRem()
    Reactor.data.heat       = nil
end --end updataData

---- Reactor control ----
function Reactor.checkStatus() --returns true or false if reactor is running or not.
    if Reactor.producesEnergy() then return true else return false end
end --end checkStatus

function Reactor.on() -- turns reactor on via redstone
    local redstoneOn  = {15, 15, 15, 15, 15, 15}
    redstone.setOutput(redstoneOn)
    Reactor.data.isOn = true
end --end on

function Reactor.off() -- turns reactor off via redstone
    local redstoneOff = { 0,  0,  0,  0,  0,  0}
    redstone.setOutput(redstoneOff)
    if Reactor.checkStatus() == true then return end
    Reactor.data.isOn = false
end --end off

function Reactor.switch() -- turns on and off the reactor depending on stored charge levels
    if not Reactor.data.isOn and LSC.data.Pcharge < Config.REACTOR_ON_THRESHOLD then
        Reactor.on()
    elseif Reactor.data.isOn and LSC.data.Pcharge >= Config.REACTOR_OFF_THRESHOLD then
        Reactor.off()
    end
end --end switch


------- Other Functions -------
function Reactor.checkHeatLevel() --returns percentage heat in system.
    return Reactor.getHeat() / Reactor.getMaxHeat()
end --end checkHeat

function Reactor.checkOutput() --returns EU output for two reactors
    return Reactor.getReactorEUOutput() * NUM_REACTORS 
end --end checkOutput


------- Energy Reserves -------
function Reactor.checkFuelRem() --returns a value between 1 in 100 representing fuel remaining in reactor
    local a = chest.getStackInSlot(2,21)["damage"] --get durability of fuel in reactor (durability of 1 rod, multiplies by num of rods)
    local b = chest.getStackInSlot(4,4)["size"] --get amount of fuel rods in buffer
    local c = chest.getStackInSlot(4,3)["size"] --get amount of spent fuel rods
    if a ~= nil then a = (100 - a) * NUM_RODS / 100 else return 0 end
    if b ~= nil then b = b * 100 else return 0 end
    if c ~= nil then c = c * 100 else return 0 end
    return  (a + b) / (NUM_RODS + b + c)
end --end checkFuelRem

return Reactor
