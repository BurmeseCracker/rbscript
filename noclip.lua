-- [[ ULTIMATE NOCLIP WITH AUTO-SPEED REDUCTION ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

-- အရင် Loop ဟောင်းကို ရှင်းထုတ်ခြင်း
if _G.NoclipLoop then 
    _G.NoclipLoop:Disconnect() 
    _G.NoclipLoop = nil
end

-- Raycast အတွက် Parameter များ (နံရံကို စမ်းသပ်ရန်)
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

-- ၁။ Main Noclip & Auto-Speed Loop
_G.NoclipLoop = RunService.Stepped:Connect(function()
    if _G["noclip"] == true then
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if not char or not hrp or not hum then return end
        rayParams.FilterDescendantsInstances = {char}

        -- နံရံနဲ့ ထိမထိ ရှေ့ကို Ray လွှတ်ပြီး စစ်ဆေးခြင်း (Distance: 2 studs)
        local lookDir = hrp.CFrame.LookVector * 2
        local rayResult = workspace:Raycast(hrp.Position, lookDir, rayParams)

        if rayResult then
            -- နံရံရှိနေရင် Speed ကို ၅ ထားပြီး Collision ပိတ်မယ်
            hum.WalkSpeed = 5
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        else
            -- နံရံမရှိရင် Speed ကို ပုံမှန် (၁၆) ပြန်ထားမယ်
            hum.WalkSpeed = 16
            -- Collision ကိုတော့ Noclip ဖြစ်နေလို့ ပိတ်ထားဆဲပဲ ဖြစ်ရမယ်
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    else
        -- Noclip OFF လုပ်လျှင် အားလုံးကို မူလအတိုင်း ပြန်ပြင်ခြင်း
        if hum then hum.WalkSpeed = 16 end
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
        if _G.NoclipLoop then
            _G.NoclipLoop:Disconnect()
            _G.NoclipLoop = nil
        end
    end
end)

-- ၂။ Jump Fix (ပုံမှန်အတိုင်း ခုန်နိုင်ရန်)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and _G["noclip"] == true then
        if input.KeyCode == Enum.KeyCode.Space then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

print("Noclip with Auto-Speed: Activated! Speed drops to 5 near walls.")
