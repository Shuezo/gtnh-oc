--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 3.0
Usage: Storage of generic gpu functions and drawing generic shapes.
]]--
local Graphic = {}
------------General Libraries------------
local component = require("component")
local term      = require("term")
local string    = require("string")
local gpu       = component.gpu
------------Util Libraries------------
local Functions = require("Util\\Functions")
------------Compenent Libraries------------
local GtMachine = require("Components\\GtMachine")
local Reactor   = require("Components\\Reactor")
local LSC       = require("Components\\LSC")

------------Administrative Functions------------
function Graphic.clearScreen() --clears the screen
    gpu.setBackground(COLOR.black)
    gpu.fill(1, 1, W, H, " ")
end --end clearScreen

function Graphic.setupResolution()
    --Use the resolution to help position all of the UI elements
    --Also sets the resolution to the maximum that is possible
    local maxW, maxH = gpu.maxResolution()
    if (W ~= maxW) and (H ~= maxH) then
        gpu.setResolution(maxW, maxH)
        local x, y = gpu.getResolution()
        W, H = x, y
        return true
    elseif (W == maxW and H == maxH) then
        local x, y = gpu.getResolution()
        W, H = x, y
        return true
    else
        return false
    end
end --end setupResolution
--------------------------------------------------
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

function Graphic.drawArrow(x, y, left)
    local bg = gpu.setBackground(COLOR.grey)
    local fg = gpu.setForeground(COLOR.white)
    if left == true then
        gpu.fill(x,y,2,1,"<")
    else
        gpu.fill(x,y,2,1,">")
    end

    gpu.setBackground(bg)
    gpu.setForeground(fg)
end --end drawArrow

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

return Graphic