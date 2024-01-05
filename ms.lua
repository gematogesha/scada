local version = "0.0.1"

local repo = "http://raw.githubusercontent.com/gematogesha/scada/main/"

local manifest = "manifest.json"

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
        fs.delete("local_manifest.json")
        _local_manifest = fs.open("local_manifest.json", "w")
        _local_manifest.write(textutils.serializeJSON(local_manifest))
        _local_manifest.close()

        color(colors.blue)
        if mode == "install" then 
            println(" Start downloading...")
        else
            println(" Start updating...")
        end
        println(" ")
        color(colors.lightGray)
    
        if mode == "install" then 
            print(" downloading ")
        else
            print(" updating ")
        end

        color(colors.blue)
        println(app)

        for _, file in pairs(local_manifest.files[app]) do 
            color(colors.lightGray)
            local dl, err = http.get(repo .. file)
    
            if dl == nil then
                error(" HTTP Error " .. err)
                error(" Installer download failed.")
            else
                color(colors.lightGray)
                println(" GET " .. file)
                local local_file = fs.open(file, "w")
                local_file.write(dl.readAll())
                local_file.close()
            end
        end
        println(" ")

        if mode == "install" then 
            print(" downloading ")
        else
            print(" updating ")
        end

        color(colors.blue)
        println("graphics")

        for _, file in pairs(local_manifest.files["graphics"]) do 
            color(colors.lightGray)
            local dl, err = http.get(repo .. file)
    
            if dl == nil then
                error(" HTTP Error " .. err)
                error(" Installer download failed.")
            else
                color(colors.lightGray)
                println(" GET " .. file)
                local local_file = fs.open(file, "w")
                local_file.write(dl.readAll())
                local_file.close()
            end
        end
    end
end

local startInstall = function()
    fs.delete(app)
    color(colors.white)
    println(" Chosen: " .. string.upper( app ) .. " " .. mode )
    color(colors.lightGray)
    println(" -----------------------------------")
    os.setComputerLabel(app)
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

local startCheck = function()
    local fileManifest, err = http.get(repo .. manifest)
    local _fileManifest = fs.open("local_manifest.json", "r")

    if fileManifest == nil then
        error(" HTTP Error " .. err)
        error(" Manifest download failed.")
    else
        local_ok, local_manifest = pcall(function () return textutils.unserializeJSON(fileManifest.readAll()) end)
        _local_ok, _local_manifest = pcall(function () return textutils.unserializeJSON(_fileManifest.readAll()) end)
        if not _local_ok then 
            error(" Failed to load local manifest") 
        else
            color(colors.white)
            println(" Name     || Local || Current")
            println(" ")
            for key, ver in pairs(local_manifest.versions) do 
                local _ver = _local_manifest.versions[key]
                color(colors.lightGray)
                print(" ")
                print(key)
                print(string.rep(" ", 8 - #key) .. " || ")
                if ver == _ver then
                    color(colors.green)
                else 
                    color(colors.red)
                end
                print(_ver)
                color(colors.lightGray)
                print(" || ")
                println(ver)
            end
        end
    

    end
end

println(" ")
color(colors.lightGray)
color(colors.white)
println(" SCADA Minecfaft Mekanism " .. version)
color(colors.lightGray)
println(" -----------------------------------")

if #opts == 0 or opts[1] == "help" then
    color(colors.white)
    println(" use: ms <mode> <app>")
    color(colors.lightGray)
    println(" ")
    color(colors.white)
    println(" <mode>")
    color(colors.lightGray)
    println(" install     - fresh install")
    println(" check       - check latest versions available")
    println(" update      - update files")
    color(colors.yellow)
    println("             - skip <app> for update ms.lua")
    color(colors.lightGray)
    println(" uninstall   - delete files")
    println(" ")
    color(colors.white)
    println(" <app>")
    color(colors.lightGray)
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
    if app == nil and mode ~= "check" then
        error(" Unrecognized application.")
        return
    end
end

if mode == "install" and (fs.isDir("plc") or fs.isDir("hmi")) then
    error(" There is already an active mode")
elseif (mode == "install" and not fs.isDir("plc") and not fs.isDir("hmi")) or mode == "update" then
    startInstall()
end

if mode == "uninstall" and fs.isDir(app) then
    startUninstall()
elseif mode == "uninstall" and not fs.isDir(app) then
    error(" Folder does not exist")
end

if mode == "check" and app == nil then
    startCheck()
end

