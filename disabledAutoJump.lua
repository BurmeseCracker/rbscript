-- [[ disableAutoJump.lua - Permanent Force Disable (No Toggle) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function forceDisable(character)
    local humanoid = character:WaitForChild("Humanoid")

    -- Heartbeat သုံးပြီး Frame တိုင်းမှာ AutoJumpEnabled ကို false ဖြစ်အောင် အတင်းလုပ်မယ်
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent then
            connection:Disconnect()
            return
        end
        
        -- ဘာမှမစစ်ဘဲ အမြဲတမ်း ပိတ်ထားမယ်
        if humanoid.AutoJumpEnabled ~= false then
            humanoid.AutoJumpEnabled = false
        end
    end)
end

-- လက်ရှိရှိနေတဲ့ Character အတွက် run မယ်
if player.Character then
    forceDisable(player.Character)
end

-- အသစ်ပြန်ပွင့်လာတဲ့ Character (Respawn) တိုင်းအတွက် run မယ်
player.CharacterAdded:Connect(forceDisable)

print("AutoJump has been PERMANENTLY disabled.")
