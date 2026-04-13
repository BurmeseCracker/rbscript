-- [[ trackerv4.lua - Fuel Master (SYNC + COLLECTION) ]] --
local scriptID = "trackerv4" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes (Mirrored from Scrap script)
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local TRACK_DIST = 150    -- Distance to show beams
local COLLECT_DIST = 35   -- Distance to auto-pickup
local ITEM_NAME = "Fuel"

local v4Beams = {}
local processedItems = {}

-- [[ BEAM LOGIC ]] --
local function removeV4Path(model)
    local data = v4Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v4Beams[model] = nil
    end
end

local function clearAllBeams()
    for model, _ in pairs(v4Beams) do
        removeV4Path(model)
    end
end

local function createV4Path(model, root, color)
    if v4Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChild("Union") or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(color)
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"
    beam.TextureSpeed = 2
    beam.FaceCamera = true
    v4Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.FuelMasterLoop then _G.FuelMasterLoop:Disconnect() end

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    -- CRITICAL: If Menu is OFF, destroy all beams and stop
    if _G[scriptID] ~= true then 
        clearAllBeams()
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME and not processedItems[item] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- 1. VISUAL TRACKING (Red Beam)
            if dist <= TRACK_DIST then
                createV4Path(item, root, Color3.fromRGB(255, 0, 0))
            else
                removeV4Path(item)
            end

            -- 2. INSTANT SYNC PICKUP (Mirroring Scrap logic)
            if dist <= COLLECT_DIST then
                processedItems[item] = true

                task.spawn(function()
                    task.wait(0.1) -- Stability delay
                    
                    -- Remote calls for collection
                    PickUpRemote:FireServer(item)
                    AdjustRemote:FireServer(item)
                    
                    task.wait(0.2)
                    removeV4Path(item)
                    
                    task.wait(2.5) -- Cooldown to prevent spam/lag
                    processedItems[item] = nil
                end)
            end
        end
    end
    
    -- Cleanup orphaned beams
    for model, _ in pairs(v4Beams) do
        if not model or not model.Parent then
            removeV4Path(model)
        end
    end
end)

print("Fuel Master Loaded (Auto-Collection Enabled).")
