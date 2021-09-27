--[[
Date: 2021/06/22 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: Handles general parsing of the component API from gregtech machines
]]--
------------Variables------------
local GtMachine = {}
local machines = {}

local component = require("component")
local math      = require("math")
local string    = require("string")
local Functions = require("Util\\Functions")

function GtMachine:new(addr)
    local o = machines[addr] 

    if not o then --Check if machine object exists
        o = component.proxy(addr)
        o.data = {
                    isOn = nil,
                    output = 0,
                    problems = nil,
                }
                
        setmetatable(o, self)
        self.__index = self

        machines[addr] = o
    end

    return o
end

function GtMachine:updateData()
    self.data.isOn       = self.isMachineActive()
    self.data.output     = self.getEUOutputAverage()
    self.data.problems   = self:hasProblems()
end

function GtMachine:hasProblems()
    if string.sub( self.getSensorInformation()[5], 13, 14 ) == 'c0' then return false                       --Cleanroom, EBF
    elseif string.sub( self.getSensorInformation()[7], 13, 14 ) == 'c0' then return false                       --Pyrolyse Oven
    elseif self.getSensorInformation()[2] == '§aNo Maintenance issues§r' then return false                  --Turbine
    elseif self.getSensorInformation()[9] == 'Maintenance Status: §aWorking perfectly§r' then return false  --LSC
    elseif self.getSensorInformation()[31] == 'Maintenance Status: §aWorking perfectly§r' then return false --TFFT
    else return true
    end
end --end hasProblems

function GtMachine:craftingStatus()
    if self.getWorkMaxProgress() ~= 0.0 then return string.format(" %3.0fs/%3.0fs ", self.getWorkProgress() / 20, self.getWorkMaxProgress() / 20 )
    else return "" end
end --end craftingStatus

--[[
    GtMachine:sensorInfo(args)
    args: {line, sensorTag (optional)}, ...
]]--
function GtMachine:sensorInfo(...)
    local tbl = {}
    local dat = self.getSensorInformation()
    local tmp, sub

    for i,v in ipairs({...}) do
        if v[2] ~= nil then
            tmp = string.match(dat[v[1]],"§".. v[2] ..".-§r")
            sub = v[2]
        else
            sub = ""
            tmp = dat[v[1]]
        end
        tmp = string.gsub(tmp,"[§".. sub .."r,EUt/ ]","")

        tbl[i] = tonumber(tmp)
    end

    return table.unpack(tbl)
end

return GtMachine