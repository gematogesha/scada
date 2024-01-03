local t = {}
t.func = function(x, y, text, textColor, bacgroundColor, status)

    local writeText = " " .. text .. " "
    
    term.setCursorPos(x, y)
    term.setBackgroundColor(bacgroundColor)
    term.setTextColor(textColor)
    write(string.rep(" ", writeText:len()))
    term.setCursorPos(x, y+1)
    write(writeText)
    term.setCursorPos(x, y+2)
    write(string.rep(" ", writeText:len()))
    
    t.status = status
end

return t