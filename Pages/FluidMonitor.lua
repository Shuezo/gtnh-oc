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

----------------Main----------------

local function splitTable()
    local fluidName = {}
    local fluidAmount = {}
    
    for k,v in ipairs(dat) do
        if k>1 and k<=26 then
            s, e = string.find(':')
            table.insert(fluidName, string.sub(5,s) )
        end
    end

    for k,v in ipairs(dat) do
        if k>1 and k<=26 then
            table.insert(fluidAmount, string.sub(string.find(':'), string.find('L') ) )
        end
    end

end

local function mainUpdate()
    dat = TFFT.getSensorInformation()
    splitTable()
    for i,v in ipairs(fluidName) do
        if i==4 then
            gpu.set(1, 25, v)
        elseif i>1 and i<=13 and i~=4 then
            gpu.set(1,i,v)
        elseif i>13 and i<=26 then
            gpu.set(20,i-13,v)
        end
    end
end

--[[
local function mainUpdate()
    for i,v in ipairs(dat) do
        if i==4 then
            gpu.set(1, 25, v)
        elseif i>1 and i<=13 and i~=4 then
            gpu.set(1,i,v)
        elseif i>13 and i<=26 then
            gpu.set(20,i-13,v)
        end
    end
end
]]--

function FluidMonitor.startup()
    Graphic.clearScreen()
    Graphic.drawTitle("FLUID MONITORING SYSTEM") --draw title bar
    --Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    timers = TThreads:newTimers({mainUpdate, 1})

    return timers
end --end startupFunction

return FluidMonitor