-- [[ anti-lag.lua - LIME TEXT & TRANSPARENT BLACK BG ]] --

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- အဟောင်းတွေကို ရှင်းထုတ်ခြင်း
if _G.AntiLagConnection then _G.AntiLagConnection:Disconnect() end
local oldGui = player.PlayerGui:FindFirstChild("AntiLagGui")
if oldGui then oldGui:Destroy() end

-- UI ဖန်တီးသည့် Function (Custom Colors)
local function CreateFPSUI()
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "AntiLagGui"
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 120, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0) -- Black Background
    frame.BackgroundTransparency = 0.5 -- Transparent
    frame.Active = true
    frame.Draggable = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local fpsLabel = Instance.new("TextLabel", frame)
    fpsLabel.Name = "FPSLabel"
    fpsLabel.Size = UDim2.new(1, -10, 0.5, 0)
    fpsLabel.Position = UDim2.new(0, 10, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Lime Green
    fpsLabel.TextSize = 16
    fpsLabel.Font = Enum.Font.Code
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left
    fpsLabel.Text = "FPS: ..."

    local pingLabel = Instance.new("TextLabel", frame)
    pingLabel.Name = "PingLabel"
    pingLabel.Size = UDim2.new(1, -10, 0.5, 0)
    pingLabel.Position = UDim2.new(0, 10, 0.5, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Lime Green
    pingLabel.TextSize = 16
    pingLabel.Font = Enum.Font.Code
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left
    pingLabel.Text = "Ping: ..."
    
    return gui
end

-- Main Monitoring Loop
local lastTime = tick()
_G.AntiLagConnection = RunService.RenderStepped:Connect(function()
    local gui = player.PlayerGui:FindFirstChild("AntiLagGui")
    
    if _G["anti-lag"] == true then
        -- [ ON Mode ]
        if not gui then
            gui = CreateFPSUI()
        end
        
        -- Update Stats
        local currentTime = tick()
        local fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        
        local frame = gui:FindFirstChild("Frame")
        if frame then
            frame.FPSLabel.Text = "FPS: " .. fps
            frame.PingLabel.Text = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
        end
        
        -- Optimization Settings
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = 0
        settings().Rendering.QualityLevel = 1
        Lighting.GlobalShadows = false
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                v.Enabled = false
            end
        end
    else
        -- [ OFF Mode ]
        if gui then
            gui:Destroy()
        end
        
        -- Reset to Original Settings
        settings().Physics.AllowSleep = false
        settings().Physics.PhysicsEnvironmentalThrottle = 1
        settings().Rendering.QualityLevel = 0
        Lighting.GlobalShadows = true
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
                v.Enabled = true
            end
        end
    end
end)

print("Anti-Lag System Loaded with Lime UI!")

