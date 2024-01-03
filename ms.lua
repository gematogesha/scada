local button = require("graphics/button")

local version = "v0.0.1"

local function println(message) print(tostring(message)) end
local function print(message) term.write(tostring(message)) end

local function color(color) term.setTextColor(color) end
local function bg(color) term.setBackgroundColor(color) end 

local function cursor(x, y) term.setCursorPos(x, y) end

local opts = { ... }
local mode

local function get_opt(opt, options)
    for _, v in pairs(options) do 
        if opt == v then 
            return v 
        end 
    end
    return nil
end

local plc = function()
    color(colors.white)
    println(" chosen PLC mode")
    color(colors.lightGray)
    println(" -----------------------------------")
    os.setComputerLabel("plc")
    os.getComputerLabel()
end

function file_exists(name)
    local f = io.open(name .. "/starup.lua","r")
    if f ~= nil then 
        io.close(f) 
        return true 
    else 
        return false 
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
    println(" use: ms <mode>")
    color(colors.lightGray)
    println(" <mode>")
    println(" plc         - PLC firmware")
    println(" hmi         - HMI firmware")
    return
else 
    mode = get_opt(opts[1], { "plc", "hmi" })
    if mode == nil then
        color(colors.red)
        println("Unrecognized mode.")
        color(colors.white)
        return
    end
end

if mode == "plc" then
    plc()
elseif mode == "hmi" then
    hmi()
else
    return false
end



print(opts[0])

