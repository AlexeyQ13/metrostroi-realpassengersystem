--[[
    
                                                 --- Публичная версия для Steam Workshop ---
    Контакты автора:
        Discord: 257516660431257600 (Alexey#3650)
        Steam:   http://steamcommunity.com/profiles/76561198235732946

    На правах лицензии «Attribution-NonCommercial-NoDerivs» («Атрибуция-Некоммерчески-БезПроизводных») CC BY-NC-ND
    https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode

--]]

-- Performance optimized version with caching

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

-- Cached values to avoid recalculating every frame
local cached_time_string = ""
local cached_metro_status = ""
local cached_rush_hour_status = ""
local cached_is_rush_hour = false
local cached_is_metro_closed = false

-- Cache colors to avoid creating new Color objects
local COLOR_WHITE = color_white
local COLOR_RED = Color(244, 0, 0)

surface.CreateFont("infopass", {
    font = "Moscow Sans Regular",
    extended = true,
    size = 24,
    antialias = true,
    shadow = true,
})

-- Function to update cached values (called by timer, not every frame)
local function updateTimeCache()
    local current_time = os.time()
    local current_minutes = dayToMinuts(current_time)
    local day_abbr = os.date("%a", current_time)
    local is_weekend = (day_abbr == "Sat" or day_abbr == "Sun")
    
    -- Update time string cache
    cached_time_string = "Время: " .. os.date("%H:%M:%S", current_time)
    
    -- Update metro status cache
    cached_is_metro_closed = (current_minutes >= 70 and current_minutes < 320)
    cached_metro_status = cached_is_metro_closed and "Метро закрыто" or "Метро открыто"
    
    -- Update rush hour status cache
    if not is_weekend then
        -- будний день
        cached_is_rush_hour = (current_minutes >= 480 and current_minutes < 600) or 
                             (current_minutes >= 1050 and current_minutes < 1260)
    else
        -- выходной
        cached_is_rush_hour = (current_minutes >= 1050 and current_minutes < 1260)
    end
    
    cached_rush_hour_status = cached_is_rush_hour and "ЧАС-ПИК" or ""
end

-- Initialize cache immediately
updateTimeCache()

-- Update cache every second instead of every frame
timer.Create("passcale_client_cache", 1, 0, updateTimeCache)

-- Optimized HUDPaint hook - now only draws, no calculations
hook.Add("HUDPaint", "pass12312414", function()
    local screen_w = ScrW()
    local screen_h = ScrH()
    local base_y = screen_h / 3
    
    -- Draw metro status
    draw.SimpleText(cached_metro_status, "infopass", screen_w - 10, base_y, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    
    -- Draw time
    local time_offset = cached_is_metro_closed and 24 or 20
    draw.SimpleText(cached_time_string, "infopass", screen_w - 10, base_y + time_offset, COLOR_WHITE, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    
    -- Draw rush hour status if applicable and metro is open
    if not cached_is_metro_closed and cached_is_rush_hour then
        draw.SimpleText(cached_rush_hour_status, "infopass", screen_w - 35, base_y + 48, COLOR_RED, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end)

-- Clean up timer when addon is unloaded
hook.Add("ShutDown", "passcale_cleanup", function()
    if timer.Exists("passcale_client_cache") then
        timer.Remove("passcale_client_cache")
    end
end)