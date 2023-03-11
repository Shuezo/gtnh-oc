--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 3.1
Usage: A general page, to be used in conjunction with Main.lua
]]--
local MachineMonitor = {}
local Config    = require("Config")
local timers   = {}
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
local Turbine   = require("Components\\Turbine")
local GtMachine = require("Components\\GtMachine")

------------Power Functions------------
function MachineMonitor.updatePowerData()
    local dataLSC      = LSC.data
    local net          = dataLSC.input - dataLSC.output

    gpu.set(34,H-5, string.format("Load: %.0f EU/t    ", dataLSC.output))
    if net > 0 then gpu.set(35,H-4,string.format("Net: +%.0f EU/t    ", net)) else gpu.set(35,H-4,string.format("Net: %.0f EU/t    ", net)) end

    gpu.setBackground(COLOR.darkGrey)
    --gpu.setForeground(COLOR.white)
    gpu.set(4,H-2,"Battery: " .. dataLSC.time)

    gpu.setBackground(COLOR.black)
end --end updateData

local function updatePowerBar(level, x, y, barWidth, fillColor, emptyColor) --Value to calculate bar fill and set label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
    level = level or 0
    local percent = Functions.getPercent(level)
    local textX = Functions.centerText((x + barWidth)/2, percent)
    local fillWidth = math.ceil(barWidth * level)
    local emptyWidth = barWidth - fillWidth

    if fillWidth > 0 then
        gpu.setBackground(fillColor)
        for pos=x,x+fillWidth do
            if pos>=textX and pos<textX+string.len(percent) then
                gpu.set(pos, y, string.sub(percent,1+pos-textX,1+pos-textX))
            else
                gpu.set(pos,y," ")
            end
        end
    end

    if emptyWidth > 0 then
        gpu.setBackground(emptyColor)
        for pos=x+fillWidth+1,x+barWidth do
            if pos>=textX and pos<textX + string.len(percent) then
                gpu.set(pos, y, string.sub(percent,pos-textX+1,pos-textX+1))
            else
                gpu.set(pos,y," ")
            end
        end
    end

    gpu.setBackground(COLOR.black)
end --end UpdatePowerBar


---------Update Functions---------
local function dataUpdate() --handles data refreshing for non-essential tasks on machine monitor screen. (to be disabled when screen is cached)
    --updateData
end --end dataUpdate

local function mainUpdate() --Draws tiles onscreen and handles refreshing
    Graphic.drawStatusTile('Test', 'Status:', nil, 4, 3)
end --end MainUpdate

local function updateBars()
    updatePowerBar(LSC.data.Pcharge, 3, H-1, W-5, COLOR.green, COLOR.red) --draw powerbar
end --end updateBars

----------------Main----------------
function MachineMonitor.startup()
    Graphic.clearScreen()
    Graphic.drawTitle("MACHINE MONITORING SYSTEM") --draw title bar
    Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    timers = TThreads:newTimers({dataUpdate, 4},
                                {mainUpdate, 1},
                                {updateBars, 0.5})
    return timers
end --end startup

return MachineMonitor
