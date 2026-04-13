-- [[ Full Auto Kill Aura - Swing + HitTargets ]] --
local RunService = game:GetService("RunService")
local player = game:GetService("Players").LocalPlayer

-- CONFIGURATION
local KILL_RANGE = 50 -- ၂၀ ပေအတွင်း အကုန်သေမယ်
local ATTACK_SPEED = 0.8 -- တိုက်ခိုက်မယ့်အမြန်နှုန်း (စက္ကန့်)

local lastAttack = 0

RunService.Heartbeat:Connect(function()
    -- Attack Speed အတွက် ခဏစောင့်မယ် (Anti-Cheat ကန်ထုတ်တာမျိုးမဖြစ်အောင်)
    if tick() - lastAttack < ATTACK_SPEED then return end
    
    local char = player.Character
    if not char then return end
    
    -- လက်ထဲမှာ Bat ရှိမရှိ စစ်မယ်
    local bat = char:FindFirstChild("Bat")
    if not bat then return end
    
    local swingRemote = bat:FindFirstChild("Swing")
    local hitRemote = bat:FindFirstChild("HitTargets")
    local charactersFolder = workspace:FindFirstChild("Characters")
    
    if not (swingRemote and hitRemote and charactersFolder) then return end

    local targetFound = false

    -- အနားက Zombie တွေကို ရှာမယ်
    for _, zombie in pairs(charactersFolder:GetChildren()) do
        if zombie:IsA("Model") and zombie ~= char then
            local root = zombie:FindFirstChild("HumanoidRootPart")
            local hum = zombie:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local dist = (char.HumanoidRootPart.Position - root.Position).Magnitude
                
                -- ၂၀ ပေအတွင်းရှိရင်
                if dist <= KILL_RANGE then
                    targetFound = true
                    
                    -- ၁။ Hit Signal ပို့မယ်
                    local args = {{ zombie }}
                    hitRemote:FireServer(unpack(args))
                end
            end
        end
    end
    
    -- တကယ်လို့ အနားမှာ Zombie ရှိရင် Swing (ဝှေ့ယမ်းတာ) ကို တစ်ခါတည်းလုပ်မယ်
    if targetFound then
        swingRemote:FireServer()
        lastAttack = tick()
    end
end)

print("Full Auto Aura: ACTIVE. Just equip your Bat and stand near zombies!")
