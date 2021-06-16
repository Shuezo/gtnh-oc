--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 0.1
Usage: To be used in conjunction with Power.lua and Graphic.lua
]]--
package.loaded.Power = nil  --Free memory
package.loaded.Monitor = nil
package.loaded.Graphic = nil

------------Initilized Values------------
local component = require("component")
local Power = require("Power")
local Graphic = require("Graphic")
local event = require("event")
local keyboard = require("keyboard")
local thread = require("thread")

local mainThread
local quickThread
local exitThread

local timer1
local timer5
local running = true

------------Variables------------

local title = "MONITORING SYSTEM"
local exitBtn = {x = W, 
                 y = 1}

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

--setup start screen
Graphic.setupResolution()
Graphic.clearScreen()
Graphic.drawTitle(title)
Graphic.drawBox(COLOR.darkGrey,1,H-3,W,H)
Graphic.drawLabel(10, 3)
Graphic.drawExit(exitBtn.x, exitBtn.y)

--start timers/listeners
timer1 = event.timer(10, quickUpdate, math.huge)
timer5 = event.timer(5, mainUpdate, math.huge)

----------------Threads----------------

mainThread = thread.create(function ()
    while true do
        Power.reactorPower()
        Graphic.updateData()
        thread.current():suspend()
    end
end)
 
quickThread = thread.create(function ()
    while true do
        Graphic.updatePowerBar(2, 24, 76)
        thread.current():suspend()
    end
end)


local x, y
while true do --loop until x is touched
    _, _, x, y = event.pull("touch")
    if x == exitBtn.x and y == exitBtn.y then
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

