-- [[ JumpPower & AirWalk - Sync with Menu Toggle ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local JUMP_POWER_CUSTOM = 150 
local PLATFORM_SIZE = Vector3.new(8, 0.5, 8) 

-- Script IDs (Menu က Toggle တွေနဲ့ တူရမယ်)
local jumpToggle = "jump"
local airWalkToggle = "air_walk"

local airPart = nil

-- [[ Platform ဖန်တီးခြင်း ]] --
local function getAirPart()
    if not airPart or not airPart.Parent then
        airPart = Instance.new("Part")
        airPart.Name = "AirWalkPlatform"
        airPart.Size = PLATFORM_SIZE
        airPart.Transparency = 1 -- မမြင်ရအောင် 1 ထားတယ်
        airPart.Anchored = true
        airPart.CanCollide = true
        airPart.Parent = workspace
    end
    return airPart
end

-- [[ Logic Apply ]] --
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    -- Jump Power Logic
    RunService.Heartbeat:Connect(function()
        if _G[jumpToggle] == true then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = JUMP_POWER_CUSTOM
        else
            -- Toggle OFF ထားရင် Normal ပြန်ဖြစ်စေချင်ရင် ဒီမှာ 50 ပြန်ထားလို့ရတယ်
            -- humanoid.JumpPower = 50 
        end
    end)

    -- Character ပြန်ဖြစ်တိုင်း Jump Power ကို အတင်းသတ်မှတ်မယ်
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if _G[jumpToggle] == true then
            humanoid.JumpPower = JUMP_POWER_CUSTOM
        end
    end)

    -- Air Walk Logic (Heartbeat Loop)
    RunService.Heartbeat:Connect(function()
        if _G[airWalkToggle] == true and character and character.Parent and root then
            local part = getAirPart()
            -- ခြေထောက်အောက်မှာ ကွက်တိဖြစ်အောင် CFrame ကို ချိန်တယ်
            part.CFrame = root.CFrame * CFrame.new(0, -3.8, 0)
        else
            -- Toggle OFF ဖြစ်သွားရင် Platform ကို ဖျက်ပစ်မယ်
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

print("Jump & AirWalk: Toggle Logic Synced.")
