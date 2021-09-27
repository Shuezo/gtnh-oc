--[[
Date: 2021/07/20
Author: A. Jones & S. Huezo
Usage: Main Runtime Configuration File
]]--
local config = {
------------Variables------------
QUICKBOOT                   = false, -- setting this value to true disables splashscreen and gpu buffer
REACTOR_ON_THRESHOLD        = 0.80,  -- enter as a decimal value
REACTOR_OFF_THRESHOLD       = 0.99,  -- 
TURBINE_SAFETY_THRESHOLD    = 1,     -- 

------------Adapter Addresses------------
CLEANROOM_A         = "49e22d69-9915-43af-95e4-12385c4d6867",
EBF_A               = "c3440dd2-ba1e-4ea9-abfd-7a63e85d3ad2",
TFFT_A              = "80e4e927-0901-465c-aafd-122c2373fb19",
REACTOR_A           = "5ca155e9-ba43-4b65-8ba7-2b76d2e8b458",
REACTOR_B           = "fea9b540-29d6-4032-8b70-bafcf6f8b795",
REACTOR_INV         = "fa458337-2bdd-4161-94f1-c126ce8571ef",
LSC_A               = "1cc48397-5b2c-4b14-adba-d6df1b8111be",
LG_GAS_TURBINE_A    = "cc5ead40-5cd1-4df9-966a-671b41e20d38",
REDSTONE_REACTOR    = "ac6e4538-fea3-44e0-ac6d-9820e915bc7e",
REDSTONE_TURBINE    = "cd5f5cfe-81e6-4ef6-b3bd-955ccb08f48a",
OVEN_A              = "10c0ad96-bf69-4b10-8aa4-b8dd94252560",
OVEN_B              = "99a48a7e-4fad-49ee-99ba-fe09a1784b76",
DIST_TOWER_A        = "dfd76d80-2b20-4b6f-9aa1-c1452644f233",

}
return config