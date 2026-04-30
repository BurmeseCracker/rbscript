-- Infinite Yield Style Speed Hack with Toast Notifications
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- Function to create a Toast Message
local function Notify(text)
    local sg = Instance.new("ScreenGui", CoreGui)
    local frame = Instance.new("Frame", sg)
    local label = Instance.new("TextLabel", frame)
    
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(0.5, -100, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Text = text
    label.Font = Enum.Font.SourceSansSemibold
    label.TextSize = 18

    -- Simple Fade Out & Destroy
    task.wait(2)
    for i = 0, 1, 0.1 do
        frame.BackgroundTransparency = i
        label.TextTransparency = i
        task.wait(0.05)
    end
    sg:Destroy()
end

-- Global Setup
_G.SpeedValue = 30 

if _G.SpeedLoop then _G.SpeedLoop:Disconnect() end

-- Initial Notification
if _G["speed"] == true then
    Notify("Speed Hack: ENABLED")
end

_G.SpeedLoop = RunService.Stepped:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if _G["speed"] == true then 
        if hum then
            hum.WalkSpeed = _G.SpeedValue
        end
    else
        -- OFF Logic
        if hum then
            hum.WalkSpeed = 16
        end
        Notify("Speed Hack: DISABLED")
        _G.SpeedLoop:Disconnect()
        _G.SpeedLoop = nil
    end
end)
