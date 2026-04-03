local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Config
local MAX_DISTANCE = 200 -- Distance the "Gold Path" appears
local TARGET_NAME = "Battery"

local activeBeams = {} -- Keeps track of active paths

-- Function to create the Golden Path
local function createGoldenPath(model, root)
    if activeBeams[model] then return end
    
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    -- Create Attachments
    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    
    -- Create the Beam
    local beam = Instance.new("Beam")
    beam.Attachment0 = attP
    beam.Attachment1 = attB
    
    -- BRIGHT GOLD COLOR (RGB: 255, 215, 0)
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) 
    
    beam.Width0, beam.Width1 = 0.35, 0.35 -- Slightly thicker for visibility
    beam.Texture = "rbxassetid://44611181" -- Dotted line
    beam.TextureSpeed = 2.5 -- Faster "shimmer" effect
    beam.FaceCamera = true
    beam.Parent = root
    
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

-- Function to remove the path
local function removePath(model)
    local data = activeBeams[model]
    if data then
        data.beam:Destroy()
        data.aP:Destroy()
        data.aB:Destroy()
        activeBeams[model] = nil
    end
end

-- The "Scanner" Loop
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Scan for any Battery Models
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

    -- Cleanup if the battery is collected or deleted
    for model, _ in pairs(activeBeams) do
        if not model:IsDescendantOf(workspace) then
            removePath(model)
        end
    end
end)
