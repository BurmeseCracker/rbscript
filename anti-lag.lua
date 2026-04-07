-- [[ ANTI-LAG INFINITE YIELD EDITION - DRAGGABLE & FIXED ]] --

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- အဟောင်းများကို ရှင်းထုတ်ခြင်း
if _G.AntiLagConnection then _G.AntiLagConnection:Disconnect() end
local oldGui = player.PlayerGui:FindFirstChild("AntiLagGui")
if oldGui then oldGui:Destroy() end

-- [ DRAG LOGIC FUNCTION ]
local function MakeDraggable(UIElement)
    local dragging, dragInput, dragStart, startPos
    UIElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = UIElement.Position
            input.Changed:Connect(function() 
                if input.UserInputState == Enum.UserInputState.End then dragging = false end 
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            UIElement.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- UI ဖန်တီးခြင်း (Lime Green Style)
local function CreateFPSUI()
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "AntiLagGui"
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 130, 0, 55)
    frame.Position = UDim2.new(0, 10, 0, 150)
    frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.Active = true -- Drag လုပ်ဖို့အတွက် လိုအပ်သည်
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    -- ရွှေ့လို့ရအောင် လုပ်ခြင်း
    MakeDraggable(frame)

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

-- [[ OPTIMIZATION FUNCTION ]] --
local function optimizeGame()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 1
    
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
        elseif v:IsA("Decal") or v:IsA("Texture") then
            v.Transparency = 1
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Enabled = false
        end
    end
end

local lastTime = tick()
local currentGui, fl, pl

-- Main Loop
_G.AntiLagConnection = RunService.RenderStepped:Connect(function()
    -- Menu ရဲ့ _G["anti-lag"] variable ကို စစ်ဆေးခြင်း
    if _G["anti-lag"] == true then
        -- UI မရှိသေးရင် အသစ်ဆောက်မယ်
        if not player.PlayerGui:FindFirstChild("AntiLagGui") then
            currentGui, fl, pl = CreateFPSUI()
            optimizeGame()
        end
        
        -- Update Stats
        local currentTime = tick()
        local fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        
        if fl and pl then
            fl.Text = "FPS: " .. fps
            pl.Text = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
        end

        settings().Rendering.QualityLevel = 1
    else
        -- _G["anti-lag"] က false ဖြစ်သွားရင် (Menu ကနေ ပိတ်လိုက်ရင်)
        local existingGui = player.PlayerGui:FindFirstChild("AntiLagGui")
        if existingGui then
            existingGui:Destroy() -- UI ကို ဖျက်မယ်
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = 0
            print("Anti-Lag Disabled & UI Removed.")
        end
    end
end)

print("Anti-Lag with Draggable FPS Loaded!")
