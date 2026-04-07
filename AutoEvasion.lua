-- [[ AutoAim_ESP.lua - Bloater Tracker ]] --

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Config
local TARGET_NAME = "Bloater" 
local AIM_DISTANCE = 100 -- ဘယ်လောက်အကွာအဝေးအထိ လှည့်ကြည့်မလဲ (Distance တိုးထားပေးပါတယ်)

-- Function: Highlight (ESP)
local function applyRedHighlight(model)
    local highlight = model:FindFirstChild("BloaterHighlight")
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = "BloaterHighlight"
        highlight.Parent = model
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
        highlight.FillTransparency = 0.4 
        highlight.OutlineTransparency = 0 
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
    print("ESP + AutoAim Started (Teleport Disabled)...")
    
    _G.AutoAimActive = true -- Loop ကို ထိန်းချုပ်ရန် Variable
    
    while _G.AutoAimActive do
        local charFolder = Workspace:FindFirstChild("Characters")
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if charFolder and myHrp then
            local closestBloater = nil
            local shortestDist = AIM_DISTANCE

            for _, ent in pairs(charFolder:GetChildren()) do
                if ent:IsA("Model") and ent.Name == TARGET_NAME then
                    -- ၁။ ESP ပြပေးခြင်း
                    applyRedHighlight(ent)

                    local entRoot = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Head")
                    if entRoot then
                        local dist = (myHrp.Position - entRoot.Position).Magnitude
                        
                        -- ၂။ အနီးဆုံး Bloater ကို ရှာခြင်း (Aim လုပ်ရန်)
                        if dist < shortestDist then
                            shortestDist = dist
                            closestBloater = entRoot
                        end
                    end
                end
            end

            -- ၃။ အနီးဆုံးရှိတဲ့ Bloater ကို Camera နဲ့ Auto-Aim လုပ်မည်
            if closestBloater then
                autoAim(closestBloater)
            end
        end
        task.wait(0.01) -- ပိုပြီး Smooth ဖြစ်အောင် Loop speed ကို မြှင့်ထားပါတယ်
    end
    
    -- Cleanup (ပိတ်လိုက်တဲ့အခါ Highlight တွေ ရှင်းထုတ်ရန်)
    local charFolder = Workspace:FindFirstChild("Characters")
    if charFolder then
        for _, ent in pairs(charFolder:GetChildren()) do
            local hl = ent:FindFirstChild("BloaterHighlight")
            if hl then hl:Destroy() end
        end
    end
    print("AutoAim & ESP Stopped.")
end)

