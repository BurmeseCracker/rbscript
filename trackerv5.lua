local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local CRATE_FOLDER = workspace:WaitForChild("Map"):WaitForChild("Crates")

-- Config
local MAX_DISTANCE = 500 -- Long range
local PURPLE_COLOR = Color3.fromRGB(170, 0, 255) -- Bright Purple
local activeBeams = {}

-- Function to create the Purple Path
local function createPurplePath(model, root)
    if activeBeams[model] then return end
    
    -- Target the MainPart specifically as you requested
    local targetPart = model:FindFirstChild("MainPart")
    if not targetPart then return end

    -- 1. Create Attachments
    local attPlayer = Instance.new("Attachment", root)
    local attCrate = Instance.new("Attachment", targetPart)
    
    -- 2. Create the Beam
    local beam = Instance.new("Beam")
    beam.Attachment0 = attPlayer
    beam.Attachment1 = attCrate
    
    -- Appearance
    beam.Color = ColorSequence.new(PURPLE_COLOR)
    beam.Width0, beam.Width1 = 0.4, 0.4
    beam.Texture = "rbxassetid://44611181" -- Dotted/Shimmer line
    beam.TextureSpeed = 2.5
    beam.FaceCamera = true
    beam.Parent = root
    
    activeBeams[model] = {beam = beam, aP = attPlayer, aB = attCrate}
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

-- The Scanner Loop
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or not CRATE_FOLDER then return end

    -- Scan the Crates Folder
    for _, crate in pairs(CRATE_FOLDER:GetChildren()) do
        -- Safety check for position
        local success, pos = pcall(function() return crate:GetPivot().Position end)
        if not success then continue end
        
        local dist = (root.Position - pos).Magnitude
        
        -- If it has a MainPart and is within distance
        if dist <= MAX_DISTANCE and crate:FindFirstChild("MainPart") then
            createPurplePath(crate, root)
        else
            removePath(crate)
        end
    end

    -- Cleanup for deleted or looted crates
    for model, _ in pairs(activeBeams) do
        if not model:IsDescendantOf(workspace) then
            removePath(model)
        end
    end
end)
