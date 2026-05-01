-- [[ Fly Jump - Pure IY Infinite Jump Logic ]] --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local FLY_JUMP_POWER = 50 -- How high each "step" in the air is
local infJumpToggle = "inf_jump"

-- [[ THE FLY JUMP ENGINE ]] --
UserInputService.JumpRequest:Connect(function()
    -- Only runs if your menu toggle is ON
    if _G[infJumpToggle] == true then
        local character = player.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if rootPart and humanoid then
            -- 1. Reset the State (Tells Roblox "I am starting a new jump now")
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- 2. Velocity Injection (The "Fly" part)
            -- This replaces your current falling speed with a fresh upward push.
            -- It doesn't matter how fast you are falling; you will go UP.
            rootPart.AssemblyLinearVelocity = Vector3.new(
                rootPart.AssemblyLinearVelocity.X, 
                FLY_JUMP_POWER, 
                rootPart.AssemblyLinearVelocity.Z
            )
        end
    end
end)

print("Fly Jump: Activated. Spam Space to fly.")
