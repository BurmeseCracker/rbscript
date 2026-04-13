-- [[ JumpPower & AirWalk Script - Full Version ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local JUMP_POWER_CUSTOM = 40 
local JUMP_POWER_DEFAULT = 50 
local PLATFORM_SIZE = Vector3.new(6, 0.5, 6) -- ခြေထောက်အောက်က part ရဲ့ အရွယ်အစား

-- Global Toggles (Menu ကနေ control လုပ်ဖို့)
_G["jump"] = _G["jump"] or false
_G["air_walk"] = _G["air_walk"] or false

local airPart = nil

-- [[ Invisible Part Creation ]] --
local function getAirPart()
    if not airPart or not airPart.Parent then
        airPart = Instance.new("Part")
        airPart.Name = "AirWalkPlatform"
        airPart.Size = PLATFORM_SIZE
        airPart.Transparency = 1 -- အမြင်မရအောင် ၁ ထားတယ် (စမ်းချင်ရင် 0.5 ပြောင်းကြည့်ပါ)
        airPart.Anchored = true
        airPart.CanCollide = true
        airPart.Parent = workspace
    end
    return airPart
end

-- [[ Jump & AirWalk Logic ]] --
local function applyLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    
    -- Jump Power Loop
    task.spawn(function()
        while character and character.Parent do
            if _G["jump"] then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = JUMP_POWER_CUSTOM
            else
                humanoid.JumpPower = JUMP_POWER_DEFAULT
            end
            task.wait(0.5)
        end
    end)

    -- Air Walk / Stay on Invisible Part Loop
    RunService.Heartbeat:Connect(function()
        if _G["air_walk"] and character and character.Parent then
            local part = getAirPart()
            -- လူရဲ့ ခြေထောက်အောက် (၃.၅ unit) အကွာမှာ part ကို အမြဲကပ်နေစေမယ်
            part.CFrame = root.CFrame * CFrame.new(0, -3.5, 0)
        else
            if airPart then
                airPart:Destroy()
                airPart = nil
            end
        end
    end)
end

-- Initialization
if player.Character then
    applyLogic(player.Character)
end

player.CharacterAdded:Connect(function(character)
    applyLogic(character)
end)

print("Jump & AirWalk Script Loaded.")
print("Toggle _G['jump'] for High Jump")
print("Toggle _G['air_walk'] for Invisible Platform")
