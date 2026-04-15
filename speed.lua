-- Infinite Yield Style Speed Hack
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Global variable ကို သုံးပြီး ON/OFF လုပ်မယ် (မင်းရဲ့ Menu နဲ့ ချိတ်ဖို့)
_G.SpeedValue = 70 -- Default speed

if _G.SpeedLoop then _G.SpeedLoop:Disconnect() end

_G.SpeedLoop = RunService.Stepped:Connect(function()
    if _G["speed"] == true then -- မင်းရဲ့ Menu က scriptID ("speed") နဲ့ တိုက်စစ်တာ
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if hum then
            hum.WalkSpeed = _G.SpeedValue
        end
    else
        -- OFF ဖြစ်သွားရင် ပုံမှန်အမြန်နှုန်း (16) ကို ပြန်ပြောင်းမယ်
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.WalkSpeed = 16
        end
        _G.SpeedLoop:Disconnect()
        _G.SpeedLoop = nil
    end
end)
