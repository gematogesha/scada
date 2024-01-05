local button = require("graphics/button")

local version = "v0.0.1"

local repo = "http://raw.githubusercontent.com/Gematogesha/scada/main/"

local installJson = "install.json"

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

local function download(mode)
    local file = fs.open(installJson, "r")
    local_ok, local_manifest = pcall(function () return textutils.unserializeJSON(file.readAll()) end)
    println(local_manifest.files.test)

    color(colors.blue)
    println(" Start downloading...")
    color(colors.lightGray)

    local dl, err = http.get(repo .. "ccmsi.lua")

    if dl == nil then
        error("HTTP Error " .. err)
        error("Installer download failed.")
    end

end

local startInstall = function()
    color(colors.white)
    println(" Chosen " .. string.upper( mode ) .. " mode")
    color(colors.lightGray)
    println(" -----------------------------------")
    os.setComputerLabel(mode)
    download(mode)
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
    println(" uninstall   - delete files")
    println(" ")
    println(" <app>")
    println(" plc         - PLC firmware")
    println(" hmi         - HMI firmware")
    return
else 
    mode = get_opt(opts[1], { "install", "uninstall" })
    if mode == nil then
        error("Unrecognized mode.")
        return
    end

    app = get_opt(opts[2], { "plc", "hmi" })
    if app == nil then
        error("Unrecognized application.")
        return
    end
end

if mode == "install" then
    startInstall()
elseif mode == "uninstall" then
    startUninstall()
else
    error("Atypical error")
end
