--[[
Date: 2021/07/21
Author: A. Jones & S. Huezo
Version: 3.0
Usage: A general page, to be used in conjunction with Main.lua
]]--
local FluidMonitor = {}
local Config    = require("Config")
------------General Libraries------------
local event     = require("event")
local keyboard  = require("keyboard")
local thread    = require("thread")
local component = require("component")
local computer  = require("computer")
local gpu       = component.gpu
------------Util Libraries------------
local Functions = require("Util\\Functions")
local Graphic   = require("Util\\Graphic")
------------Compenent Libraries------------
local LSC       = require("Components\\LSC")
local Reactor   = require("Components\\Reactor")
local Turbine   = require("Components\\Turbine")
local GtMachine = require("Components\\GtMachine")
------------Initilized Values------------
local TFFT      = GtMachine:new(Config.TFFT_A)

local threads = {}

----------------Main----------------
function FluidMonitor.startup()
    Graphic.clearScreen()
    Graphic.drawTitle("FLUID MONITORING SYSTEM") --draw title bar
    Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    threads = Functions.createThreads(FluidMonitor.mainUpdate)
end --end startupFunction

function FluidMonitor.mainUpdate()
    print( TFFT.getSensorInformation() )
end

return FluidMonitor