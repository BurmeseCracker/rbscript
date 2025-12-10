local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Load original RushHour module
local RushHourModule = require(
    LocalPlayer.PlayerScripts.Source.Systems.RushHour
)

-- Get dependencies from inside the module
local ScreenWidgets = require(
    LocalPlayer.PlayerScripts.Source.Interfaces.Screen.ScreenWidgets
)

-- Forcing Rush Hour Function
local function ForceRushHour()
	-- Choose a random RushHour type using module function
	local eventType = RushHourModule:GetEventType()

	-- Force rush hour always ON
	RushHourModule.Active = true
	RushHourModule.EventType = eventType
	RushHourModule.StartTime = os.time()
	RushHourModule.EndTime = os.time() + 3600  -- 1 hour

	-- UI ALWAYS ON
	ScreenWidgets:SetRushHourVisible(true)

	print("⚡ Forced Rush Hour:", eventType)
end

-- Override SetState so server CANNOT turn it off
function RushHourModule.SetState(self, ...)
	ForceRushHour()
end

-- Force on at start
task.wait(1)
ForceRushHour()

-- Refresh every 30 seconds
while task.wait(30) do
	ForceRushHour()
end
