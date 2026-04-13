-- [[ update.lua - Fixed Template ]] --
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local TXT_URL = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/update.txt"

-- Fetch Update Text
local success, note = pcall(function() return game:HttpGet(TXT_URL) end)
local updateText = success and note or "• Fix Bugs\n• Improved Performance"

-- UI Setup
local sg = Instance.new("ScreenGui", CoreGui)
sg.IgnoreGuiInset = true

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 320, 0, 280)
main.Position = UDim2.new(0.5, -160, 0.5, -140)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
title.Text = "UPDATE LOGS"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 15)

local content = Instance.new("TextLabel", main)
content.Size = UDim2.new(1, -30, 0, 130)
content.Position = UDim2.new(0, 15, 0, 65)
content.BackgroundTransparency = 1
content.Text = updateText
content.TextColor3 = Color3.new(1, 1, 1)
content.TextSize = 16
content.Font = Enum.Font.GothamMedium
content.TextWrapped = true
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top

local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0, 240, 0, 55) -- BIG BUTTON
btn.Position = UDim2.new(0.5, -120, 1, -75)
btn.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
btn.Text = "GOT IT!"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 22
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

-- [[ THE FIX ]] --
btn.MouseButton1Click:Connect(function()
    print("Signaling Loader...")
    _G.UpdateClosed = true -- Sends signal to Loader script
    
    -- Animation Out
    local tween = TweenService:Create(main, TweenInfo.new(0.4), {
        Position = UDim2.new(0.5, -160, 0.6, -140),
        BackgroundTransparency = 1
    })
    tween:Play()
    
    task.wait(0.4)
    sg:Destroy()
end)
