--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 0.1
Usage: To be used in conjunction with Power.lua and Graphic.lua and Cleanroom.lua
]]--
package.loaded.Power = nil  --Free memory
package.loaded.Monitor = nil
package.loaded.Graphic = nil
package.loaded.Cleanroom = nil

------------Initilized Values------------
local event = require("event")
local keyboard = require("keyboard")
local thread = require("thread")
local component = require("component")
local Power = require("Power")
local Graphic = require("Graphic")

local mainThread
local quickThread
local exitThread

local timer1
local timer5
local running = true

------------Variables------------

local title = "MONITORING SYSTEM"

----------Functions----------

local function mainUpdate(e)
    if mainThread:status() == "suspended" then
        mainThread:resume()
    end
end

local function quickUpdate(e)
    if quickThread:status() == "suspended" then
        quickThread:resume()
    end
end

------------Main------------

--setup screen
Graphic.setupResolution()
Graphic.clearScreen()
Graphic.drawTitle(title)
Graphic.drawBox(COLOR.darkGrey,1,H-3,W,H)
Graphic.drawPowerLabel(10, 3)
Graphic.drawExit(W, 1)

--start timers/listeners
timer1 = event.timer(10, quickUpdate, math.huge)
timer5 = event.timer(5, mainUpdate, math.huge)

----------------Threads----------------

mainThread = thread.create(function ()
    while true do
        Power.reactorPower()
        Graphic.updatePowerData(30, 3)
        Graphic.updateCleanroomStatus(10, 9)
        thread.current():suspend()
    end
end)
 
quickThread = thread.create(function ()
    while true do
        Graphic.updatePowerBar(3, 24, 76)
        thread.current():suspend()
    end
end)


local x, y
while true do --loop until x is touched
    _, _, x, y = event.pull("touch")
    if x == W and y == 1 then
        break
    end
end

-----Exit-----
event.cancel(timer1)
event.cancel(timer5)

quickThread:kill()
mainThread:kill()

Power.reactorOff()
Graphic.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil