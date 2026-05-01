-- [[ Smooth Bypass Speed Hack + Toast Notifications ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer

-- CONFIG
_G.SpeedValue = 30 -- Adjust this (0.1 to 0.8 is the "Safe Zone" for bypass)
local scriptID = "speed"

-- Function to create a Toast Message
local function Notify(text)
    local sg = Instance.new("ScreenGui", CoreGui)
    local frame = Instance.new("Frame", sg)
    local label = Instance.new("TextLabel", frame)
    
    frame.Size = UDim2.new(0, 220, 0, 40)
    frame.Position = UDim2.new(0.5, -110, 0.8, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = ToolNumber.new(0, 8)
    
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(0, 255, 150) -- Greenish glow
    label.Text = text
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 16

    task.spawn(function()
        task.wait(2)
        for i = 0, 1, 0.1 do
            frame.BackgroundTransparency = i
            label.TextTransparency = i
            task.wait(0.03)
        end
        sg:Destroy()
    end)
end

-- Cleanup old loop
if _G.SpeedLoop then _G.SpeedLoop:Disconnect() end

-- Initial Toggle Check
if _G[scriptID] == true then
    Notify("BYPASS SPEED: ENABLED")
end

_G.SpeedLoop = RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if _G[scriptID] == true then
        -- BYPASS LOGIC: We move the CFrame directly based on MoveDirection
        -- This does NOT change WalkSpeed, so anti-cheats don't flag the property
        if root and hum and hum.MoveDirection.Magnitude > 0 then
            root.CFrame = root.CFrame + (hum.MoveDirection * _G.SpeedValue)
        end
    else
        -- Cleanup and Notify when turned OFF
        Notify("BYPASS SPEED: DISABLED")
        if _G.SpeedLoop then
            _G.SpeedLoop:Disconnect()
            _G.SpeedLoop = nil
        end
    end
end)
