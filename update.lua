-- [[ update.lua - Dynamic Announcement Splash ]] --
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- CONFIG: Change this to your raw txt link!
local TEXT_URL = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/update.txt"

-- Loader Variable
_G.UpdateClosed = false

-- Get Update Text from GitHub
local success, updateText = pcall(function()
    return game:HttpGet(TEXT_URL)
end)

if not success or not updateText then
    updateText = "Failed to load update notes.\nPlease check your connection."
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnnouncementSplash"
screenGui.Parent = CoreGui
screenGui.IgnoreGuiInset = true

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 320, 0, 220) -- Slightly taller for more text
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -110)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.Parent = screenGui
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

-- Top Bar
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "What's New?"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

-- Content Area (Now uses the fetched updateText)
local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -30, 1, -100)
content.Position = UDim2.new(0, 15, 0, 60)
content.BackgroundTransparency = 1
content.Text = updateText -- <--- DYNAMIC TEXT HERE
content.TextColor3 = Color3.fromRGB(240, 240, 240)
content.TextSize = 14
content.Font = Enum.Font.GothamMedium
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.TextWrapped = true
content.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 140, 0, 35)
closeBtn.Position = UDim2.new(0.5, -70, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255) -- Blue color for update
closeBtn.Text = "Got it!"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = mainFrame
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

-- Animation Logic
mainFrame.GroupTransparency = 1 -- If you have a CanvasGroup, otherwise fade manually
local function fade(trans)
    local info = TweenInfo.new(0.5)
    TweenService:Create(mainFrame, info, {BackgroundTransparency = trans}):Play()
    TweenService:Create(title, info, {BackgroundTransparency = trans, TextTransparency = trans}):Play()
    TweenService:Create(content, info, {TextTransparency = trans}):Play()
    TweenService:Create(closeBtn, info, {BackgroundTransparency = trans, TextTransparency = trans}):Play()
end

fade(0)

closeBtn.MouseButton1Click:Connect(function()
    _G.UpdateClosed = true
    fade(1)
    task.wait(0.5)
    screenGui:Destroy()
end)
