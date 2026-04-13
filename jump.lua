-- [[ JumpPower & AirWalk - Fixed & Auto-Run ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local JUMP_POWER_CUSTOM = 150 -- ခုန်အားကို ပိုမြှင့်ထားတယ်
local PLATFORM_SIZE = Vector3.new(8, 0.5, 8) 

-- Toggle စစ်တာကို ခဏကျော်ပြီး အမြဲတမ်း ON ထားမယ် (စမ်းသပ်ဖို့)
_G["jump"] = true
_G["air_walk"] = true

local airPart = nil

-- [[ Platform ဖန်တီးခြင်း ]] --
local function getAirPart()
    if not airPart or not airPart.Parent then
        airPart = Instance.new("Part")
        airPart.Name = "AirWalkPlatform"
        airPart.Size = PLATFORM_SIZE
        airPart.Transparency = 0.7 -- စမ်းသပ်နေတုန်း မြင်ရအောင် 0.7 ထားထားတယ်
        airPart.Color = Color3.fromRGB(255, 0, 0) -- အနီရောင်
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
    
    -- Jump Power ကို တိုက်ရိုက်ပြောင်းမယ်
    humanoid.UseJumpPower = true
    humanoid.JumpPower = JUMP_POWER_CUSTOM
    
    -- Character ပြန်ဖြစ်တိုင်း Jump Power ကို အတင်းသတ်မှတ်မယ်
    humanoid:GetPropertyChangedSignal("JumpPower"):Connect(function()
        if _G["jump"] then
            humanoid.JumpPower = JUMP_POWER_CUSTOM
        end
    end)

    -- Air Walk Logic
    RunService.Heartbeat:Connect(function()
        if _G["air_walk"] and character and character.Parent and root then
            local part = getAirPart()
            -- ခြေထောက်အောက်မှာ ကွက်တိဖြစ်အောင် (Height Offset ကို ၃.၈ ထားတယ်)
            part.CFrame = root.CFrame * CFrame.new(0, -3.8, 0)
        else
            if airPart then
                airPart:Destroy()
                airPart = nil
            end
        end
    end)
end

-- Run Now
if player.Character then
    applyLogic(player.Character)
end

player.CharacterAdded:Connect(applyLogic)

print("Jump & AirWalk: Forced ON Version Loaded.")
