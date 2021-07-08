--[[
Modified 7/7/21 
by: Sean Huezo

Inspired by github code from rater193
]]

--CONFIGURATION
local GIT = {}
GIT.NAME = "Shuezo"
GIT.REPO = "gtnh-oc"
GIT.REPO_URL = "https://api.github.com/repos/"..GIT.NAME.."/"..GIT.REPO.."/git/trees/master"
GIT.FILE_URL = "https://raw.githubusercontent.com/"..GIT.NAME.."/"..GIT.REPO.."/master"

local shell = require("shell")
local internet = require("internet")

--downloading the json libs if they do not exsist
shell.execute('wget -fq "https://raw.githubusercontent.com/LuaDist/dkjson/master/dkjson.lua" "/lib/dkjson.lua/"')

local json = require("dkjson")

local function exists(dir)
    local ok, err, code = os.rename(dir, dir)
    if not ok then
        if code == 13 then
            -- permission denied, but it exists
            return true
        end
    end
    return ok, err
end

--gets HTTP data and returns it in a table
local function getHTTPData(url)
    local ret = ""
    local req, resp = pcall(internet.request, url)

    if(req) then
        ret = json.decode(resp())
    else
        print("Could not connect to "..url)
        return nil
    end
    
    return ret
end

local function splitFile(inputstr)
	if sep == nil then
			sep = "%s"
	end

    local t = {}
	local dir  = ""

	for str in string.gmatch(inputstr, "([^/]+)") do
            table.insert(t, str)
	end

    for _, str in pairs(t) do
        if str ~= t[#t] then
            dir = dir..str.."/"
        end
    end
    
    local file = t[#t]
	return dir, file
end

local function createFile(path)
    local dir, file = splitFile(path)
    local fullUrl = GIT.FILE_URL.."/"..path
    local dirPath = '/programs/'..GIT.REPO.."/"..dir
    
    if not exists(dirPath) then
        shell.execute('mkdir '..dirPath)
    end
    shell.execute('wget -fg '..fullUrl..' /programs/'..GIT.REPO.."/"..path)
end

--the data for the json api for the repository
local dat = getHTTPData(GIT.REPO_URL.."?recursive=1")

if exists("/programs/"..GIT.REPO.."/") then
    shell.execute("rm -r /programs/"..GIT.REPO.."/")
end

shell.execute("mkdir /programs/"..GIT.REPO.."/")

for _, file in pairs(dat.tree) do
    if file.type == "blob" then
        createFile(file.path)
    end
end