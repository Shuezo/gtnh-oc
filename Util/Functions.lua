--[[
Date: 2021/06/05 
Author: A. Jones & S. Huezo
Version: 1.0
Usage: To be used in conjunction with Monitor.lua
]]--

local Functions = {}

function Functions.average(t)
	local sum = 0
	for _,v in pairs(t) do -- Get the sum of all numbers in t
		sum = sum + v
	end
	return sum / #t
end

function Functions.centerText(x, text)
	local xLeft = math.ceil(x - string.len(text)/2)
	return xLeft
end --end centerText

function Functions.getPercent(val)
    return string.format("%.2f%%", val * 100)
end


return Functions