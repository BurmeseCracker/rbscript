-- IMPROVED NOCLIP (Anti-Rubberband)
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end

_G.NoclipLoop = RunService.Stepped:Connect(function()
    if _G["noclip"] == true then
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            -- Character ကို Noclip State (11) ပြောင်းလိုက်ခြင်းဖြင့် Physics ကန်အားကို လျှော့ချမယ်
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(11)
            end
        end
    else
        -- OFF လုပ်လိုက်ရင် ပုံမှန်အတိုင်း ပြန်ဖြစ်သွားမယ်
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
        _G.NoclipLoop:Disconnect()
        _G.NoclipLoop = nil
    end
end)
