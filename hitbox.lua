-- [[ ZOMBIE HITBOX EXPANDER FOR BURMESE MOD MENU ]] --

local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer
local targetFolder = workspace:FindFirstChild("Characters")

-- Hitbox ပြင်ဆင်မည့် Function
local function ApplyHitbox(npc, size, transparency, canCollide)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.Size = size
        hrp.Transparency = transparency
        hrp.CanCollide = canCollide
        -- ရန်သူမှန်းသိသာအောင် အနီရောင်ဖျော့ဖျော့လေး ပြထားမယ်
        hrp.Color = Color3.fromRGB(255, 0, 0) 
    end
end

-- Main Loop (Heartbeat သုံးထားလို့ တုန်ခါမှုမရှိဘဲ ငြိမ်ပါတယ်)
RunService.Heartbeat:Connect(function()
    -- Menu ရဲ့ Toggle ON/OFF ကို စစ်ဆေးခြင်း
    if _G["hitbox"] == true then
        if targetFolder then
            for _, npc in pairs(targetFolder:GetChildren()) do
                -- ကိုယ့်ကိုယ်ကို မဟုတ်တာ သေချာမှ လုပ်မယ်
                if npc:IsA("Model") and npc.Name ~= player.Name then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    -- အသက်ရှိတဲ့ Zombie တွေကိုပဲ Hitbox ချဲ့မယ်
                    if hum and hum.Health > 0 then
                        ApplyHitbox(npc, Vector3.new(30, 30, 30), 0.7, false)
                    else
                        -- သေသွားရင် Hitbox ကို မူလအတိုင်း ပြန်ထားမယ်
                        ApplyHitbox(npc, Vector3.new(2, 2, 1), 1, true)
                    end
                end
            end
        end
    else
        -- Menu မှာ OFF လိုက်တဲ့အခါ အကုန်လုံးကို ပုံမှန်အရွယ်အစား ပြန်ပြောင်းပေးခြင်း
        if targetFolder then
            for _, npc in pairs(targetFolder:GetChildren()) do
                if npc:IsA("Model") then
                    ApplyHitbox(npc, Vector3.new(2, 2, 1), 1, true)
                end
            end
        end
    end
end)

print("Hitbox Script Loaded and Synced with Menu Toggle!")
