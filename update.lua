-- [[ update.lua - Announcement Splash ]] --
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ခါတိုင်းထက် ပိုလန်းအောင် UI ကို CoreGui ထဲမှာ ဖန်တီးမယ်
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnnouncementSplash"
screenGui.Parent = CoreGui
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 300, 0, 180)
mainFrame.Position = UDim2.new(0.5, -150, 0.4, -90)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Rounded Corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- Title (Announcement)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Text = "Announcement"
title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold Color
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = title

-- Content (New Update)
local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -20, 1, -80)
content.Position = UDim2.new(0, 10, 0, 50)
content.BackgroundTransparency = 1
content.Text = "New Update:\n\n• Fixed Battery TP Bugs\n• Improved Force Loop\n• Optimized Collection"
content.TextColor3 = Color3.fromRGB(230, 230, 230)
content.TextSize = 16
content.Font = Enum.Font.Gotham
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 80, 0, 30)
closeBtn.Position = UDim2.new(0.5, -40, 1, -40)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = closeBtn

-- Animation (Fade In)
mainFrame.BackgroundTransparency = 1
title.BackgroundTransparency = 1
title.TextTransparency = 1
content.TextTransparency = 1
closeBtn.BackgroundTransparency = 1
closeBtn.TextTransparency = 1

local function fadeIn()
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(mainFrame, info, {BackgroundTransparency = 0}):Play()
    TweenService:Create(title, info, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(content, info, {TextTransparency = 0}):Play()
    TweenService:Create(closeBtn, info, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
end

fadeIn()

-- Close Logic
closeBtn.MouseButton1Click:Connect(function()
    local info = TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(mainFrame, info, {Size = UDim2.new(0, 0, 0, 0), BackgroundTransparency = 1}):Play()
    task.wait(0.4)
    screenGui:Destroy()
end)

print("Update Splash Loaded.")
