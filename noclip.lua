-- [[ ULTIMATE NORMAL JUMP NOCLIP (FIXED) ]] --

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = game.Players.LocalPlayer

-- အရင်ရှိခဲ့တဲ့ Loop ကို ရှင်းထုတ်ခြင်း
if _G.NoclipLoop then 
    _G.NoclipLoop:Disconnect() 
    _G.NoclipLoop = nil
end

-- ၁။ Main Noclip Loop (နံရံဖောက်ရန် အဓိကအပိုင်း)
_G.NoclipLoop = RunService.Stepped:Connect(function()
    if _G["noclip"] == true then
        local char = player.Character
        if not char then return end

        -- ခန္ဓာကိုယ် အစိတ်အပိုင်း အားလုံးကို Collision ပိတ်မည်
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    else
        -- Noclip OFF လုပ်လျှင် အားလုံးပြန်ဖွင့်မည်
        if _G.NoclipLoop then
            _G.NoclipLoop:Disconnect()
            _G.NoclipLoop = nil
        end
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end
        end
    end
end)

-- ၂။ ပုံမှန်အတိုင်း ခုန်နိုင်စေရန် (Jump Fix)
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and _G["noclip"] == true then
        if input.KeyCode == Enum.KeyCode.Space then
            local char = player.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            
            if hum then
                -- ခုန်သည့် Animation နှင့် Force ကို ပေးခြင်း
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

print("Noclip Fixed: You can now go through walls and jump normally!")
