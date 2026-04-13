-- [[ trackerv4.lua - Fuel Master DEBUGGED ]] --
local scriptID = "trackerv4" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local TRACK_DIST = 150    
local COLLECT_DIST = 35   
local TARGET_NAME = "Fuel" -- Exact name of the item in DroppedItems

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

local function createV4Path(model, root)
    if v4Beams[model] then return end
    -- Look for Union or any BasePart to attach the beam to
    local targetPart = model:FindFirstChild("Union") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) 
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"
    beam.TextureSpeed = 2
    beam.FaceCamera = true
    v4Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.FuelMasterLoop then _G.FuelMasterLoop:Disconnect() end

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v4Beams) do removeV4Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        -- FIX: Simplified name check to ensure it actually triggers
        if item.Name == TARGET_NAME and not processedItems[item] then
            local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end
            
            local dist = (root.Position - targetPart.Position).Magnitude

            -- 1. TRACKING
            if dist <= TRACK_DIST then
                createV4Path(item, root)
            else
                removeV4Path(item)
            end

            -- 2. COLLECTION (The "Latch" fix)
            if dist <= COLLECT_DIST then
                processedItems[item] = true -- Lock item so loop doesn't spam it
                
                task.spawn(function()
                    -- Tell the server we are picking it up
                    PickUpRemote:FireServer(item)
                    task.wait(0.1)
                    AdjustRemote:FireServer(item)
                    
                    -- Remove visual beam immediately after firing
                    removeV4Path(item)
                    
                    -- Wait before allowing this specific item to be tracked again
                    task.wait(2) 
                    processedItems[item] = nil
                end)
            end
        end
    end
    
    -- Cleanup for items that vanished or were taken by others
    for model, _ in pairs(v4Beams) do
        if not model or not model.Parent then
            removeV4Path(model)
        end
    end
end)

print("Fuel Master Fixed & Loaded.")
