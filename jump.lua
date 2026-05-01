-- [[ JumpPower, AirWalk & InfJump - Fixed & Polished ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local DEFAULT_JUMP_POWER = 50 
local PLATFORM_SIZE = Vector3.new(8, 0.5, 8) 

-- Script IDs (Check these match your UI Toggle Names)
local jumpToggle = "jump" 
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

-- [[ Infinite Jump Logic ]] --
UserInputService.JumpRequest:Connect(function()
    if _G[infJumpToggle] == true then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            -- Force the Jumping state
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- Apply upward velocity (Normal Jump Strength)
            root.AssemblyLinearVelocity = Vector3.new(
                root.AssemblyLinearVelocity.X, 
                DEFAULT_JUMP_POWER, 
                root.AssemblyLinearVelocity.Z
            )
            -- print("Jumping...") -- Uncomment to test if the toggle works
        end
    end
end)

-- [[ Core Logic Loop ]] --
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    -- Using a named function for the connection so we can manage it better
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent or not humanoid then
            connection:Disconnect()
            return
        end

        -- 1. JUMP POWER LOGIC
        if _G[jumpToggle] == true then
            humanoid.UseJumpPower = true
            if humanoid.JumpPower ~= DEFAULT_JUMP_POWER then
                humanoid.JumpPower = DEFAULT_JUMP_POWER 
            end
        end

        -- 2. AIR WALK LOGIC
        if _G[airWalkToggle] == true then
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

-- Monitor for Character
player.CharacterAdded:Connect(function(newChar)
    applyLogic(newChar)
end)

if player.Character then
    applyLogic(player.Character)
end

print("Sky Climber: Ready. Ensure _G variables are set to 'true' in your menu.")
