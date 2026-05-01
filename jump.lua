-- [[ Sky Climber - Continuous Air Jump Edition ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local DEFAULT_JUMP_POWER = 50 
local PLATFORM_SIZE = Vector3.new(8, 0.5, 8) 

-- Script IDs
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

-- [[ FIXED Continuous Infinite Jump Logic ]] --
UserInputService.JumpRequest:Connect(function()
    if _G[infJumpToggle] == true then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if hum and root then
            -- Reset vertical velocity immediately to prevent "falling momentum" from stopping the jump
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
            
            -- Force jump state and apply upward force
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, DEFAULT_JUMP_POWER, root.AssemblyLinearVelocity.Z)
        end
    end
end)

-- [[ Core Logic Loop ]] --
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent or not humanoid then
            connection:Disconnect()
            return
        end

        -- 1. JUMP POWER LOGIC
        if _G[jumpToggle] == true then
            humanoid.UseJumpPower = true
            -- Keep it locked at 50 so every jump is the same height
            if humanoid.JumpPower ~= DEFAULT_JUMP_POWER then
                humanoid.JumpPower = DEFAULT_JUMP_POWER 
            end
        end

        -- 2. AIR WALK LOGIC
        if _G[airWalkToggle] == true then
            local part = getAirPart()
            -- Sync platform position slightly below the root part
            part.CFrame = root.CFrame * CFrame.new(0, -3.8, 0)
        else
            if airPart then
                airPart:Destroy()
                airPart = nil
            end
        end
    end)
end

-- Character Monitoring
player.CharacterAdded:Connect(applyLogic)
if player.Character then applyLogic(player.Character) end

print("Sky Climber: Ready. Infinite jumping is now forced.")
