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
local TThreads  = require("Util\\TThreads")
------------Compenent Libraries------------
local LSC       = require("Components\\LSC")
local Reactor   = require("Components\\Reactor")
local Turbine   = require("Components\\Turbine")
local GtMachine = require("Components\\GtMachine")
------------Initilized Values------------
local TFFT      = GtMachine:new(Config.TFFT_A)
local timers = {}
local dat = {}
local fluidName = {}
local fluidAmount = {}
----------------Main----------------

local function splitTable()
    fluidName = {}
    fluidAmount = {}
    for k,v in ipairs(dat) do
        if k>1 and k<=26 then
            table.insert(fluidName, string.sub(v, (string.find(v,'-') + 2), (string.find(v,':') - 1) ) )
        end
    end

    for k,v in ipairs(dat) do
        if k>1 and k<=26 then
            table.insert(fluidAmount, string.sub(v, (string.find(v, ':') + 2), (string.find(v, 'L') - 4) ) )
        end
    end
return fluidName, fluidAmount
end

local function drawData(t, x, y)
    z = y
    for k,v in ipairs(t) do
        if k>1 and k<=13 then
            gpu.set(x, y, v)
            y = y + 2
        elseif k>13 and k<=26 then
            x = W/2
            gpu.set(x, z, v)
            z = z + 2
        end
    end
end

local function mainUpdate()
    dat = TFFT.getSensorInformation()
    splitTable()
    drawData(fluidName,2,2)
    drawData(fluidAmount,2,3)
end

function FluidMonitor.startup()
    Graphic.clearScreen()
    Graphic.drawTitle("FLUID MONITORING SYSTEM") --draw title bar
    --Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    timers = TThreads:newTimers({mainUpdate, 1})

    return timers
end --end startupFunction

return FluidMonitor