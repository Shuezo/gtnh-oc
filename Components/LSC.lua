--[[
Date: 2021/07/11 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local component = require("component")
local math      = require("math")
local Functions = require("Util\\Functions")
local GtMachine = require("Components\\GtMachine")

-------------------------------------------------------------------------
local LSC       = GtMachine:new(LSC_A)
-------------------------------------------------------------------------
LSC.data      = {
                isOn        = nil,
                input       = 0,
                output      = 0,
                charge      = 0,
                Pcharge     = 0,
                capacity    = 0,
                ref         = {0,0},   -- 1st is current, 2nd is also current (unless changed)
                time        = "",
                problems    = nil,
                }

function LSC.updateData()
    LSC.data.isOn           = LSC.isMachineActive()
    LSC.data.charge         = LSC.getEUStored()
    LSC.data.capacity       = LSC.getEUMaxStored()
    LSC.data.input          = LSC.getEUInputAverage()
    LSC.data.output         = LSC.getEUOutputAverage()
    LSC.data.Pcharge        = LSC.data.charge / LSC.data.capacity
    LSC.data.problems       = LSC:hasProblems()
end --end updateData

function LSC.calcData() --manipulates battery data from battery buffer
    local tmpData = LSC.data
    
    if tmpData.ref[1] ~= tmpData.ref[2] then
        tmpData.ref[2] = tmpData.ref[1]
        tmpData.charge = tmpData.ref[1]
    else
        tmpData.charge = tmpData.charge + (tmpData.input - tmpData.output) * 10 -- updates once every 0.5 seconds = 10 ticks
    end

    local ref = LSC.data.ref[1]
    LSC.data = tmpData
    LSC.data.ref[2] = ref -- ref[1] saved to ref[2]

    LSC.timeRemaining()
end --end CalcData

function LSC.timeRemaining() -- calculates time remaining for battery to fill/empty
    local t = 0 --initialized time
    local m = 0 --calculated minutes
    local s = 0 --caluclated seconds
    local h = 0 --calculated hours
    local u = LSC.data.input - LSC.data.output --energy usage

        if u == 0 then
        t = "No load                          "
    elseif u > 0 and LSC.data.Pcharge > 0.999 then
        t = "Full                             "
    elseif u < 0 then
        t = math.abs(LSC.data.charge / u ) / 20 --time=(currentCharge/Usage)*coversion from ticks to seconds
        s = t % 60
        m = (t % 3600) / 60
        h = t / 3600
        t = string.format("%.0fh %.0fm %.0fs to empty   ", h, m, s)
    elseif u > 0 then
        t = (LSC.data.capacity - LSC.data.charge) / u / 20 --time=(maxCharge-currentCharge/Usage)*conversion from ticks to seconds
        s = t % 60
        m = (t % 3600) / 60
        h = t / 3600
        t = string.format("%.0fh %.0fm %.0fs to full    ", h, m, s)
    else t = "Error"
    end

    LSC.data.time = t
    
end --end timeRemaining

return LSC