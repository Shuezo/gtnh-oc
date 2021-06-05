--2021 / 06 / 05
--Revision 0.1

--Initialize
local component = require("component")
local gpu = component.gpu--can
local w, h = gpu.getResolution()

--Set Component ID's
--local reactor = component.de831599-fabb-44a5-ac3c-4ac71a2f16f5
--local chest = component.fa458337-2bdd-4161-94f1-c126ce8571ef
--local bat = component.e4ecc183-dfe1-4fd0-a68f-56589d54902b

function clear () gpu.fill(1, 1, w, h, " ") end --clears the screen

function Fill (x) return x end