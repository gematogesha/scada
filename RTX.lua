
local function println(message) print(tostring(message)) end
local function print(message) term.write(tostring(message)) end

local width, height = term.getSize()
height = height + 1
local aspect = width / height
local pixelAspect = 15 / 22

local screen = {}

for i = 1, height do
    screen[i] = {}
    for j = 1, width do
        local x = j / width * 2 - 1
        local y = i / height * 2 - 1 
        local pixel = " "
        x = x * aspect * pixelAspect
        if (x * x + y * y < 0.7) then pixel = "@" end
        screen[i][j] = pixel
    end
end

local function printScreen()
    term.clear()
    term.setCursorPos(1, 1)
    for i in pairs(screen) do
        for j in pairs(screen[i]) do
            if j == width then
                println(screen[i][j])
            else
                print(screen[i][j])
            end
        end
    end
end

printScreen()
