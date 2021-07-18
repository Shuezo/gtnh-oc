--[[
Date: 2021/06/22 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--
------------Variables------------
local GtMachine = {}

local component = require("component")
local math      = require("math")
local string    = require("string")
local Functions = require("Util\\Functions")

function GtMachine:new(addr)
    self.__index = self
    self.data = {
                    isOn        = nil,
                    output      = 0,
                    problems    = false,
                }

    return setmetatable(component.proxy(addr) or {}, self)
end

function GtMachine:updateData()
    self.data.isOn       = self.isMachineActive()
    self.data.output     = self.getEUOutputAverage()
    self.data.problems   = self:hasProblems()
end

function GtMachine:hasProblems()
    if string.sub( self.getSensorInformation()[5], 11, 17 ) == '§c0§r' then return false
    elseif self.getSensorInformation()[2] == '§aNo Maintenance issues§r' then return false
    elseif self.getSensorInformation()[9] == 'Maintenance Status: §aWorking perfectly§r' then return false
    elseif self.getSensorInformation()[31] == 'Maintenance Status: §aWorking perfectly§r' then return false
    else return true
    end
end --end hasProblems

function GtMachine:craftingStatus()
    if self.getWorkMaxProgress() ~= 0.0 then return string.format(" %3.0fs/%3.0fs ", self.getWorkProgress() / 20, self.getWorkMaxProgress() / 20 )
    else return " Inactive. " end
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