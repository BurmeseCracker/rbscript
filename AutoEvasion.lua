-- [[ AutoAim_Hold_ESP.lua ]] --

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Config
local TARGET_NAME = "Bloater" 
local AIM_DISTANCE = 50
local isAiming = false -- Aim လုပ်နေသလား စစ်ရန်

-- Mouse ညာဘက်ခလုတ် ဖိထားခြင်း ရှိ/မရှိ စစ်ဆေးခြင်း
UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = true -- ညာဘက်ခလုတ် ဖိထားလျှင် Aim မည်
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        isAiming = false -- လွှတ်လိုက်လျှင် Free Cam ပြန်ဖြစ်မည်
    end
end)

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

-- Function: Auto Aim Logic
local function autoAim(targetRoot)
    if targetRoot and isAiming then
        -- ညာဘက်ခလုတ် ဖိထားမှသာ Camera ကို လှည့်မည်
        local targetPos = camera:WorldToViewportPoint(targetRoot.Position)
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position)
    end
end

-- Main Loop
task.spawn(function()
    print("Hold Right-Click to Aim + ESP Started...")
    _G.AutoAimActive = true
    
    while _G.AutoAimActive do
        local charFolder = Workspace:FindFirstChild("Characters")
        local myChar = player.Character
        local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

        if charFolder and myHrp then
            local closestBloater = nil
            local shortestDist = AIM_DISTANCE

            for _, ent in pairs(charFolder:GetChildren()) do
                if ent:IsA("Model") and ent.Name == TARGET_NAME then
                    applyRedHighlight(ent) -- ESP ကတော့ အမြဲပြနေမည်

                    local entRoot = ent:FindFirstChild("HumanoidRootPart") or ent:FindFirstChild("Head")
                    if entRoot then
                        local dist = (myHrp.Position - entRoot.Position).Magnitude
                        if dist < shortestDist then
                            shortestDist = dist
                            closestBloater = entRoot
                        end
                    end
                end
            end

            -- ညာဘက်ခလုတ် ဖိထားမှသာ Aim ခိုင်းမည်
            if closestBloater and isAiming then
                autoAim(closestBloater)
            end
        end
        task.wait(0.01)
    end
end)
