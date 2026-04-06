-- [[ anti-lag.lua - FIXED DISABLE & FPS ]] --

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- အရင်ရှိနေတဲ့ Stats Loop ဟောင်းကို ဖြတ်မယ် (ထပ်မနေအောင်)
if _G.StatsLoop then 
    _G.StatsLoop:Disconnect() 
    _G.StatsLoop = nil 
end

------------------------------------------
-- ၁။ Button ON ဖြစ်တဲ့အခါ (Activate)
------------------------------------------
if _G["anti-lag"] == true then
    
    -- FPS/Ping UI မရှိသေးရင် ဆောက်မယ်
    local gui = player.PlayerGui:FindFirstChild("AntiLagGui")
    if not gui then
        gui = Instance.new("ScreenGui", player.PlayerGui)
        gui.Name = "AntiLagGui"
        
        local frame = Instance.new("Frame", gui)
        frame.Size = UDim2.new(0, 140, 0, 50)
        frame.Position = UDim2.new(0, 10, 0, 150)
        frame.BackgroundColor3 = Color3.new(0, 0, 0)
        frame.BackgroundTransparency = 0.5
        frame.Active = true
        frame.Draggable = true
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

        local fpsLabel = Instance.new("TextLabel", frame)
        fpsLabel.Size = UDim2.new(1, 0, 0.5, 0)
        fpsLabel.BackgroundTransparency = 1
        fpsLabel.TextColor3 = Color3.new(1, 1, 1)
        fpsLabel.Text = "FPS: ..."
        fpsLabel.Parent = frame

        local pingLabel = Instance.new("TextLabel", frame)
        pingLabel.Size = UDim2.new(1, 0, 0.5, 0)
        pingLabel.Position = UDim2.new(0, 0, 0.5, 0)
        pingLabel.BackgroundTransparency = 1
        pingLabel.TextColor3 = Color3.new(1, 1, 1)
        pingLabel.Text = "Ping: ..."
        pingLabel.Parent = frame

        -- Stats Update Loop
        local lastTime = tick()
        _G.StatsLoop = RunService.RenderStepped:Connect(function()
            -- Button OFF သွားရင် Loop ကိုပါ သတ်ပစ်မယ်
            if _G["anti-lag"] ~= true then
                if _G.StatsLoop then _G.StatsLoop:Disconnect() end
                return
            end
            
            local currentTime = tick()
            local fps = math.floor(1 / (currentTime - lastTime))
            lastTime = currentTime
            fpsLabel.Text = "FPS: " .. fps
            pingLabel.Text = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
        end)
    end

    -- Anti-Lag Settings ON မယ်
    settings().Physics.AllowSleep = true
    settings().Physics.PhysicsEnvironmentalThrottle = 0
    settings().Rendering.QualityLevel = 1
    Lighting.GlobalShadows = false

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
            v.Enabled = false
        end
    end
    print("Anti-lag: ON")

------------------------------------------
-- ၂။ Button OFF ဖြစ်တဲ့အခါ (Disable)
------------------------------------------
else
    -- UI ကို ဖျက်မယ်
    local gui = player.PlayerGui:FindFirstChild("AntiLagGui")
    if gui then gui:Destroy() end
    
    -- Loop ကို ရပ်မယ်
    if _G.StatsLoop then 
        _G.StatsLoop:Disconnect() 
        _G.StatsLoop = nil 
    end

    -- Settings တွေကို Original အတိုင်း ပြန်ပြင်မယ်
    settings().Physics.AllowSleep = false
    settings().Physics.PhysicsEnvironmentalThrottle = 1
    settings().Rendering.QualityLevel = 0 -- Auto
    Lighting.GlobalShadows = true

    for _, v in pairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") then
            v.Enabled = true
        end
    end
    print("Anti-lag: OFF & Disabled")
end

