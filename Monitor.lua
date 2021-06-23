--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.2
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
local Functions = require("Functions")
local Power = require("Power")
local Graphic = require("Graphic")

local gpu = component.gpu

local threads = {}

local timer10
local timer2
local dataTimer
local barTimer

local locked = false

------------Variables------------

local title = "MONITORING SYSTEM"

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
            while true do
                updateFunc()
                thread.current():suspend()
            end
        end)
    end
end

threads["exit"] = thread.create(function ()
    local id, x, y
    while true do --loop until x is touched
        id, _, x, y = event.pullMultiple("touch", "interrupted")
        if id == "interrupted" then
            break
        elseif id == "touch" then
            if x == W and y == 1 then
                break
            end
        end
    end
end)

---------Main Functions---------

local function mainUpdate()
    Power.reactorPower()
    Graphic.updateCleanroomStatus(4, 3)
    Graphic.updateEBFStatus(4, 7)
end

local function slowUpdate()
    Power.updateBatData()
end

local function updateData()
    Power.calcBatData()
end

local function updateBars()
    local bat = Power.checkBatteryLevel()
    local fuel = Power.checkFuelRem()
    Graphic.updatePowerData()
    Graphic.updatePowerBar(bat, 3, H-1, W-5, COLOR.green, COLOR.red)
    --Graphic.updatePowerBar(fuel, 3, H-2, W-5, COLOR.blue, COLOR.purple)
end

------------Main------------

--setup screen
Graphic.setupResolution() --initial screen setup (hardware)
Graphic.clearScreen()
Graphic.SplashScreen("Initializing...", "Please Wait")

--buffer
local buf = gpu.allocateBuffer(W,H)
gpu.setActiveBuffer(buf)

Graphic.clearScreen()
Graphic.drawTitle(title) --draw title bar
Graphic.drawBox(COLOR.darkGrey,1,H-2,W,H) --draw background for power bars
Graphic.drawExit(W, 1) --draw exit button

createThreads(slowUpdate, 
              updateData, 
              mainUpdate,
              updateBars)

os.sleep(0.5)

--load buffer onto screen
gpu.bitblt(0, 1, 1, W, H, buf, 1, 1)
gpu.freeBuffer(buf)

--start timers/listeners
timer10     = event.timer(8,    resume(threads[slowUpdate]),    math.huge)
timer2      = event.timer(2,    resume(threads[mainUpdate]),    math.huge)
dataTimer   = event.timer(0.5,  resume(threads[updateData]),    math.huge)
barTimer    = event.timer(0.5,  resume(threads[updateBars]),    math.huge)

thread.waitForAny({exitThread})

-----Exit-----

event.cancel(timer10)
event.cancel(timer2)
event.cancel(dataTimer)
event.cancel(barTimer)



Power.reactorOff()
Graphic.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil

os.exit()