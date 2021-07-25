--[[
TThreads.lua

Date: 2021/07/25 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: Set up objects containing timers that resume threads
]]--

local TThreads = {}
local Functions = require("Util\\Functions")


------------Thread/Timer Functions------------
local thread    = require("thread")
local event     = require("event")
local computer  = require("computer")

--Create a thread for use with a timer
local function createThread(updateFunc)
    local thr = thread.create(function ()
        local syc, e
        while true do
            syc, e = xpcall(updateFunc, debug.traceback)

            if syc == false then
                --Functions.errorLog(e) --doesn't work
                local file = io.open("lastError.log", 'w') -- open file with write privileges
                file:write(e) --write error
                file:close() --close file
                computer.beep(250,10) --indicate a thread had an error by making a sound
                thread.current():kill()
            end

            thread.current():suspend()
        end
    end)

    return thr
end

local function resume(thr)
    return function () 
        if thr:status() == "suspended" then
            thr:resume()
        end
    end
end

local function stopTimers(tbl)
    for key, timer in pairs(tbl) do
        event.cancel(timer)
    end
end

local function killThreads(tbl)
    for key, thr in pairs(tbl) do
        thr:kill()
    end
end

function TThreads:stop()
    stopTimers(self.timers)
    killThreads(self.threads)
end

--Creates timers with threads
--args: {updateFunc, Time}, ...
function TThreads:newTimers(...)
    local threads = {}
    local timers = {}

    for i,val in ipairs({...}) do
        local func = val[1]
        local interval = val[2]

        threads[func] = createThread(func)
        timers[func] = event.timer(interval, resume(threads[func]), math.huge)
    end

    local o = {
                threads = threads,
                timers = timers
              }

    setmetatable(o, self)
    self.__index = self

    return o
end

return TThreads