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

local timer1
local timer5
local keyListener
local done = false

------------Variables------------

local title = "MONITORING SYSTEM"

----------Functions----------

local function setKey(e)
    if keyboard.isKeyDown(keyboard.keys.x) then
        done = true
    end
end

local function mainUpdate(e)
    Power.reactorPower()
    Graphic.updateData()
end

local function quickUpdate(e)
    Graphic.updatePowerBar(2, 24, 76)
end

------------Main------------

--setup start screen
Graphic.setupResolution()
Graphic.clearScreen()
Graphic.drawTitle(title)
Graphic.drawBox()
Graphic.drawLabel(10, 3)

--start timers/listeners
timer1 = event.timer(1, quickUpdate, math.huge)
timer5 = event.timer(5, mainUpdate, math.huge)
event.listen("key_down", setKey)

--loop until key = x
while not done do
    os.sleep(0.1)
end

-----Exit-----
event.ignore("key_down", mainUpdate)
event.cancel(timer1)
event.cancel(timer5)

Power.reactorOff()
Graphic.clearScreen()