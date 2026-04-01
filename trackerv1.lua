local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Rush Hour modules
local RushHourModule = require(LocalPlayer.PlayerScripts.Source.Systems.RushHour)
local ScreenWidgets = require(LocalPlayer.PlayerScripts.Source.Interfaces.Screen.ScreenWidgets)

-- Safely get event type
local function GetSafeEventType()
    local ok, result = pcall(function()
        return RushHourModule:GetEventType()
    end)

    if ok and result then
        return result
    else
        warn("⚠ RushHourModule:GetEventType() returned NIL, using default 'Standard'")
        return "Standard"
    end
end

local function ForceRushHour()
    local eventType = GetSafeEventType()

    RushHourModule.Active = true
    RushHourModule.EventType = eventType
    RushHourModule.StartTime = os.time()
    RushHourModule.EndTime = os.time() + 3600

    -- Protect UI update (prevent nil errors)
    pcall(function()
        ScreenWidgets:SetRushHourVisible(true)
    end)

end

-- Hook state changes
function RushHourModule:SetState(...)
    ForceRushHour()
end

-- Initial start
task.wait(1)
ForceRushHour()

-- Auto refresh
task.spawn(function()
    while task.wait(30) do
        ForceRushHour()
    end
end)
