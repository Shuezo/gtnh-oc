local component = require("component")
local file = io.open('components','w')
local cl = component.list()

for k,v in pairs(cl) do
	file:write(k .. '  ' .. "\n")
end

file:close()
print("All done, Onii-Chan!")