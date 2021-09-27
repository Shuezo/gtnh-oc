--[[
Date: 2021/07/19
Author: A. Jones & S. Huezo
Version: 1.0
Usage: Main Runtime. To be used in conjunction with Components, Pages, and Utils.
]]--
package.loaded["Config.lua"]            = nil          --Free memory
package.loaded["Pages\\MachineMonitor"] = nil
package.loaded["Pages\\FluidMonitor"]   = nil
package.loaded["Util\\Functions"]       = nil
package.loaded["Util\\Graphic"]         = nil
package.loaded["Util\\TThreads"]        = nil
package.loaded["Components\\GtMachine"] = nil
package.loaded["Components\\Reactor"]   = nil
package.loaded["Components\\LSC"]       = nil
package.loaded["Components\\Turbine"]   = nil


local Config    = require("Config")
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
local TThreads  = require("Util\\TThreads")
------------Component Libraries------------
local LSC       = require("Components\\LSC")
local Reactor   = require("Components\\Reactor")
local Turbine   = require("Components\\Turbine")
local GtMachine = require("Components\\GtMachine")
------------Page Libraries------------
local Pages =   {
                  require("Pages\\MachineMonitor"), --1
                  require("Pages\\FluidMonitor")    --2
                }
------------Initilized Values------------
local Cleanroom = GtMachine:new("49e22d69-9915-43af-95e4-12385c4d6867")
local EBF       = GtMachine:new("c3440dd2-ba1e-4ea9-abfd-7a63e85d3ad2")
local TFFT      = GtMachine:new("80e4e927-0901-465c-aafd-122c2373fb19")

local timers    = {main = nil, page = nil}
---------Update Functions---------

local function dataUpdate() --core data refreshing, runs regardless of GUI status
    LSC.updateData()
    Reactor.updateData()
    Turbine.updateData()
end --end dataUpdate

local function calcData()
    LSC.calcData()
end --end calcData

local function controlPower()
    Reactor.switch()
    Turbine.switch()
end

----------------Setup----------------
local pageNumber = 1

Graphic.setupResolution()

if Config.QUICKBOOT == false then --provides override for buffer allocation and splashscreen
    Graphic.SplashScreen("Initializing...", "Please Wait")
    local buf = gpu.allocateBuffer(W,H)
    gpu.setActiveBuffer(buf)

    timers.main = TThreads:newTimers({dataUpdate,   4   },
                                     {calcData,     0.5 },
                                     {controlPower, 2   })
    
    timers.page = Pages[pageNumber].startup()
    os.sleep(0.25)
    thread.waitForAll(timers.page.threads)
    thread.waitForAll(timers.main.threads)
    
    gpu.bitblt(0, 1, 1, W, H, buf, 1, 1) --load buffer onto screen
    gpu.freeBuffer(buf)
else
    timers.page = Pages[pageNumber].startup()
end


--------------MAIN LOOP--------------
local id, x, y
while true do --loop until x is touched
    id, _, x, y = event.pullMultiple("touch", "interrupted")
    if id == "interrupted" then
        break
    elseif id == "touch" then       --exit button
        if x == W and y == 1 then
            break
        elseif x == W then
            timers.page:stop()
            if pageNumber+1 > #Pages  then
                pageNumber = 1
            else
                pageNumber = pageNumber + 1
            end
            timers.page = Pages[pageNumber].startup()

        elseif x == 1 then
            timers.page:stop()
            if pageNumber-1 == 0  then
                pageNumber = #Pages
            else
                pageNumber = pageNumber - 1
            end
            timers.page = Pages[pageNumber].startup()

        end
    end
end

timers.page:stop() -- Stop timers/threads of current page
timers.main:stop() -- Stop main timers
Reactor.off()
Graphic.clearScreen()

--clean up globals
W, H, COLOR = nil, nil, nil

os.exit()