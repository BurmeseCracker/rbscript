-- [[ anti-lag.lua - FULL VERSION (WITH FPS/PING + TOGGLE) ]] --

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

------------------------------------------
-- ၁။ Button ON ဖြစ်တဲ့အခါ (Activated)
------------------------------------------
if _G["anti-lag"] == true then
    -- [ UI ဖန်တီးခြင်း ]
    if not player.PlayerGui:FindFirstChild("AntiLagGui") then
        local ScreenGui = Instance.new("ScreenGui", player.PlayerGui)
        ScreenGui.Name = "AntiLagGui"
        
        local frame = Instance.new("Frame", ScreenGui)
        frame.Size = UDim2.new(0, 140, 0, 50)
        frame.Position = UDim2.new(0, 10, 0, 150) -- Menu နဲ့ မလွတ်အောင် နေရာချထားသည်
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 0.5
        frame.Active = true
        frame.Draggable = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local fpsLabel = Instance.new("TextLabel", frame)
        fpsLabel.Name = "FPS"
        fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.TextColor3 = Color3.new(1, 1, 1)
        fpsLabel.TextSize = 14
        fpsLabel.Font = Enum.Font.Code

        local pingLabel = Instance.new("TextLabel", frame)
        pingLabel.Name = "Ping"
        pingLabel.Size = UDim2.new(1, 0, 0.5, 0)
        pingLabel.Position = UDim2.new(0, 0, 0.5, 0)
        pingLabel.BackgroundTransparency = 1
        pingLabel.TextColor3 = Color3.new(1, 1, 1)
        pingLabel.TextSize = 14
        pingLabel.Font = Enum.Font.Code

        -- FPS/Ping Update Loop
        local lastTime = tick()
        _G.StatsLoop = RunService.RenderStepped:Connect(function()
            local currentTime = tick()
            local fps = math.floor(1 / (currentTime - lastTime))
            lastTime = currentTime
            fpsLabel.Text = "FPS: " .. fps
            pingLabel.Text = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
        end)
    end

    -- [ Anti-Lag Settings ]
    settings().Physics.AllowSleep = true
    settings().Physics.PhysicsEnvironmentalThrottle = 0
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
            v.Enabled = false
        end
    end
    print("Anti-lag & FPS: ON")

------------------------------------------
-- ၂။ Button OFF ဖြစ်တဲ့အခါ (Deactivated)
------------------------------------------
else
    -- [ UI ဖျက်သိမ်းခြင်း ]
    local gui = player.PlayerGui:FindFirstChild("AntiLagGui")
    if gui then gui:Destroy() end
    
    if _G.StatsLoop then 
        _G.StatsLoop:Disconnect() 
        _G.StatsLoop = nil 
    end

    -- [ Settings များ မူလအတိုင်း ပြန်ထားခြင်း ]
    settings().Physics.AllowSleep = false
    settings().Physics.PhysicsEnvironmentalThrottle = 1
    settings().Rendering.QualityLevel = 0
    Lighting.GlobalShadows = true

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
            v.Enabled = true
        end
    end
    print("Anti-lag & FPS: OFF")
end
