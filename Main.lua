--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 3.0
Usage: Main Runtime. To be used in conjunction with Components, Pages, and Utils.
]]--
package.loaded["Pages\\MachineMonitor"] = nil          --Free memory
package.loaded["Util\\Functions"]       = nil
package.loaded["Util\\Graphic"]         = nil
package.loaded["Components\\GtMachine"] = nil
package.loaded["Components\\Reactor"]   = nil
package.loaded["Components\\LSC"]       = nil
package.loaded["Components\\Turbine"]   = nil

------------General Libraries------------
local event     = require("event")
local keyboard  = require("keyboard")
local thread    = require("thread")
local component = require("component")
local computer  = require("computer")
local gpu       = component.gpu
------------Util Libraries------------
local Functions = require("Util\\Functions")
local Graphic   = require("Util\\Graphic")
------------Component Libraries------------
local LSC       = require("Components\\LSC")
local Reactor   = require("Components\\Reactor")
local Turbine   = require("Components\\Turbine")
local GtMachine = require("Components\\GtMachine")
------------Page Libraries------------
local MachineMonitor = require("Pages\\MachineMonitor")
------------Initilized Values------------
local Cleanroom = GtMachine:new("49e22d69-9915-43af-95e4-12385c4d6867")
local EBF       = GtMachine:new("c3440dd2-ba1e-4ea9-abfd-7a63e85d3ad2")
local TFFT      = GtMachine:new("80e4e927-0901-465c-aafd-122c2373fb19")
local threads   = {}
local timers    = {}
------------Variables---------------
local title = "MONITORING SYSTEM"
local quickBoot = false --setting this value to true disables splashscreen and gpu buffer

---------Update Functions---------

local function dataUpdate()
    Graphic.updatePowerData()
    
    LSC.updateData()
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


----------interrupt threads----------

threads["touch"] = thread.create(function ()
    local id, x, y
    while true do --loop until x is touched
        id, _, x, y = event.pullMultiple("touch", "interrupted")
        if id == "interrupted" then
            break
        elseif id == "touch" then       --exit button
            if x == W and y == 1 then
                break
            end
        end
    end
end)

-- end main function. Wait until user exits in touch thread
thread.waitForAny({threads["touch"]})

-----Exit-----

Functions.stopTimers(timers)
Functions.killThreads(threads)

Reactor.off()
Functions.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil

os.exit()