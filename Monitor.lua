--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 2.0
Usage: To be used in conjunction with Power.lua and Graphic.lua and Cleanroom.lua
]]--
package.loaded.Power = nil  --Free memory
package.loaded.Monitor = nil
package.loaded.Functions = nil
package.loaded.Graphic = nil
package.loaded.GtMachine = nil

------------Initilized Values------------
local event = require("event")
local keyboard = require("keyboard")
local thread = require("thread")
local component = require("component")
local Functions = require("Util\\Functions")
local Power = require("Components\\Power")
local Graphic = require("Components\\Graphic")
local computer = require("computer")

local gpu = component.gpu

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
    Graphic.updateCleanroomStatus(4, 3)
    Graphic.updateEBFStatus(4, 7)
    --Graphic.updateOvenStatus(ovenA, "A", 17, 3)
    --Graphic.updateOvenStatus(ovenB, "B", 17, 7)
    --Graphic.updateOvenStatus(ovenC, "C", 17, 11)
end --end MainUpdate

local function slowUpdate()
    Power.updateBatData()
    fuel = Power.checkFuelRem()
end --end slowUpdate

local function updateData()
    Power.calcBatData()
end --end updateData

local function controlPower()
    Power.reactorPower()
end

local function updateBars()
    bat = Power.checkBatteryLevel()
    Graphic.updatePowerData()
    Graphic.updatePowerBar(bat, 3, H-1, W-5, COLOR.green, COLOR.red) --draw powerbar
    Graphic.updateReactorBar(fuel, "Fuel", W-2, 5, H-8, COLOR.blue, COLOR.purple)
end --end updateBars

---------Timer Functions---------

local function stopTimers(tbl)
    for key, timer in pairs(tbl) do
        event.cancel(timer)
    end
end

local function startTimers()
    timers[slowUpdate]      = event.timer(8,    resume(threads[slowUpdate]),    math.huge)
    timers[mainUpdate]      = event.timer(2,    resume(threads[mainUpdate]),    math.huge)
    timers[updateData]      = event.timer(0.5,  resume(threads[updateData]),    math.huge)
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
                  slowUpdate,
                  updateData,
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

Power.reactorOff()
Functions.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil

os.exit()
