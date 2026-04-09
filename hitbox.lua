-- [[ ZOMBIE HITBOX EXPANDER - MATCHING GAME LOGIC ]] --

local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

-- သင်ပြပေးထားတဲ့ code ထဲကအတိုင်း Characters folder ကို သုံးထားပါတယ်
local targetFolder = workspace:FindFirstChild("Characters")

RunService.RenderStepped:Connect(function()
    -- Menu ကနေ ON ထားမှ အလုပ်လုပ်မည်
    if _G["hitbox"] == true then
        if not targetFolder then return end

        for _, npc in pairs(targetFolder:GetChildren()) do
            -- Player မဟုတ်သော Zombie/Bandit များကို ရှာခြင်း
            if npc:IsA("Model") and npc ~= player.Character then
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                local hum = npc:FindFirstChildOfClass("Humanoid")

                -- အသက်ရှိနေသေးရင် Hitbox ချဲ့မည်
                if hrp and hum and hum.Health > 0 then
                    -- [[ SIZE ADJUSTMENT ]] --
                    -- ဒီနေရာမှာ ကိန်းဂဏန်းကို စိတ်ကြိုက်ပြောင်းနိုင်ပါတယ်
                    hrp.Size = Vector3.new(20, 20, 20) 
                    
                    hrp.Transparency = 0.7
                    hrp.Color = Color3.fromRGB(255, 0, 0) -- အနီရောင်
                    hrp.CanCollide = false
                    hrp.Massless = true
                end
            end
        end
    else
        -- OFF လိုက်လျှင် မူလအတိုင်း ပြန်ဖြစ်သွားစေရန်
        if targetFolder then
            for _, npc in pairs(targetFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Size ~= Vector3.new(2, 2, 1) then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end
end)
