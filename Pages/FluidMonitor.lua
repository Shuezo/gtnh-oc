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
local TFFT      = GtMachine:new(TFFT_A)

----------------Main----------------
function FluidMonitor.startupFunction()
    Graphic.clearScreen()
    Graphic.drawTitle("FLUID MONITORING SYSTEM") --draw title bar
    Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    threads = Functions.createThreads(mainUpdate,
                                      updateBars)
end --end startupFunction

Graphic.setupResolution() --initial screen setup (hardware)
Graphic.clearScreen()

if QUICKBOOT == false then --provides override for buffer allocation and splashscreen
    Graphic.SplashScreen("Initializing...", "Please Wait")
    local buf = gpu.allocateBuffer(W,H)
    gpu.setActiveBuffer(buf)
    
    startupFunction()
    os.sleep(0.25)
    thread.waitForAll(threads)
    
    gpu.bitblt(0, 1, 1, W, H, buf, 1, 1) --load buffer onto screen
    gpu.freeBuffer(buf)
else
    startupFunction()
end

startTimers()

return FluidMonitor