-- [[ locateBloater_v2.lua - RED HIGHLIGHT & AUTO-EVADE ]] --

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Config
local TARGET_NAME = "Bloater" 
local EVADE_DISTANCE = 20 
local TELEPORT_DISTANCE = 60 -- နည်းနည်းပိုဝေးဝေး ခုန်ပါမယ်

-- Function: Highlight (ESP) ကို အနီရောင်ပြောင်းလဲခြင်း
local function applyRedHighlight(model)
    local highlight = model:FindFirstChild("BloaterHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "BloaterHighlight"
        highlight.Parent = model
    end
    
    -- အနီရောင် တောက်တောက် ဖြစ်အောင် ပြင်ဆင်ခြင်း
    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Pure Red
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0) -- Red Outline (အဖြူမဟုတ်တော့ပါ)
    highlight.FillTransparency = 0.4 -- ပိုလင်းအောင် transparency လျှော့ထားသည်
    highlight.OutlineTransparency = 0 -- အပြင်ဘောင်ကို အပိတ်ထားသည်
end

-- Function: Teleport Logic
local function teleportAway(bloaterPos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        local direction = (hrp.Position - bloaterPos).Unit
        local newPos = hrp.Position + (direction * TELEPORT_DISTANCE)
        
        -- မြေပြင်အထက် ၅ ပေ အမြင့်ကို ပို့ပေးမည် (မညပ်အောင်)
        hrp.CFrame = CFrame.new(newPos + Vector3.new(0, 5, 0))
        print("🔴 Bloater Detected! Teleported to safety.")
    end
end

-- Main Loop
task.spawn(function()
    while true do
        local charFolder = workspace:FindFirstChild("Characters")
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if charFolder then
            for _, ent in pairs(charFolder:GetChildren()) do
                -- Model နာမည်က Bloater ဖြစ်ရင်
                if ent:IsA("Model") and ent.Name == TARGET_NAME then
                    -- ၁။ အနီရောင် Highlight ပြမည်
                    applyRedHighlight(ent)

                    -- ၂။ အကွာအဝေး စစ်ဆေးမည်
                    local entRoot = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Head")
                    if myHrp and entRoot then
                        local dist = (myHrp.Position - entRoot.Position).Magnitude
                        if dist < EVADE_DISTANCE then
                            teleportAway(entRoot.Position)
                            task.wait(1.5) -- Teleport ပြီးရင် ခဏနားမည်
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

print("Red Bloater Tracker Activated!")
