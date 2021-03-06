--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 3.0
Usage: To be used in conjunction with Monitor.lua and everything in components folder.
]]--
------------Variables------------
local Graphic = {}

local component = require("component")
local term      = require("term")
local string    = require("string")
local gpu       = component.gpu

local Functions = require("Util\\Functions")
local GtMachine = require("Components\\GtMachine")
local Reactor   = require("Components\\Reactor")
local LSC       = require("Components\\LSC")

------------Generic Functions------------

function Graphic.SplashScreen(textA, textB) --creates splashscreen
    Graphic.drawBox(COLOR.darkGrey, 1, 1, W, H)
    Graphic.drawExit(W, 1)
    Graphic.drawFrame(COLOR.lightGrey, COLOR.darkGrey, W/2-10, H/2-3, W/2+10, H/2+2)
    gpu.setForeground(COLOR.green)
    gpu.setBackground(COLOR.darkGrey)
    gpu.set(Functions.centerText(W/2, textA),H/2-1, textA)
    gpu.set(Functions.centerText(W/2, textB),H/2, textB)
    gpu.setForeground(COLOR.white)
    gpu.setBackground(COLOR.black)
end --end SplashScreen

function Graphic.drawFrame(clr, fill, x1, y1, x2, y2)
    local barWidth  = math.abs(x2 - x1) + 1
    local height = math.abs(y2 - y1) + 1
    local bg = gpu.getBackground()

    gpu.setBackground(clr)
    gpu.fill(x1, y1, barWidth, height, " ")
    gpu.setBackground(fill)

    if barWidth > math.abs(2) or height > math.abs(2) then
        gpu.fill(x1+1, y1+1, barWidth-2, height-2, " ")
    end
    gpu.setBackground(bg)
end --end drawFrame

function Graphic.drawBox(clr, x1, y1, x2, y2)
    local barWidth = math.abs(x2 - x1) + 1
    local height = math.abs(y2 - y1) + 1

    gpu.setBackground(clr)
    gpu.fill(x1, y1, barWidth, height, " ")

    gpu.setBackground(COLOR.black)
end --end drawBox

function Graphic.drawTitle(text)
    gpu.setBackground(COLOR.darkGrey)
    gpu.setForeground(COLOR.darkAqua)
    gpu.fill(1,1,W,1," ")
    gpu.set(Functions.centerText(W/2, text),1,text)
    gpu.setBackground(COLOR.black)
    gpu.setForeground(COLOR.white)
end --end drawTitle

function Graphic.drawExit(x,y)
    local bg = gpu.setBackground(COLOR.red)
    local fg = gpu.setForeground(COLOR.white)

    gpu.fill(x,y,1,1,"X")

    gpu.setBackground(bg)
    gpu.setForeground(fg)
end --end drawExit

function Graphic.drawStatusTile(lineOne, lineTwo, machine, x, y)
    Graphic.drawBox(COLOR.darkGrey, x, y, x+10, y+2)
    gpu.setBackground(COLOR.darkGrey)
    gpu.setForeground(COLOR.darkAqua)
    gpu.set(Functions.centerText(x+5, lineOne), y, lineOne)
    gpu.setForeground(COLOR.white)
    gpu.set(Functions.centerText(x+5, lineTwo), y+1, lineTwo)
    if machine.problems == nil then
        gpu.setForeground(COLOR.red)
        gpu.set(x,y+2,"   Null.   ")
    elseif not machine.problems and machine.isOn then
        gpu.setForeground(COLOR.green)
        gpu.set(x,y+2,"    OK.    ")
    elseif not machine.problems and not machine.isOn then
        gpu.setForeground(COLOR.red)
        gpu.set(x,y+2," Inactive! ")
    else
        gpu.setForeground(COLOR.red)
        gpu.set(x,y+2," Problems! ")
    end
    gpu.setForeground(COLOR.white)
    gpu.setBackground(COLOR.black)
end --end drawStatusTile

------------Reactor Functions------------

function Graphic.updatePowerData()
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

function Graphic.updatePowerBar(level, x, y, barWidth, fillColor, emptyColor) --Value to calculate bar fill and set label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
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

function Graphic.updateReactorBar(level, label, x, y, barHeight, fillColor, emptyColor) --Value to calculate bar fill, label, Hor Bar Position, Vertical Bar Position, Width of bar, colors
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

return Graphic