--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 0.1
Usage: To be used in conjunction with Power.lua and Graphic.lua
]]--
package.loaded.Power = nil  --Free memory
package.loaded.Monitor = nil
package.loaded.Graphic = nil

------------Variables------------
local component = require("component")
local Power = require("Power")
local Graphic = require("Graphic")
local event = require("event")
local keyboard = require("keyboard")

local updateTimer
local keyListener
local powerTimer
local done = false

----------Functions----------

local function setKey(e)
    if keyboard.isKeyDown(keyboard.keys.x) then
        done = true
    end
end

local function tick(e)
    Graphic.drawData()
end

------------Main------------

--setup start screen
Graphic.setupResolution()
Graphic.clearScreen()
Graphic.drawLabel()
Graphic.drawData()

--start timers/listeners
updateTimer = event.timer(2, tick, math.huge)
powerTimer = event.timer(1, Power.reactorPower, math.huge)
event.listen("key_down", setKey)

--loop until key = x
while not done do
    os.sleep(0.1)
end

-----Exit-----
event.ignore("key_down", tick)
event.cancel(updateTimer)
event.cancel(powerTimer)

Power.reactorOff()
Graphic.clearScreen()