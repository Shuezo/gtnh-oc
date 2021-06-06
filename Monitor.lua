--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 0.1
Usage: To be used in conjunction with Power.lua and GUI.lua
]]--
------------Variables------------
local component = require("component")
local Power = require("Power")
local GUI = require("GUI")
------------Functions------------

------------Main------------

print("Beginning Test")
print(Power.checkBatteryPercent())
print(GUI.test())
GUI.clearScreen()
GUI.setupResolution()
GUI.drawFrame()