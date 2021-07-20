--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: A general page, to be used in conjunction with Main.lua
]]--
local MachineMonitor = {}
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
local Cleanroom = GtMachine:new("49e22d69-9915-43af-95e4-12385c4d6867")
local EBF       = GtMachine:new("c3440dd2-ba1e-4ea9-abfd-7a63e85d3ad2")
local TFFT      = GtMachine:new("80e4e927-0901-465c-aafd-122c2373fb19")

local threads   = {}
local timers    = {}
local bat, fuel

------------Variables------------
local title = "MONITORING SYSTEM"
local quickBoot = false --setting this value to true disables splashscreen and gpu buffer

---------Update Functions---------
function MachineMonitor.mainUpdate()
    Graphic.drawStatusTile('Cleanroom', 'Status:', Cleanroom.data, 4, 3)
    Graphic.drawStatusTile('Turbine', string.format('%d%%', Turbine.data.durability), Turbine.data, 17, 3)
    Graphic.drawStatusTile('LSC', 'Status:', LSC.data, 30, 3)
    Graphic.drawStatusTile('TFFT', 'Status:', TFFT.data, 43, 3)
    Graphic.drawStatusTile('EBF', EBF:craftingStatus(), EBF.data, 4, 7)
end --end MainUpdate

function MachineMonitor.updateBars()
    Graphic.updatePowerBar(LSC.data.Pcharge, 3, H-1, W-5, COLOR.green, COLOR.red) --draw powerbar
    Graphic.updateReactorBar(Reactor.data.fuel, "Fuel", W-2, 5, H-8, COLOR.blue, COLOR.purple)
end --end updateBars

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

function MachineMonitor.updatePowerBar(level, x, y, barWidth, fillColor, emptyColor) --Value to calculate bar fill and set label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
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

function MachineMonitor.updateReactorBar(level, label, x, y, barHeight, fillColor, emptyColor) --Value to calculate bar fill, label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
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

----------------Main----------------
function MachineMonitor.startupFunction()
    Graphic.clearScreen()
    Graphic.drawTitle(title) --draw title bar
    Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    threads = Functions.createThreads(mainUpdate,
                                      updateBars)
end --end startupFunction

Graphic.setupResolution() --initial screen setup (hardware)
Graphic.clearScreen()

if quickBoot == false then --provides override for buffer allocation and splashscreen
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

return MachineMonitor
