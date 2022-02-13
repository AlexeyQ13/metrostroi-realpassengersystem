--[[
    
                                                 --- Публичная версия для Steam Workshop ---
    Контакты автора:
        Discord: 257516660431257600 (Alexey#3650)
        Steam:   http://steamcommunity.com/profiles/76561198235732946

    На правах лицензии «Attribution-NonCommercial-NoDerivs» («Атрибуция-Некоммерчески-БезПроизводных») CC BY-NC-ND
    https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode

--]]

local function dayToMinuts(x)
    --можно не передавать переменную в функцию, но тогда будет брать текущее время, тоесть реалтайм
    if not x then
        x = os.time()
    end

    local daystr = os.date("%H %M", x)
    local timeTbl = string.Explode(" ", daystr)
    -- timeTbl[1] - часы | timeTbl[2] - минуты 

    return tonumber(timeTbl[1]) * 60 + tonumber(timeTbl[2])
end

local vix = os.date("%a", os.time()) == "Sat" or os.date("%a", os.time()) == "Sun"
local multipler = 0.8

local function passcale(scale)
    RunConsoleCommand("metrostroi_passengers_scale", scale * multipler)
end

local function check()
    local timemin = dayToMinuts()
    if not vix then
        --будний день
        if timemin >= 0 and timemin < 60 then
            passcale(5) --0:00 - 1:00 = 5
        elseif timemin >= 60 and timemin < 70 then
            passcale(3) --1:00 - 1:10 = 1
        elseif timemin >= 70 and timemin < 320 then
            passcale(0) --1:10 - 5:20 = 0
        elseif timemin >= 320 and timemin < 330 then
            passcale(3) --5:20 - 5:30 = 1
        elseif timemin >= 330 and timemin < 390 then
            passcale(10) --5:30 - 6:30 = 5
        elseif timemin >= 390 and timemin < 480 then
            passcale(50) --6:30 - 8:00 = 35 
        elseif timemin >= 480 and timemin < 600 then
            passcale(80) --8:00 - 10:00 = 50  x 
        elseif timemin >= 600 and timemin < 1050 then
            passcale(45) --10:00 - 17:30 = 30
        elseif timemin >= 1050 and timemin < 1260 then
            passcale(80) --17:30 - 21:00 = 50  x
        elseif timemin >= 1260 and timemin < 1320 then
            passcale(35) --21:00 - 22:00 = 30
        elseif timemin >= 1320 then
            passcale(15) --22:00 - 00:00 = 10
        end
    else
        --выходной
        if timemin >= 1 and timemin < 70 then
            passcale(2) --0:00 - 1:10 = 1
        elseif timemin >= 70 and timemin < 320 then
            passcale(0) --1:10 - 5:20 = 0
        elseif timemin >= 320 and timemin < 330 then
            passcale(2) --5:20 - 5:30 = 1
        elseif timemin >= 330 and timemin < 390 then
            passcale(7) --5:30 - 6:30 = 3
        elseif timemin >= 390 and timemin < 480 then
            passcale(14) --6:30 - 8:00 = 8
        elseif timemin >= 480 and timemin < 600 then
            passcale(16) --8:00 - 10:00 = 13
        elseif timemin >= 600 and timemin < 1050 then
            passcale(20) --10:00 - 17:30 = 18
        elseif timemin >= 1050 and timemin < 1260 then
            passcale(35) --17:30 - 21:00 = 27  x
        elseif timemin >= 1260 and timemin < 1320 then
            passcale(24) --21:00 - 22:00 = 15
        elseif timemin >= 1320 then
            passcale(6) --22:00 - 00:00 = 6
        end
    end
end

timer.Create("changepasscale", 10, 99999, check)