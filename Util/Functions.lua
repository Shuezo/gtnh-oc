--[[
Date: 2021/06/23 
Author: A. Jones & S. Huezo
Version: 2.0
Usage: Storage of generic functions and basic constants.
]]--
local Functions = {}

local computer  = require("computer")
local internet = require("internet")
local json = require("json")

------------Constants------------
COLOR = { blue      = 0x4286F4,
          darkAqua  = 0x3392FF,
          purple    = 0xB673d6,
          red       = 0xC14141,
          green     = 0x0DA841,
          black     = 0x000000,
          white     = 0xFFFFFF,
          grey      = 0x252525,
          lightGrey = 0xBBBBBB,
          darkGrey  = 0x262626 }

------------General Helper Functions------------
function Functions.average(t) --average a set of numbers
    local sum = 0
    for _,v in pairs(t) do -- Get the sum of all numbers in t
        sum = sum + v
    end
    return sum / #t
end --end average

function Functions.centerText(x, text) --center text at a point
    local xLeft = math.ceil(x - string.len(text)/2)
    return xLeft
end --end centerText

function Functions.getPercent(val, precision) --create a percent at a certain precision
    precision = precision or "0.2"
    return string.format("%".. precision .. "f%%", val * 100)
end --end getPercent

function Functions.getHTTPData(url) --gets HTTP data and returns it in a table
    local dat = ""
    local req, resp = pcall(internet.request, url)

    if(req) then
        local tmp = resp()
        while tmp ~= nil do -- Add response buffer to dat
            dat = dat..tmp
            tmp = resp()
        end
        return json.decode(dat) --Return decoded json data
    else
        print("Could not connect to "..url)
        return nil
    end
end --end getHTTPdata

------------Error Functions------------
function Functions.errorLog(error) --parses the current time from a web API, and writes a new file under the "Log" folder with the timestamp as the name
        local dat = Functions.getHTTPdata("http://worldtimeapi.org/timezone/America/New_York") --get current time
        local filename = "..Log\\" .. json.decode(dat).datetime .. ".txt" --filepath .. timestamp .. file extension
        local file = io.open(filename, 'w') -- open file with write privileges
        file:write(error) --write error
        file:close() --close file
        computer.beep(250,10) --indicate a thread had an error by making a sound
end --end errorlog

------------Thread/Timer Functions------------
local thread    = require("thread")
local event     = require("event")

--Create a thread for use with a timer
local function createThread(updateFunc)
    local thr = thread.create(function ()
        local syc, e
        while true do
            syc, e = xpcall(updateFunc, debug.traceback)

            if syc == false then
                Functions.errorLog(e)
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

function Functions.stopTimers(tbl)
    for key, timer in pairs(tbl) do
        event.cancel(timer)
    end
end

function Functions.killThreads(tbl)
    for key, thr in pairs(tbl) do
        thr:kill()
    end
end

--Creates timers with threads
--args: {updateFunc, Time}, ...
function Functions.addTimers(...)
    local threads = {}
    local timers = {}

    for i,val in ipairs({...}) do
        local func = val[1]
        local interval = val[2]

        threads[func] = createThread(func)
        timers[func] = event.timer(interval, resume(threads[func]), math.huge)
    end

    return timers, threads
end

return Functions