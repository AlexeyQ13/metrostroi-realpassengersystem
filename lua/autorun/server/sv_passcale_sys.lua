--[[
    
                                                 --- Публичная версия для Steam Workshop ---
    Контакты автора:
        Discord: 257516660431257600 (Alexey#3650)
        Steam:   http://steamcommunity.com/profiles/76561198235732946

    На правах лицензии «Attribution-NonCommercial-NoDerivs» («Атрибуция-Некоммерчески-БезПроизводных») CC BY-NC-ND
    https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode

--]]

-- Performance optimized version with smart intervals and caching

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

local multipler = 0.8
local last_scale = -1 -- Cache last scale to avoid redundant console commands

local function passcale(scale)
    local final_scale = scale * multipler
    -- Only run console command if scale actually changed
    if final_scale ~= last_scale then
        RunConsoleCommand("metrostroi_passengers_scale", final_scale)
        last_scale = final_scale
    end
end

-- Function to determine if current day is weekend
local function isWeekend(time_val)
    local day_abbr = os.date("%a", time_val or os.time())
    return day_abbr == "Sat" or day_abbr == "Sun"
end

-- Function to calculate smart timer interval based on time
local function getNextCheckInterval(current_minutes)
    -- More frequent checks during transition periods
    local transition_times = {70, 320, 330, 390, 480, 600, 1050, 1260, 1320}
    
    for _, transition_time in ipairs(transition_times) do
        local minutes_to_transition = transition_time - current_minutes
        if minutes_to_transition > 0 and minutes_to_transition <= 60 then
            return 5 -- Check every 5 seconds when within 1 hour of transition
        end
    end
    
    return 30 -- Default to 30 seconds for normal periods
end

local function check()
    local current_time = os.time()
    local timemin = dayToMinuts(current_time)
    local is_weekend = isWeekend(current_time) -- Fixed: now calculates every time
    
    if not is_weekend then
        --будний день
        if timemin >= 0 and timemin < 60 then
            passcale(5) --0:00 - 1:00 = 5
        elseif timemin >= 60 and timemin < 70 then
            passcale(3) --1:00 - 1:10 = 3
        elseif timemin >= 70 and timemin < 320 then
            passcale(0) --1:10 - 5:20 = 0
        elseif timemin >= 320 and timemin < 330 then
            passcale(3) --5:20 - 5:30 = 3
        elseif timemin >= 330 and timemin < 390 then
            passcale(10) --5:30 - 6:30 = 10
        elseif timemin >= 390 and timemin < 480 then
            passcale(50) --6:30 - 8:00 = 50 
        elseif timemin >= 480 and timemin < 600 then
            passcale(80) --8:00 - 10:00 = 80  [rush hour]
        elseif timemin >= 600 and timemin < 1050 then
            passcale(45) --10:00 - 17:30 = 45
        elseif timemin >= 1050 and timemin < 1260 then
            passcale(80) --17:30 - 21:00 = 80  [rush hour]
        elseif timemin >= 1260 and timemin < 1320 then
            passcale(35) --21:00 - 22:00 = 35
        elseif timemin >= 1320 then
            passcale(15) --22:00 - 00:00 = 15
        end
    else
        --выходной
        if timemin >= 0 and timemin < 70 then
            passcale(2) --0:00 - 1:10 = 2
        elseif timemin >= 70 and timemin < 320 then
            passcale(0) --1:10 - 5:20 = 0
        elseif timemin >= 320 and timemin < 330 then
            passcale(2) --5:20 - 5:30 = 2
        elseif timemin >= 330 and timemin < 390 then
            passcale(7) --5:30 - 6:30 = 7
        elseif timemin >= 390 and timemin < 480 then
            passcale(14) --6:30 - 8:00 = 14
        elseif timemin >= 480 and timemin < 600 then
            passcale(16) --8:00 - 10:00 = 16
        elseif timemin >= 600 and timemin < 1050 then
            passcale(20) --10:00 - 17:30 = 20
        elseif timemin >= 1050 and timemin < 1260 then
            passcale(35) --17:30 - 21:00 = 35  [rush hour]
        elseif timemin >= 1260 and timemin < 1320 then
            passcale(24) --21:00 - 22:00 = 24
        elseif timemin >= 1320 then
            passcale(6) --22:00 - 00:00 = 6
        end
    end
    
    -- Calculate next check interval and update timer
    local next_interval = getNextCheckInterval(timemin)
    timer.Create("changepasscale", next_interval, 1, check)
end

-- Start the system
timer.Create("changepasscale", 1, 1, check) -- Initial check after 1 second

-- Optional: Add cleanup on server shutdown
hook.Add("ShutDown", "passcale_server_cleanup", function()
    if timer.Exists("changepasscale") then
        timer.Remove("changepasscale")
    end
end)