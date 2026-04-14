-- [[ JumpPower, AirWalk & InfJump - Sync with Menu Toggle ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- CONFIG
local JUMP_POWER_CUSTOM = 150 
local DEFAULT_JUMP_POWER = 50
local PLATFORM_SIZE = Vector3.new(8, 0.5, 8) 

-- Script IDs (Menu Config နဲ့ တူရမယ်)
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
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- [[ Logic Apply ]] --
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    -- Main Loop
    RunService.Heartbeat:Connect(function()
        -- 1. JUMP POWER LOGIC
        if _G[jumpToggle] == true then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = JUMP_POWER_CUSTOM
        else
            -- Reset to 50 when OFF
            if humanoid.JumpPower ~= DEFAULT_JUMP_POWER then
                humanoid.JumpPower = DEFAULT_JUMP_POWER
                humanoid.UseJumpPower = false
            end
        end

        -- 2. AIR WALK LOGIC
        if _G[airWalkToggle] == true and character and character.Parent and root then
            local part = getAirPart()
            part.CFrame = root.CFrame * CFrame.new(0, -3.8, 0)
        else
            if airPart then
                airPart:Destroy()
                airPart = nil
            end
        end
    end)

    -- Force JumpPower if game tries to change it back while ON
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if _G[jumpToggle] == true and humanoid.JumpPower ~= JUMP_POWER_CUSTOM then
            humanoid.JumpPower = JUMP_POWER_CUSTOM
        end
    end)
end

-- Start Logic
if player.Character then
    applyLogic(player.Character)
end

player.CharacterAdded:Connect(applyLogic)

print("Jump, AirWalk & Infinite Jump: Loaded.")
