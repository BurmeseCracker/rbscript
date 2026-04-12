-- [[ ANTI-LAG INFINITE YIELD EDITION - FORCE DELETE ]] --

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- [[ AGGRESSIVE DELETION ]] --
-- This function will keep looking for the folders until it finds and deletes them
local function forceDelete(parent, name)
    task.spawn(function()
        while true do
            local target = parent:FindFirstChild(name)
            if target then
                pcall(function() target:Destroy() end)
                print(name .. " has been force deleted.")
                break
            end
            task.wait(1) -- Check every second until it exists to delete it
        end
    end)
end

-- Force delete the specific targets
forceDelete(workspace, "Fog")
forceDelete(RS:WaitForChild("Assets"), "Cutscenes")

-- Handle Modules > VFX folder
task.spawn(function()
    local modules = RS:WaitForChild("Modules")
    local vfx = modules:WaitForChild("VFX")
    if vfx then
        local shake = vfx:FindFirstChild("Shake")
        local effects = vfx:FindFirstChild("ScreenEffects")
        if shake then shake:Destroy() end
        if effects then effects:Destroy() end
    end
end)

-- Cleanup old instances
if _G.AntiLagConnection then _G.AntiLagConnection:Disconnect() end
local oldGui = player.PlayerGui:FindFirstChild("AntiLagGui")
if oldGui then oldGui:Destroy() end

-- [ DRAG LOGIC ]
local function MakeDraggable(UIElement)
    local dragging, dragStart, startPos
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

-- [ UI CREATION ]
local function CreateFPSUI()
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "AntiLagGui"
    gui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 130, 0, 55)
    frame.Position = UDim2.new(0, 10, 0, 150)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.4
    frame.Active = true
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

    MakeDraggable(frame)

    local function createLabel(pos)
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -10, 0.5, 0)
        lbl.Position = pos
        lbl.BackgroundTransparency = 1
        lbl.TextColor3 = Color3.new(0, 1, 0)
        lbl.Font = Enum.Font.Code
        lbl.TextSize = 15
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        return lbl
    end

    return gui, createLabel(UDim2.new(0, 10, 0, 0)), createLabel(UDim2.new(0, 10, 0.5, 0))
end

-- [[ OPTIMIZATION FUNCTION ]] --
local function optimizeGame()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostProcessEffect") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("SunRaysEffect") then
            v.Enabled = false
        end
    end

    for _, v in ipairs(workspace:GetDescendants()) do
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
local fl, pl

-- [[ MAIN LOOP ]] --
_G.AntiLagConnection = RunService.RenderStepped:Connect(function()
    if _G["anti-lag"] == true then
        if not player.PlayerGui:FindFirstChild("AntiLagGui") then
            local gui
            gui, fl, pl = CreateFPSUI()
            optimizeGame()
            settings().Rendering.QualityLevel = 1
        end
        
        local currentTime = tick()
        local fps = math.floor(1 / (currentTime - lastTime))
        lastTime = currentTime
        
        if fl and pl then
            fl.Text = "FPS: " .. fps
            pl.Text = "Ping: " .. math.floor(player:GetNetworkPing() * 1000) .. "ms"
        end
    else
        local existingGui = player.PlayerGui:FindFirstChild("AntiLagGui")
        if existingGui then
            existingGui:Destroy()
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = 0
        end
    end
end)

print("Anti-Lag Optimized & Loaded!")
