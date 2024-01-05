local version = "0.0.1"

local repo = "http://raw.githubusercontent.com/Gematogesha/scada/main/"

local manifest = "install.json"

local function println(message) print(tostring(message)) end
local function print(message) term.write(tostring(message)) end

local function color(color) term.setTextColor(color) end
local function bg(color) term.setBackgroundColor(color) end 

local function cursor(x, y) term.setCursorPos(x, y) end

local opts = { ... }
local mode, app

local function get_opt(opt, options)
    for _, v in pairs(options) do 
        if opt == v then 
            return v 
        end 
    end
    return nil
end

local function error(text)
    color(colors.red)
    println(text)
    color(colors.white)
end

local function any_key() os.pullEvent("key_up") end

local function ask_y_n(question, default)
    print(question)
    if default == true then print(" (Y/n)? ") else print(" (y/N)? ") end
    local response = read();any_key()
    if response == "" then return default
    elseif response == "Y" or response == "y" then return true
    elseif response == "N" or response == "n" then return false
    else return nil end
end

local function download()
    local fileManifest, err = http.get(repo .. manifest)

    if fileManifest == nil then
        error(" HTTP Error " .. err)
        error(" Manifest download failed.")
    else
        local_ok, local_manifest = pcall(function () return textutils.unserializeJSON(fileManifest.readAll()) end)

        color(colors.blue)
        println(" Start downloading...")
        println(" ")
        color(colors.lightGray)
    
        for _, file in pairs(local_manifest.files[app]) do 
            color(colors.lightGray)
            local dl, err = http.get(repo .. file)
    
            if dl == nil then
                error(" HTTP Error " .. err)
                error(" Installer download failed.")
            else
                color(colors.lightGray)
                println(" Downloading " .. file:match("[^/]*.lua$"))
            end
        end
    end
end

local startInstall = function()
    color(colors.white)
    println(" Chosen: " .. string.upper( app ) .. " " .. mode )
    color(colors.lightGray)
    println(" -----------------------------------")
    os.setComputerLabel(mode)
    download()
    println(" ")
    color(colors.green)
    println(" Done!")
end

local startUninstall = function()
    local ask = ask_y_n(" Are you sure you want to delete " .. app, false)
    if ask then
        fs.delete(app)
        println(" ")
        color(colors.green)
        println(" Done!")
    else
        println(" ")
        color(colors.red)
        println(" Canceled")
    end

end

local checkStart = function()
    local fileManifest, err = http.get(repo .. manifest)

    if fileManifest == nil then
        error(" HTTP Error " .. err)
        error(" Manifest download failed.")
    else
        local_ok, local_manifest = pcall(function () return textutils.unserializeJSON(fileManifest.readAll()) end)
    
        for _, ver in pairs(local_manifest.versions) do 
            color(colors.lightGray)
            println(ver)
        end
    end
end


color(colors.lightGray)
println(" -----------------------------------")
color(colors.white)
println(" SCADA Minecfaft Mekanism " .. version)
color(colors.lightGray)
println(" -----------------------------------")

if #opts == 0 or opts[1] == "help" then
    color(colors.white)
    println(" select the computer operating mode")
    color(colors.lightGray)
    println(" -----------------------------------")
    color(colors.white)
    println(" use: ms <mode> <app>")
    color(colors.lightGray)
    println(" ")
    println(" <mode>")
    println(" install     - fresh install")
    println(" check       - check latest versions available")
    println(" update      - update files")
    color(colors.yellow)
    println("             - skip <app> for update ms.lua")
    color(colors.lightGray)
    println(" uninstall   - delete files")
    println(" ")
    println(" <app>")
    println(" plc         - PLC firmware")
    println(" hmi         - HMI firmware")
    return
else 
    mode = get_opt(opts[1], { "install", "uninstall", "update", "check" })
    if mode == nil then
        error(" Unrecognized mode.")
        return
    end

    app = get_opt(opts[2], { "plc", "hmi" })
    if app == nil and mode ~= "update" then
        error(" Unrecognized application.")
        return
    end
end

if mode == "install" and (fs.isDir("plc") or fs.isDir("hmi")) then
    error(" There is already an active mode")
elseif mode == "install" and not fs.isDir("plc") and not fs.isDir("hmi") then
    startInstall()
end

if mode == "uninstall" and fs.isDir(app) then
    startUninstall()
elseif mode == "uninstall" and not fs.isDir(app) then
    error(" Folder does not exist")
end

if mode == "update" and app ~= nil then
    startUpdate()
elseif mode == "update" and app == nil then
    startUpdateMs()
end

if mode == "check" and (app == nil or app ~= nil) then
    checkStart()
end

