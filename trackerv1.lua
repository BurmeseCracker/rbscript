-- GitHub Script: trackerv1.lua
local scriptID = "trackerv1" 

-- Wait for the Menu Toggle
repeat task.wait(0.1) until _G[scriptID] == true

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Config
local MAX_DISTANCE = 500 
local TARGET_NAME = "Battery"
local v1Beams = {} -- Unique table for this script

local function removeV1Path(model)
    local data = v1Beams[model]
    if data then
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
        v1Beams[model] = nil
    end
end

local function createV1Path(model, root)
    if v1Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    -- Create Visuals
    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam")
    
    beam.Attachment0 = attP
    beam.Attachment1 = attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) -- Gold
    beam.Width0, beam.Width1 = 0.5, 0.5 
    beam.Texture = "rbxassetid://44611181" 
    beam.TextureSpeed = 2
    beam.FaceCamera = true
    beam.Parent = root
    
    v1Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- THE LOOP
task.spawn(function()
    print("Tracker V1: ACTIVE")
    while _G[scriptID] == true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
                if item.Name == TARGET_NAME then
                    local dist = (root.Position - item:GetPivot().Position).Magnitude
                    if dist <= MAX_DISTANCE then
                        createV1Path(item, root)
                    else
                        removeV1Path(item)
                    end
                end
            end
            
            -- Clean up if item is gone
            for model, _ in pairs(v1Beams) do
                if not model:IsDescendantOf(workspace) then
                    removeV1Path(model)
                end
            end
        end
        task.wait(0.5)
    end
    
    -- Final Cleanup
    for model, _ in pairs(v1Beams) do removeV1Path(model) end
    print("Tracker V1: STOPPED")
end)
