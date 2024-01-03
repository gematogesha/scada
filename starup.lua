local function println(message) print(tostring(message)) end
local function print(message) term.write(tostring(message)) end

println("BOOT> SCANNING FOR APPLICATIONS...")

local exit_code

if fs.exists("reactor-plc/startup.lua") then
    println("BOOT> EXEC PLC STARTUP")
    exit_code = shell.execute("plc/startup")
elseif fs.exists("rtu/startup.lua") then
    println("BOOT> EXEC HMI STARTUP")
    exit_code = shell.execute("hmi/startup")
else
    println("BOOT> NO SCADA STARTUP FOUND")
    println("BOOT> EXIT")
    return false
end

if not exit_code then println("BOOT> APPLICATION CRASHED") end

return exit_code