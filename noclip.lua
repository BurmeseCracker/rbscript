-- FINAL ANTI-KICK NOCLIP (Simplified)
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

-- အရင်ရှိခဲ့တဲ့ Loop ကို အရင်ဖြတ်မယ်
if _G.NoclipLoop then 
    _G.NoclipLoop:Disconnect() 
    _G.NoclipLoop = nil
end

_G.NoclipLoop = RunService.Stepped:Connect(function()
    -- Menu မှာ ON ထားမှ အလုပ်လုပ်မယ်
    if _G["noclip"] == true then
        local char = player.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")

        -- ၁။ ခန္ဓာကိုယ်အစိတ်အပိုင်းအားလုံးကို Collision ပိတ်မယ်
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
        
        -- ၂။ Humanoid State ကို Noclip state (11) ပြောင်းမယ်
        if hum then 
            hum:ChangeState(11) 
        end
    else
        -- OFF လုပ်လိုက်ရင် Loop ကိုပါ အပြီးသတ်ဖျက်မယ်
        if _G.NoclipLoop then
            _G.NoclipLoop:Disconnect()
            _G.NoclipLoop = nil
        end
        
        -- Collision တွေကို ပြန်ဖွင့်ပေးမယ်
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
    end
end)
