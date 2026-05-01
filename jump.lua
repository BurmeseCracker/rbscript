-- [[ jump.lua - Sky Climber / Fly Jump Edition ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local JUMP_POWER_VALUE = 50 
local scriptID = "jump" -- This matches your Menu's AddToggle("Jump Height", "jump.lua")

-- Infinite Jump / Fly-Jump Logic
if _G.JumpConnection then _G.JumpConnection:Disconnect() end

_G.JumpConnection = UserInputService.JumpRequest:Connect(function()
    -- Checks if the Toggle in the Menu is ON
    if _G[scriptID] == true then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            -- Force Jumping State
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- IY-Style Fly Jump Velocity (Up and Up)
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X, 
                JUMP_POWER_VALUE, 
                root.AssemblyLinearVelocity.Z
            )
        end
    end
end)

-- Loop to ensure the JumpPower stays normal while active
task.spawn(function()
    while _G[scriptID] == true do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = JUMP_POWER_VALUE
            hum.UseJumpPower = true
        end
        task.wait(1)
    end
end)

print("Jump Logic Linked to Menu Toggle: " .. scriptID)
