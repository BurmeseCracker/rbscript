-- [[ ERROR FIXED + MAX PHYSICS SLEEP SCRIPT ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

------------------------------------------
-- ၁။ PERFORMANCE UI (FPS & PING)
------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PerfStatsGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 140, 0, 50)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BackgroundTransparency = 0.4
frame.Active = true
frame.Draggable = true
frame.Parent = ScreenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 6)
uiCorner.Parent = frame

local fpsLabel = Instance.new("TextLabel")
fpsLabel.Size = UDim2.new(1, -10, 0, 22)
fpsLabel.Position = UDim2.new(0, 10, 0, 3)
fpsLabel.BackgroundTransparency = 1
fpsLabel.TextColor3 = Color3.new(1, 1, 1)
fpsLabel.TextSize = 15
fpsLabel.Font = Enum.Font.Code
fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
fpsLabel.Text = "FPS: ..."
fpsLabel.Parent = frame

local pingLabel = Instance.new("TextLabel")
pingLabel.Size = UDim2.new(1, -10, 0, 22)
pingLabel.Position = UDim2.new(0, 10, 0, 23)
pingLabel.BackgroundTransparency = 1
pingLabel.TextColor3 = Color3.new(1, 1, 1)
pingLabel.TextSize = 15
pingLabel.Font = Enum.Font.Code
pingLabel.TextXAlignment = Enum.TextXAlignment.Left
pingLabel.Text = "Ping: ..."
pingLabel.Parent = frame

-- UI Update Loop
local lastTime = tick()
RunService.RenderStepped:Connect(function()
    local currentTime = tick()
    local fps = math.floor(1 / (currentTime - lastTime))
    lastTime = currentTime
    fpsLabel.Text = "FPS: " .. fps
    
    local ping = math.floor(player:GetNetworkPing() * 1000)
    pingLabel.Text = "Ping: " .. ping .. " ms"
    
    fpsLabel.TextColor3 = (fps < 30) and Color3.new(1, 0.4, 0.4) or Color3.new(0.5, 1, 0.5)
    pingLabel.TextColor3 = (ping > 200) and Color3.new(1, 0.4, 0.4) or Color3.new(0.5, 1, 0.5)
end)

------------------------------------------
-- ၂။ PHYSICS & PERFORMANCE (ERROR FIXED)
------------------------------------------

-- Physics Engine ကို အတင်းအိပ်ခိုင်းခြင်း (Force Sleep)
settings().Physics.AllowSleep = true
-- Error မတက်စေရန် Numeric Value (Default = 0) ကို သုံးထားသည်
settings().Physics.PhysicsEnvironmentalThrottle = 0 

-- Rendering Quality ကို အနိမ့်ဆုံးသို့ ညှိခြင်း
settings().Rendering.QualityLevel = 1

-- ၃။ VISUAL OPTIMIZATION
Lighting.GlobalShadows = false

for _, effect in pairs(Lighting:GetChildren()) do
    if effect:IsA("PostProcessEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
        effect.Enabled = false
    end
end

-- ၄။ SMART CLEANUP (အသုံးမလိုသော အဝေးကပစ္စည်းများ ရှင်းထုတ်ခြင်း)
local function megaClean()
    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("BasePart") and not v.Anchored then
            if not v:IsDescendantOf(player.Character) and v.Size.Magnitude < 1.2 then
                v:Destroy()
            end
        end
    end
end

task.spawn(function()
    while true do
        megaClean()
        task.wait(60) -- ၁ မိနစ်တစ်ခါ Clean လုပ်မည်
    end
end)

print("All Errors Fixed! Physics Sleep Enabled.")
