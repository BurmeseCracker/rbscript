-- This ID must match the filename without ".lua"
local scriptID = "AutoCollectBattery" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Config
local MAX_DISTANCE = 200 
local TARGET_NAME = "Battery"

local activeBeams = {} 

-- Function to remove the path (CLEANUP)
local function removePath(model)
    local data = activeBeams[model]
    if data then
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
        activeBeams[model] = nil
    end
end

-- Function to remove ALL paths when script is turned OFF
local function removeAllBeams()
    for model, _ in pairs(activeBeams) do
        removePath(model)
    end
end

-- Function to create the Golden Path
local function createGoldenPath(model, root)
    if activeBeams[model] then return end
    
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    
    local beam = Instance.new("Beam")
    beam.Attachment0 = attP
    beam.Attachment1 = attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) 
    beam.Width0, beam.Width1 = 0.35, 0.35 
    beam.Texture = "rbxassetid://44611181" 
    beam.TextureSpeed = 2.5 
    beam.FaceCamera = true
    beam.Parent = root
    
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

-- THE MAIN LOOP (Checks if Toggle is ON)
task.spawn(function()
    print(scriptID .. " is now running...")
    
    -- This while loop only runs as long as the Menu Toggle is [ON]
    while _G[scriptID] == true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            -- Scan for Items
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

            -- Cleanup if item is gone
            for model, _ in pairs(activeBeams) do
                if not model:IsDescendantOf(workspace) then
                    removePath(model)
                end
            end
        end
        
        task.wait(0.5) -- Check twice per second (saves battery)
    end

    -- IF WE REACH HERE, THE TOGGLE WAS TURNED OFF
    print(scriptID .. " turned OFF. Cleaning up beams...")
    removeAllBeams()
end)
