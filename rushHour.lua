local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Check your Tycoon
local function GetMyTycoon()
    local TycoonsFolder = workspace:WaitForChild("Tycoons")
    for _, t in ipairs(TycoonsFolder:GetChildren()) do
        if t:FindFirstChild("Owner") and t.Owner.Value == LocalPlayer then
            return t
        end
    end
    return nil
end

local MyTycoon = GetMyTycoon()

if not MyTycoon then
    -- Kick if no Tycoon belongs to you
    LocalPlayer:Kick("You do not own a Tycoon, script disabled.")
end

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

print("✅ Script active for Tycoon:", MyTycoon.Name)
