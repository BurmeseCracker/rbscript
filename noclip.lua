-- ORIGINAL NOCLIP LOGIC WITH POP-UP
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local player = game.Players.LocalPlayer

if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end

-- ON လိုက်တာနဲ့ Message ပေါ်မယ်
if _G["noclip"] == true then
    StarterGui:SetCore("SendNotification", {
        Title = "Noclip Active",
        Text = "Go slowly through to the wall", -- မင်းလိုချင်တဲ့ English အတိုကောက်စာသား
        Duration = 5
    })
end

_G.NoclipLoop = RunService.Stepped:Connect(function()
    if _G["noclip"] == true then
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    else
        -- OFF ဖြစ်ရင် Logic အဟောင်းအတိုင်း CanCollide ပြန်ဖွင့်မယ်
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
enActiveive
