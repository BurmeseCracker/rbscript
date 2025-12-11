local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")



-- Force Rush Hour module
local RushHourModule = require(LocalPlayer.PlayerScripts.Source.Systems.RushHour)
local ScreenWidgets = require(LocalPlayer.PlayerScripts.Source.Interfaces.Screen.ScreenWidgets)

local function ForceRushHour()
    local eventType = RushHourModule:GetEventType()
    RushHourModule.Active = true
    RushHourModule.EventType = eventType
    RushHourModule.StartTime = os.time()
    RushHourModule.EndTime = os.time() + 3600
    ScreenWidgets:SetRushHourVisible(true)
    print("⚡ Forced Rush Hour ON:", eventType)
end

function RushHourModule:SetState(...)
    ForceRushHour()
end

-- Start forcing Rush Hour
task.wait(1)
ForceRushHour()

-- Refresh every 30 seconds
task.spawn(function()
    while task.wait(30) do
        ForceRushHour()
    end
end)

