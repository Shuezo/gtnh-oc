--[[
Created 2021/7/7
Author: Sean Huezo
]]

--CONFIGURATION
local GIT = {}
GIT.NAME = "Shuezo"
GIT.REPO = "gtnh-oc"
GIT.BRANCH = "master"
GIT.REPO_URL = "https://api.github.com/repos/"..GIT.NAME.."/"..GIT.REPO.."/git/trees/"
GIT.FILE_URL = "https://raw.githubusercontent.com/"..GIT.NAME.."/"..GIT.REPO.."/"

local shell = require("shell")
local internet = require("internet")

--downloading the json libs if they do not exsist
shell.execute('wget -fq "https://raw.githubusercontent.com/rxi/json.lua/master/json.lua" "/lib/json.lua/"')

local json = require("json")

--Check if directory exists (No error is thrown)
local function exists(dir)
    local status = os.rename(dir, dir)
    return status ~= nil
end

local function getHTTPData(url) --gets HTTP data and returns it in a table
    local dat = ""
    local req, resp = pcall(internet.request, url)
    
    if req then
        local code, _, _ = resp.response()

        if code == 200 then
            local tmp = resp()
            while tmp ~= nil do -- Add response buffer to dat
                dat = dat..tmp
                tmp = resp()
            end

            return json.decode(dat) --Return decoded json data
        end
    end

    print("Could not connect to:\n"..url)
    return nil

end --end getHTTPdata


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
    local fullUrl = GIT.FILE_URL..GIT.BRANCH.."/"..path
    local dirPath = '/programs/'..GIT.REPO.."/"..dir
    
    if not exists(dirPath) then
        shell.execute('mkdir '..dirPath)
    end
    shell.execute('touch /programs/'..GIT.REPO.."/"..path)
    shell.execute('rm /programs/'..GIT.REPO.."/"..path)
    shell.execute('wget -fg '..fullUrl..' /programs/'..GIT.REPO.."/"..path)
end

--------Start of main process--------

local args, ops = shell.parse(...)
local new = false
local oldVer = {}
local ver = {}

if args[1] == "help" then
    print(  
            "usage:\n"..
            "    Update [param] [--b=branchName]\n"..
            "\n"..
            "params:\n"..
            "    [none]    - Updates or creates files\n"..
            "    new       - Clean Reinstall\n"..
            "\n"..
            "options:\n"..
            "    --b       - Branch (default: master)"
        )
    os.exit()

--Update normally, check previous SHAs to new
elseif args[1] ~= "new" then
    local oldFile = io.open('/programs/'..GIT.REPO..'/sha','r')
    if oldFile == nil then 
        oldVer = {} 
    else
        oldVer = json.decode(oldFile:read("*a"))
        oldFile:close()
    end
end

GIT.BRANCH  = ops.b or oldVer.branch or GIT.BRANCH
new         = args[1] == "new" or oldVer.branch ~= GIT.BRANCH

ver.branch  = GIT.BRANCH

--To reinstall a program or force new if installing different branch
if new then
    print("Clean Reinstall\n")
    if exists("/programs/"..GIT.REPO.."/") then
        shell.execute("rm -r /programs/"..GIT.REPO.."/")
    end
    shell.execute("mkdir /programs/"..GIT.REPO.."/")
end

--the data for the json api for the repository
local dat = getHTTPData(GIT.REPO_URL..GIT.BRANCH.."?recursive=1")
if dat == nil then
    os.exit(1)
end

--Download a file from each blob in the tree
local updates = 0

for _, file in pairs(dat.tree) do
    if file.type == "blob" then
        ver[file.path] = file.sha
        if new or ver[file.path] ~= oldVer[file.path] then
            if updates == 0 then
                print("Fetching "..ver.branch.." branch from "..GIT.NAME.."/"..GIT.REPO.."\n")
            end
            updates = updates + 1
            downloadFile(file.path)
        end
    end
end

local file = io.open('/programs/'..GIT.REPO..'/sha','w')
file:write(json.encode(ver))
file:close()

print("\nUpdated "..updates.." file(s).")