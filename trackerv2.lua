local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("Structures")

-- Config
local MAX_DISTANCE = 100 
local TARGET_NAME = "Scrap Pile"

local activeBeams = {} 

local function createGoldenPath(model, root)
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
    
    -- COLOR UPDATED TO CYAN
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)) 
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
        data.beam:Destroy()
        data.aP:Destroy()
        data.aB:Destroy()
        activeBeams[model] = nil
    end
end

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if item:IsA("Model") and item.Name == TARGET_NAME then
            local dist = (root.Position - item:GetPivot().Position).Magnitude
            
            if dist <= MAX_DISTANCE then
                createGoldenPath(item, root)
            else
                removePath(item)
            end
        end
    end

    for model, _ in pairs(activeBeams) do
        if not model:IsDescendantOf(workspace) then
            removePath(model)
        end
    end
end)

