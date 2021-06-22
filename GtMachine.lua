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
local Functions = require("Functions")

function GtMachine:new(addr)
    self.__index = self
    return setmetatable({controller = component.proxy(addr)}, self)
end

function GtMachine:status()
    return self.controller.isMachineActive()
end --end check if machine is on

function GtMachine:getProblems()
    return string.sub(self.controller.getSensorInformation()[5], 14, 14)
end --end getProblems (EBF controller)

function GtMachine:craftingStatus()
    return string.format( self.controller.getWorkProgress() / 20 .. "s / " .. self.controller.getWorkMaxProgress() / 20 .. "s")
end --end craftingStatus (of EBF controller)

--[[
    GtMachine:sensorInfo(args)
    args: {line, sensorTag (optional)}, ...
]]--
function GtMachine:sensorInfo(...)
    local tbl = {}
    local dat = self.controller.getSensorInformation()
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