-- [[ update.lua - Announcement Splash (Loader Compatible) ]] --
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Loader အတွက် Global Variable ကို Reset လုပ်ထားမယ်
_G.UpdateClosed = false

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AnnouncementSplash"
screenGui.Parent = CoreGui
screenGui.IgnoreGuiInset = true -- Full screen behavior

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 200)
mainFrame.Position = UDim2.new(0.5, -160, 0.4, -100)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

-- Rounded Corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = mainFrame

-- Top Bar (Header)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Text = "Announcement"
title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Gold
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.Parent = title

-- Content Area
local content = Instance.new("TextLabel")
content.Size = UDim2.new(1, -30, 1, -100)
content.Position = UDim2.new(0, 15, 0, 60)
content.BackgroundTransparency = 1
content.Text = "New Update:\n\n• Fixed Battery TP (Force Loop)\n• Priority Collection (40-200m)\n• Disabled Auto-Jump Feature"
content.TextColor3 = Color3.fromRGB(255, 255, 255)
content.TextSize = 16
content.Font = Enum.Font.GothamMedium
content.TextXAlignment = Enum.TextXAlignment.Left
content.TextYAlignment = Enum.TextYAlignment.Top
content.Parent = mainFrame

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 120, 0, 35)
closeBtn.Position = UDim2.new(0.5, -60, 1, -45)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "Close"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 8)
btnCorner.Parent = closeBtn

-- [[ ANIMATIONS ]] --
mainFrame.BackgroundTransparency = 1
title.BackgroundTransparency = 1
title.TextTransparency = 1
content.TextTransparency = 1
closeBtn.BackgroundTransparency = 1
closeBtn.TextTransparency = 1

local function fadeIn()
    local info = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(mainFrame, info, {BackgroundTransparency = 0}):Play()
    TweenService:Create(title, info, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
    TweenService:Create(content, info, {TextTransparency = 0}):Play()
    TweenService:Create(closeBtn, info, {BackgroundTransparency = 0, TextTransparency = 0}):Play()
end

fadeIn()

-- [[ CLOSE LOGIC ]] --
closeBtn.MouseButton1Click:Connect(function()
    -- ၁။ Loader ကို ဆက်သွားခိုင်းဖို့ Global variable ပေးမယ်
    _G.UpdateClosed = true
    
    -- ၂။ ပျောက်သွားမယ့် Animation
    local info = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
    TweenService:Create(mainFrame, info, {
        Position = UDim2.new(0.5, -160, 0.6, -100),
        BackgroundTransparency = 1
    }):Play()
    TweenService:Create(title, info, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    TweenService:Create(content, info, {TextTransparency = 1}):Play()
    TweenService:Create(closeBtn, info, {BackgroundTransparency = 1, TextTransparency = 1}):Play()
    
    task.wait(0.5)
    screenGui:Destroy()
end)

print("Update GUI: Ready and waiting for user.")
