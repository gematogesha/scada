
local function println(message) print(tostring(message)) end
local function print(message) term.write(tostring(message)) end

local width, height = term.getSize()
local aspect = width / height
local pixelAspect = 15 / 22

local screen = {}
local gradient = {" ",".",":","!","/","r","(","l","1","Z","4","H","9","W","8","$","@"}

local function printScreen()
    term.clear()
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


for t = 1, 100000 do
    for i = 1, height do
        screen[i] = {}
        for j = 1, width do
            local x = j / width * 2 - 1
            local y = i / height * 2 - 1 
            x = x * aspect * pixelAspect
            x = x + math.sin( t * 0.01 )
            local pixel = " "
            local dist = math.sqrt( x * x + y * y )
            local color = math.floor(1 / dist) + 1
            if (color < 0 ) then color = 0 elseif (color > #gradient) then color = #gradient end

            pixel = gradient[color]
            screen[i][j] = pixel
        end
    end
    printScreen()
    os.sleep(0.01)
end



