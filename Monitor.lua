--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.2
Usage: To be used in conjunction with Power.lua and Graphic.lua and Cleanroom.lua
]]--
package.loaded.Power = nil  --Free memory
package.loaded.Monitor = nil
package.loaded.Graphic = nil
package.loaded.Cleanroom = nil
package.loaded.EBF = nil

------------Initilized Values------------
local event = require("event")
local keyboard = require("keyboard")
local thread = require("thread")
local component = require("component")
local Power = require("Power")
local Graphic = require("Graphic")

local mainThread
local slowThread
local exitThread

local timer10
local timer5

local bat = 0
local fuel = 0

------------Variables------------

local title = "MONITORING SYSTEM"

----------Functions----------

local function mainUpdate(e)
    if mainThread:status() == "suspended" then
        mainThread:resume()
    end
end

local function slowUpdate(e)
    if slowThread:status() == "suspended" then
        slowThread:resume()
    end
end

local function mainFunction()
    Power.reactorPower()
    Graphic.updatePowerData(30, 3)
    Graphic.updateCleanroomStatus(10, 9)
    Graphic.updateEBFStatus(50, 9)
    Graphic.updatePowerBar(bat, 3, H-1, W-4, COLOR.green, COLOR.red)
    Graphic.updatePowerBar(fuel, 3, H-2, W-4, COLOR.blue, COLOR.purple)
end

local function slowFunction()
    bat = Power.checkBatteryLevel()
    fuel = Power.checkFuelRem()
end

------------Main------------

--setup screen
Graphic.setupResolution() --initial screen setup (hardware)
Graphic.clearScreen()
Graphic.SplashScreen("Initializing...", "Please Wait")
--Graphic.buffer
Graphic.clearScreen()
Graphic.drawTitle(title) --draw title bar
Graphic.drawBox(COLOR.darkGrey,1,H-3,W,H) --draw background for power bars
Graphic.drawPowerLabel(10, 3) -- draw plain text labels for status, usage, etc.
Graphic.drawExit(W, 1) --draw exit button
slowFunction()
mainFunction()
--Graphic.unbuffer

----------------Threads----------------

exitThread = thread.create(function ()
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

mainThread = thread.create(function ()
    while true do
        mainFunction()
        thread.current():suspend()
    end
end)

slowThread = thread.create(function ()
    while true do
        slowFunction()
        thread.current():suspend()
    end
end)

--start timers/listeners
timer10 = event.timer(10, slowUpdate, math.huge)
timer5 = event.timer(5, mainUpdate, math.huge)

thread.waitForAny({exitThread})

-----Exit-----

event.cancel(timer10)
event.cancel(timer5)

mainThread:kill()
slowThread:kill()
exitThread:kill()

Power.reactorOff()
Graphic.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil

os.exit()