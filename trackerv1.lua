-- GitHub Script: AutoCollectBattery.lua
local scriptID = "AutoCollectBattery" 

-- SAFETY: Wait until the Menu actually sets the variable to true
repeat task.wait(0.1) until _G[scriptID] == true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local MAX_DISTANCE = 500 -- Increased distance to make sure you see it
local TARGET_NAME = "Battery"
local activeBeams = {} 

local function removePath(model)
    local data = activeBeams[model]
    if data then
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
        activeBeams[model] = nil
    end
end

local function createGoldenPath(model, root)
    if activeBeams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam")
    
    beam.Attachment0 = attP
    beam.Attachment1 = attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) 
    beam.Width0, beam.Width1 = 0.5, 0.5 
    beam.Texture = "rbxassetid://44611181" 
    beam.TextureSpeed = 2
    beam.FaceCamera = true
    beam.Parent = root
    
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

-- THE LOOP
task.spawn(function()
    print("Battery Tracker is now ACTIVE")
    while _G[scriptID] == true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            local items = SEARCH_FOLDER:GetChildren()
            for _, item in pairs(items) do
                if item.Name == TARGET_NAME then
                    local pos = item:GetPivot().Position
                    local dist = (root.Position - pos).Magnitude
                    
                    if dist <= MAX_DISTANCE then
                        createGoldenPath(item, root)
                    else
                        removePath(item)
                    end
                end
            end
        end
        task.wait(0.5)
    end
    
    -- Cleanup when OFF
    for model, _ in pairs(activeBeams) do removePath(model) end
    print("Battery Tracker is now STOPPED")
end)
