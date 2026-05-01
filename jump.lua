-- [[ Infinite Jump - IY Style (Fixed & Continuous) ]] --
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local JUMP_HEIGHT = 50 -- Standard IY jump power
local infJumpToggle = "inf_jump"
local jumpToggle = "jump"
local airWalkToggle = "air_walk"

-- [[ THE CORE INFINITE JUMP ]] --
-- This fires every time you press Space, even if you are falling or mid-air
UserInputService.JumpRequest:Connect(function()
    if _G[infJumpToggle] == true then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")

        if humanoid and rootPart then
            -- 1. Reset state so the game thinks you are starting a fresh jump
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            
            -- 2. Force velocity (IY Method): 
            -- We keep X and Z (horizontal movement) but force Y (vertical) to our Jump Height.
            -- This prevents gravity from "eating" your jump.
            rootPart.AssemblyLinearVelocity = Vector3.new(
                rootPart.AssemblyLinearVelocity.X, 
                JUMP_HEIGHT, 
                rootPart.AssemblyLinearVelocity.Z
            )
        end
    end
end)

-- [[ SUPPORT LOGIC (AirWalk & JumpPower) ]] --
local airPart = nil
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then
            connection:Disconnect()
            return
        end

        -- JumpPower Lock
        if _G[jumpToggle] == true then
            humanoid.JumpPower = JUMP_HEIGHT
        end

        -- AirWalk Logic
        if _G[airWalkToggle] == true then
            if not airPart or not airPart.Parent then
                airPart = Instance.new("Part")
                airPart.Name = "IY_AirWalk"
                airPart.Size = Vector3.new(8, 0.5, 8)
                airPart.Transparency = 1
                airPart.Anchored = true
                airPart.Parent = workspace
            end
            airPart.CFrame = root.CFrame * CFrame.new(0, -3.8, 0)
        else
            if airPart then
                airPart:Destroy()
                airPart = nil
            end
        end
    end)
end

player.CharacterAdded:Connect(applyLogic)
if player.Character then applyLogic(player.Character) end

print("Infinite Jump: IY-Style Loaded. Ready for flight.")
