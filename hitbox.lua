-- [[ ZOMBIE HITBOX EXPANDER - MENU VERSION ]] --
-- Menu ရဲ့ _G["hitbox"] variable နဲ့ ချိတ်ဆက်ထားပါတယ်

local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local targetFolder = workspace:FindFirstChild("Characters")

local function runHitboxLogic()
    -- Script က Menu ပိတ်လိုက်ရင် ရပ်သွားအောင် Loop ပတ်ပါမယ်
    while _G["hitbox"] do 
        if targetFolder then
            for _, npc in pairs(targetFolder:GetChildren()) do
                if npc:IsA("Model") and npc.Name ~= player.Name then
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    local hum = npc:FindFirstChildOfClass("Humanoid")

                    if hrp and hum and hum.Health > 0 then
                        -- Hitbox ကို ဆွဲဆန့်ခြင်း
                        hrp.Size = Vector3.new(15, 15, 15)
                        hrp.Transparency = 0.7
                        hrp.Color = Color3.fromRGB(255, 0, 0)
                        hrp.CanCollide = false
                    end
                end
            end
        end
        task.wait(0.5) -- Server လေးမသွားအောင် Delay လေး ခံထားပါတယ်
    end

    -- Toggle OFF လုပ်လိုက်တဲ့အခါ Hitbox တွေကို မူလအရွယ်အစား (2, 2, 1) ပြန်ပြောင်းပေးခြင်း
    if not _G["hitbox"] then
        if targetFolder then
            for _, npc in pairs(targetFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1 -- မမြင်ရအောင် ပြန်ပိတ်
                end
            end
        end
    end
end

-- Toggle ON ဖြစ်နေသရွေ့ Run မည်
task.spawn(runHitboxLogic)
