--[[
Created 2021/7/7
Author: Sean Huezo
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
shell.execute('wget -fq "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua" "/lib/json.lua/"')

local json = require("json")

--Check if directory exists (No error is thrown)
local function exists(dir)
    local status = os.rename(dir, dir)
    if status == nil then
        return false
    else
        return true
    end
end

--gets HTTP data and returns it in a table
local function getHTTPData(url)
    local dat = ""
    local req, resp = pcall(internet.request, url)

    if(req) then
        local tmp = resp()
        while tmp ~= nil do -- Add response buffer to dat
            dat = dat..tmp
            tmp = resp()
        end
        return json.decode(dat) --Return decoded json data
    else
        print("Could not connect to "..url)
        return nil
    end
end

--[[
Split up directory and file from the filepath

dir: Directory in the format 'dir1/dir2/dir3/...'
file: Filename only
]]
local function splitFile(inputstr)
    local t = {}
    local dir  = ""

    for str in string.gmatch(inputstr, "([^/]+)") do --Delimit '/' 
        table.insert(t, str)
    end
    
    --Create string representing the directory
    for _, str in pairs(t) do
        if str ~= t[#t] then
            dir = dir..str.."/"
        end
    end
    
    local file = t[#t]
    return dir, file
end

--Download a file from a github api path and save it to '/programs/repo/'
local function downloadFile(path)
    local dir, file = splitFile(path)
    local fullUrl = GIT.FILE_URL.."/"..path
    local dirPath = '/programs/'..GIT.REPO.."/"..dir
    
    if not exists(dirPath) then
        shell.execute('mkdir '..dirPath)
    end
    shell.execute('touch /programs/'..GIT.REPO.."/"..path)
    shell.execute('rm /programs/'..GIT.REPO.."/"..path)
    shell.execute('wget -fg '..fullUrl..' /programs/'..GIT.REPO.."/"..path)
end


--the data for the json api for the repository
local dat = getHTTPData(GIT.REPO_URL.."?recursive=1")

local args, _ = shell.parse(...)
local new = false
local oldVer = {}

--To reinstall a program
if args[1] == "new" then
    new = true
    if exists("/programs/"..GIT.REPO.."/") then
        shell.execute("rm -r /programs/"..GIT.REPO.."/")
    end
    shell.execute("mkdir /programs/"..GIT.REPO.."/")
elseif args[1] == "help" then
    print("usage:\n\tUpdate [param]\nparams:\n\t[none]\t- Updates or creates files\n\tnew\t- Clean Reinstall")
    os.exit()
else
    local oldFile = io.open('sha')
    if oldFile == nil then 
        oldVer = {} 
    else
        oldVer = json.decode(oldFile:read("*a"))
        oldFile:close()
    end
end

--Download a file from each blob in the tree
local ver = {}
local updates = 0

for _, file in pairs(dat.tree) do
    if file.type == "blob" then
        ver[file.path] = file.sha
        if new or ver[file.path] ~= oldVer[file.path] then
            updates = updates + 1
            downloadFile(file.path)
        end
    end
end

local file = io.open('sha','w')
file:write(json.encode(ver))
file:close()

print("\nUpdated "..updates.." file(s).")
