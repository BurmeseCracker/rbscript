local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Config
local MAX_DISTANCE = 100 
local TARGET_NAME = "Fuel"

local activeBeams = {} 

local function createRedPath(model, root)
    if activeBeams[model] then return end
    
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment")
    attP.Parent = root
    
    local attB = Instance.new("Attachment")
    attB.Parent = targetPart
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = attP
    beam.Attachment1 = attB
    
    -- COLOR SET TO BRIGHT RED (RGB: 255, 0, 0)
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) 
    beam.LightEmission = 1
    beam.LightInfluence = 0
    
    beam.Width0, beam.Width1 = 0.35, 0.35 
    beam.Texture = "rbxassetid://44611181" 
    beam.TextureSpeed = 2.5 
    beam.FaceCamera = true
    beam.Parent = root
    
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

local function removePath(model)
    local data = activeBeams[model]
    if data then
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
        activeBeams[model] = nil
    end
end

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Scan for Fuel
    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if item:IsA("Model") and item.Name == TARGET_NAME then
            local dist = (root.Position - item:GetPivot().Position).Magnitude
            
            if dist <= MAX_DISTANCE then
                createRedPath(item, root)
            else
                removePath(item)
            end
        end
    end

    -- Cleanup if collected or despawned
    for model, _ in pairs(activeBeams) do
        if not model:IsDescendantOf(workspace) then
            removePath(model)
        end
    end
end)
