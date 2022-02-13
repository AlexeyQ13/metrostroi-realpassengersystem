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

local chaspik = true

surface.CreateFont("infopass", {
    font = "Moscow Sans Regular",
    extended = true,
    size = 24,
    antialias = true,
    shadow = true,
})

hook.Add("HUDPaint", "pass12312414", function()

    if not os.date("%a", os.time()) == "Sat" or os.date("%a", os.time()) == "Sun" then
        --будний день
        if dayToMinuts() >= 480 and dayToMinuts() < 600 or dayToMinuts() >= 1050 and dayToMinuts() < 1260 then
            chaspik = true
        else
            chaspik = false
        end
    else
        --выходной
        if dayToMinuts() >= 1050 and dayToMinuts() < 1260 then
            chaspik = true
        else
            chaspik = false
        end
    end

    if dayToMinuts() >= 70 and dayToMinuts() < 320 then
        draw.SimpleText("Метро закрыто", "infopass", ScrW() - 10, ScrH() / 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Время: " .. os.date("%H:%M:%S", os.time()), "infopass", ScrW() - 10, ScrH() / 3 + 24, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText("Метро открыто", "infopass", ScrW() - 10, ScrH() / 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Время: " .. os.date("%H:%M:%S", os.time()), "infopass", ScrW() - 10, ScrH() / 3 + 20, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        if chaspik then
            draw.SimpleText("ЧАС-ПИК", "infopass", ScrW() - 35, ScrH() / 3 + 48, Color(244, 0, 0), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
end)