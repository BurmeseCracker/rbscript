-- [[ AutoEvasion.lua - GitHub Version with AUTO-AIM ]] --

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Config
local TARGET_NAME = "Bloater" 
local EVADE_DISTANCE = 20 
local TELEPORT_DISTANCE = 25 -- နည်းနည်းလျှော့ထားပေးပါတယ်
local AIM_DISTANCE = 20 -- ဘယ်လောက်အကွာအဝေးထိ Auto-Aim လုပ်မလဲ

-- Function: Highlight (ESP)
local function applyRedHighlight(model)
    local highlight = model:FindFirstChild("BloaterHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "BloaterHighlight"
        highlight.Parent = model
    end
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.4 
    highlight.OutlineTransparency = 0 
end

-- Function: Teleport Logic
local function teleportAway(bloaterPos)
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local direction = (hrp.Position - bloaterPos).Unit
        local newPos = hrp.Position + (direction * TELEPORT_DISTANCE)
        hrp.CFrame = CFrame.new(newPos + Vector3.new(0, 5, 0))
        print("🔴 Evaded Bloater!")
    end
end

-- Function: Auto Aim Logic (Camera ကို Bloater ဆီ လှည့်ပေးခြင်း)
local function autoAim(targetRoot)
    if targetRoot then
        -- Camera ကို Bloater ရဲ့ Position ဆီ ချောချောမွေ့မွေ့ လှည့်ကြည့်ခိုင်းမည်
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
    end
end

-- Main Loop
task.spawn(function()
    print("AutoEvasion + AutoAim Started...")
    
    while _G["AutoEvasion"] do
        local charFolder = Workspace:FindFirstChild("Characters")
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if charFolder and myHrp then
            local closestBloater = nil
            local shortestDist = AIM_DISTANCE

            for _, ent in pairs(charFolder:GetChildren()) do
                if ent:IsA("Model") and ent.Name == TARGET_NAME then
                    applyRedHighlight(ent)

                    local entRoot = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Head")
                    if entRoot then
                        local dist = (myHrp.Position - entRoot.Position).Magnitude
                        
                        -- ၁။ Teleport Logic (အလွန်နီးရင်)
                        if dist < EVADE_DISTANCE then
                            teleportAway(entRoot.Position)
                            task.wait(0.5)
                        end

                        -- ၂။ အနီးဆုံး Bloater ကို ရှာခြင်း (Aim လုပ်ရန်)
                        if dist < shortestDist then
                            shortestDist = dist
                            closestBloater = entRoot
                        end
                    end
                end
            end

            -- ၃။ အနီးဆုံးရှိတဲ့ Bloater ကို Auto-Aim လုပ်မည်
            if closestBloater then
                autoAim(closestBloater)
            end
        end
        task.wait(0.05) -- Aim အတွက် Loop ကို ပိုမြန်မြန်ပတ်ပေးရပါမည်
    end
    
    -- Cleanup
    local charFolder = Workspace:FindFirstChild("Characters")
    if charFolder then
        for _, ent in pairs(charFolder:GetChildren()) do
            local hl = ent:FindFirstChild("BloaterHighlight")
            if hl then hl:Destroy() end
        end
    end
    print("AutoEvasion Stopped.")
end)
