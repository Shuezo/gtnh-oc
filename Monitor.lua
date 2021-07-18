--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 3.0
Usage: To be used in conjunction with Components and and everything in components folder.
]]--
package.loaded["Monitor"]               = nil          --Free memory
package.loaded["Util\\Functions"]       = nil
package.loaded["Components\\Graphic"]   = nil
package.loaded["Components\\GtMachine"] = nil
package.loaded["Components\\Reactor"]   = nil
package.loaded["Components\\LSC"]       = nil
package.loaded["Components\\Turbine"]   = nil

------------Includes------------
local event     = require("event")
local keyboard  = require("keyboard")
local thread    = require("thread")
local component = require("component")
local computer  = require("computer")
local gpu       = component.gpu

local Functions = require("Util\\Functions")
local GtMachine = require("Components\\GtMachine")
local Graphic   = require("Components\\Graphic")

------------Compenents------------
local LSC       = require("Components\\LSC")
local Reactor   = require("Components\\Reactor")
local Turbine   = require("Components\\Turbine")
local Cleanroom = GtMachine:new("49e22d69-9915-43af-95e4-12385c4d6867")
local EBF       = GtMachine:new("c1b4311d-993d-4d9b-8da0-71c97f8e003b")
local TFFT      = GtMachine:new("80e4e927-0901-465c-aafd-122c2373fb19")

------------Initilized Values------------
local threads   = {}
local timers    = {}

local bat, fuel

------------Variables------------

local title = "MONITORING SYSTEM"
local quickBoot = false --setting this value to true disables splashscreen and gpu buffer

----------Thread Functions----------

local function resume(thr)
    return function () 
        if thr:status() == "suspended" then
            thr:resume()
        end
    end
end

local function createThreads(...)
    for i,updateFunc in ipairs({...}) do
        threads[updateFunc] = thread.create(function ()
            local syc, e
            while true do
                syc, e = xpcall(updateFunc, debug.traceback)

                if syc == false then
                    local file = io.open('lastError.log','w')
                    file:write(e)
                    file:close()
                    computer.beep(500,10) --indicate a thread had an error
                end

                thread.current():suspend()
            end
        end)
    end
end

local function killThreads(tbl)
    for key, thr in pairs(tbl) do
        thr:kill()
    end
end

---------Update Functions---------

local function mainUpdate()
    Graphic.drawStatusTile('Cleanroom', 'Status:', Cleanroom.data, 4, 3)
    Graphic.drawStatusTile('Turbine', string.format('%d%%', Turbine.data.durability), Turbine.data, 17, 3)
    Graphic.drawStatusTile('LSC', 'Status:', LSC.data, 30, 3)
    Graphic.drawStatusTile('TFFT', 'Status:', TFFT.data, 43, 3)
    Graphic.drawStatusTile('EBF', EBF:craftingStatus(), EBF.data, 4, 7)
end --end MainUpdate

local function dataUpdate()
    LSC.updateData()
    Graphic.updatePowerData()
    Reactor.updateData()
    Turbine.updateData()
    Cleanroom:updateData()
    EBF:updateData()
    TFFT:updateData()
end --end dataUpdate

local function calcData()
    LSC.calcData()
end --end calcData

local function controlPower()
    Reactor.switch()
end

local function updateBars()
    Graphic.updatePowerBar(LSC.data.Pcharge, 3, H-1, W-5, COLOR.green, COLOR.red) --draw powerbar
    Graphic.updateReactorBar(Reactor.data.fuel, "Fuel", W-2, 5, H-8, COLOR.blue, COLOR.purple)
end --end updateBars

---------Timer Functions---------

local function stopTimers(tbl)
    for key, timer in pairs(tbl) do
        event.cancel(timer)
    end
end

local function startTimers()
    timers[dataUpdate]      = event.timer(8,    resume(threads[dataUpdate]),    math.huge)
    timers[mainUpdate]      = event.timer(2,    resume(threads[mainUpdate]),    math.huge)
    timers[calcData]        = event.timer(0.5,  resume(threads[calcData]),      math.huge)
    timers[updateBars]      = event.timer(0.5,  resume(threads[updateBars]),    math.huge)
    timers[controlPower]    = event.timer(2,    resume(threads[controlPower]),  math.huge)
end

----------interrupt threads----------

threads["touch"] = thread.create(function ()
    local id, x, y
    while true do --loop until x is touched
        id, _, x, y = event.pullMultiple("touch", "interrupted")
        if id == "interrupted" then
            break
        elseif id == "touch" then       --exit position
            if x == W and y == 1 then
                break
            end
        end
    end
end)

----------------Main----------------

local function startupFunction()
    Functions.clearScreen()
    Graphic.drawTitle(title) --draw title bar
    Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
    Graphic.drawExit(W, 1) --draw exit button
    createThreads(mainUpdate,
                  dataUpdate,
                  calcData,
                  updateBars,
                  controlPower)
end --end startupFunction

Functions.setupResolution() --initial screen setup (hardware)
Functions.clearScreen()

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

-- end main function. Wait until user exits in touch thread
thread.waitForAny({threads["touch"]})

-----Exit-----

stopTimers(timers)
killThreads(threads)

Reactor.off()
Functions.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil

os.exit()
