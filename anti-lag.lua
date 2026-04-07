-- [[ ANTI-LAG INFINITE YIELD EDITION - LIME TEXT & OPTIMIZER ]] --

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- အဟောင်းများကို ရှင်းထုတ်ခြင်း
if _G.AntiLagConnection then _G.AntiLagConnection:Disconnect() end
local oldGui = player.PlayerGui:FindFirstChild("AntiLagGui")
if oldGui then oldGui:Destroy() end

-- UI ဖန်တီးခြင်း (Lime Green Style)
local function CreateFPSUI()
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "AntiLagGui"
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 130, 0, 55)
    frame.Position = UDim2.new(0, 10, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    local fpsLabel = Instance.new("TextLabel", frame)
    fpsLabel.Size = UDim2.new(1, -10, 0.5, 0)
    fpsLabel.Position = UDim2.new(0, 10, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Lime
    fpsLabel.Font = Enum.Font.Code
    fpsLabel.TextSize = 15
    fpsLabel.TextXAlignment = Enum.TextXAlignment.Left

    local pingLabel = Instance.new("TextLabel", frame)
    pingLabel.Size = UDim2.new(1, -10, 0.5, 0)
    pingLabel.Position = UDim2.new(0, 10, 0.5, 0)
    pingLabel.BackgroundTransparency = 1
    pingLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Lime
    pingLabel.Font = Enum.Font.Code
    pingLabel.TextSize = 15
    pingLabel.TextXAlignment = Enum.TextXAlignment.Left

    return gui, fpsLabel, pingLabel
end

local lastTime = tick()
local gui, fl, pl

-- [[ OPTIMIZATION FUNCTION (The Infinite Yield Way) ]] --
local function optimizeGame()
    -- ၁။ Lighting & Effects ကို အနိမ့်ဆုံးချခြင်း
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end

    -- ၂။ Map အတွင်းရှိ Texture နှင့် Particle များကို ရှင်းထုတ်ခြင်း
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        elseif v:IsA("Explosion") then
            v.Visible = false
        end
    end
    
    -- ၃။ Fog Cleaner
    local fogFolder = workspace:FindFirstChild("Fog")
    if fogFolder then fogFolder:ClearAllChildren() end
end

-- Main Loop
_G.AntiLagConnection = RunService.RenderStepped:Connect(function()
    if _G["anti-lag"] == true then
        if not player.PlayerGui:FindFirstChild("AntiLagGui") then
            gui, fl, pl = CreateFPSUI()
            optimizeGame() -- ON လိုက်တာနဲ့ တစ်ခါတည်း ရှင်းထုတ်မည်
        end
        
        -- Update Stats
        local currentTime = tick()
        local fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        if fl then fl.Text = "FPS: " .. fps end
        if pl then pl.Text = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms" end

        -- Low Graphics Settings (Constant Apply)
        settings().Rendering.QualityLevel = 1
    else
        if player.PlayerGui:FindFirstChild("AntiLagGui") then
            player.PlayerGui.AntiLagGui:Destroy()
            -- Reset Settings (မူလအတိုင်းပြန်ထားရန်)
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = 0
        end
    end
end)

print("Infinite Yield Style Anti-Lag Loaded!")
