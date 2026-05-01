-- [[ JumpPower (Normal), AirWalk & InfJump - Sky Climber Edition ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local DEFAULT_JUMP_POWER = 50 -- Standard Roblox Jump
local PLATFORM_SIZE = Vector3.new(8, 0.5, 8) 

-- Script IDs
local jumpToggle = "jump" -- Keep this to toggle between custom and normal
local airWalkToggle = "air_walk"
local infJumpToggle = "inf_jump"

local airPart = nil

-- [[ Platform Handling ]] --
local function getAirPart()
    if not airPart or not airPart.Parent then
        airPart = Instance.new("Part")
        airPart.Name = "AirWalkPlatform"
        airPart.Size = PLATFORM_SIZE
        airPart.Transparency = 1 
        airPart.Anchored = true
        airPart.CanCollide = true
        airPart.Parent = workspace
    end
    return airPart
end

-- [[ UPDATED Infinite Jump Logic ]] --
-- This version allows you to climb "up and up" using normal jump height
UserInputService.JumpRequest:Connect(function()
    if _G[infJumpToggle] == true then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            -- Reset state to allow a fresh jump mid-air
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- Set the vertical velocity to match a normal jump (approx 50 velocity)
            -- This makes every air-jump feel exactly like a ground-jump
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X, 
                DEFAULT_JUMP_POWER, 
                root.AssemblyLinearVelocity.Z
            )
        end
    end
end)

-- [[ Logic Apply ]] --
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then
            connection:Disconnect()
            return
        end

        -- 1. JUMP POWER LOGIC (Force Normal)
        -- Even if the game tries to nerf your jump, this keeps it at 50
        if _G[jumpToggle] == true then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = DEFAULT_JUMP_POWER 
        end

        -- 2. AIR WALK LOGIC
        if _G[airWalkToggle] == true and root then
            local part = getAirPart()
            part.CFrame = root.CFrame * CFrame.new(0, -3.8, 0)
        else
            if airPart then
                airPart:Destroy()
                airPart = nil
            end
        end
    end)
end

-- Start Logic
if player.Character then
    applyLogic(player.Character)
end

player.CharacterAdded:Connect(applyLogic)

print("Sky Climber: Normal JumpPower + Infinite Jump Loaded.")
