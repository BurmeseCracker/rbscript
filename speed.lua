-- [[ Smooth Bypass Speed Hack - Total Speed 30 ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- CONFIG
-- 0.235 added to base 16 equals approximately 30 total speed
_G.SpeedValue = 0.235 
local scriptID = "speed"

local function Notify(text)
    local sg = Instance.new("ScreenGui", CoreGui)
    local frame = Instance.new("Frame", sg)
    local label = Instance.new("TextLabel", frame)
    
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(0.5, -110, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)
    
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 200, 255)
    label.Text = text
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16

    task.spawn(function()
        task.wait(2.5)
        for i = 0, 1, 0.1 do
            frame.BackgroundTransparency = i
            label.TextTransparency = i
            task.wait(0.02)
        end
        sg:Destroy()
    end)
end

if _G.SpeedLoop then _G.SpeedLoop:Disconnect() end

if _G[scriptID] == true then
    Notify("SPEED 30 BYPASS: ENABLED")
end

_G.SpeedLoop = RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if _G[scriptID] == true then
        -- We keep Humanoid.WalkSpeed at 16 (default)
        -- We add the extra distance manually to reach 30
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * _G.SpeedValue)
        end
    else
        Notify("SPEED 30 BYPASS: DISABLED")
        if _G.SpeedLoop then
            _G.SpeedLoop:Disconnect()
            _G.SpeedLoop = nil
        end
    end
end)
