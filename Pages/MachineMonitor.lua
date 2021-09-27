--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 3.1
Usage: A general page, to be used in conjunction with Main.lua
]]--
local MachineMonitor = {}
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
local Cleanroom = GtMachine:new(Config.CLEANROOM_A)
local EBF       = GtMachine:new(Config.EBF_A)
local TFFT      = GtMachine:new(Config.TFFT_A)
local OVEN_1    = GtMachine:new(Config.OVEN_A)
local OVEN_2    = GtMachine:new(Config.OVEN_B)
local DISTOWER  = GtMachine:new(Config.DIST_TOWER_A)

local timers   = {}
local bat, fuel
local Oven_Group_Benzene = false

------------Reactor Functions------------
function MachineMonitor.updatePowerData()
    local dataLSC      = LSC.data
    local dataReactor  = Reactor.data
    local net          = dataLSC.input - dataLSC.output

    gpu.set(8,H-5, "Reactor is ")
    if dataReactor.isOn then
        gpu.setForeground(COLOR.green)
        gpu.set(19,H-5,"ON ")
        gpu.setForeground(COLOR.white)
        Graphic.drawBox(COLOR.green, 3, H-5, 6, H-4)
    elseif not dataReactor.isOn then
        gpu.setForeground(COLOR.red)
        gpu.set(19,H-5,"OFF")
        gpu.setForeground(COLOR.white)
        Graphic.drawBox(COLOR.red, 3, H-5, 6, H-4)
    end

    gpu.set(8,H-4, string.format("Output: %.0f EU/t    ", dataReactor.output))
    gpu.set(34,H-5, string.format("Load: %.0f EU/t    ", dataLSC.output))
    if net > 0 then gpu.set(35,H-4,string.format("Net: +%.0f EU/t    ", net)) else gpu.set(35,H-4,string.format("Net: %.0f EU/t    ", net)) end

    gpu.setBackground(COLOR.darkGrey)
    --gpu.setForeground(COLOR.white)
    gpu.set(4,H-2,"Battery: " .. dataLSC.time)

    gpu.setBackground(COLOR.black)
end --end updateData

local function updatePowerBar(level, x, y, barWidth, fillColor, emptyColor) --Value to calculate bar fill and set label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
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

local function updateReactorBar(level, label, x, y, barHeight, fillColor, emptyColor) --Value to calculate bar fill, label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
    local percent = Functions.getPercent(level, "3.0")
    local textPos = x-4, y-2
    local fillHeight = math.ceil(barHeight * level)
    local emptyHeight = barHeight - fillHeight

    gpu.setBackground(COLOR.darkGrey)
    gpu.fill(x,y-2,1,2," ") --fill vertically from the top of the bar up two cells
    gpu.set(x-12,y-2,string.format(" %s: %-5s", label, percent))

    if fillHeight > 0 then
        gpu.setBackground(fillColor)
        for pos=y+barHeight,y+barHeight-fillHeight,-1 do
            gpu.set(x,pos," ")
        end
    end

    if emptyHeight > 0 then
        gpu.setBackground(emptyColor)
        for pos=y+barHeight-fillHeight-1,y,-1 do
            gpu.set(x,pos," ")
        end
    end

    gpu.setBackground(COLOR.black)
end --end UpdateReactorBar

---------Update Functions---------
local function dataUpdate() --handles data refreshing for non-essential tasks on machine monitor screen. (to be disabled when screen is cached)
    MachineMonitor.updatePowerData()
    
    Cleanroom:updateData()
    EBF:updateData()
    TFFT:updateData()
    OVEN_1:updateData()
    OVEN_2:updateData()
    DISTOWER:updateData()
end --end dataUpdate

local function mainUpdate() --Draws tiles onscreen and handles refreshing
    Graphic.drawStatusTile('Cleanroom', 'Status:', Cleanroom.data, 4, 3)
    Graphic.drawStatusTile('Turbine', string.format('%d%%', Turbine.data.durability), Turbine.data, 17, 3)
    Graphic.drawStatusTile('LSC', 'Status:', LSC.data, 30, 3)
    Graphic.drawStatusTile('TFFT', 'Status:', TFFT.data, 43, 3)
    Graphic.drawStatusTile('EBF', EBF:craftingStatus(), EBF.data, 4, 7)
    Graphic.drawStatusTile('OVEN A', "Status:", OVEN_1.data, 17, 7)
    Graphic.drawStatusTile('OVEN B', "Status:", OVEN_2.data, 30, 7)
    Graphic.drawStatusTile('D-TOWER', "Status:", DISTOWER.data, 43, 7)
end --end MainUpdate

local function updateBars()
    updatePowerBar(LSC.data.Pcharge, 3, H-1, W-5, COLOR.green, COLOR.red) --draw powerbar
    updateReactorBar(Reactor.data.fuel, "Fuel", W-2, 5, H-8, COLOR.blue, COLOR.purple)
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
