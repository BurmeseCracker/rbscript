-- [[ trackerv1.lua - Battery Master (VISUAL BEAMS + RANGE COLLECT) ]] --
local scriptID = "trackerv1" 

-- Wait for Menu Toggle
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
local MAX_VISUAL_DIST = 150 -- Distance to see yellow beams
local COLLECT_DIST = 35     -- Distance to auto-collect (No TP)
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}

-- [[ BEAM LOGIC ]] --
local function removeV1Path(model)
    local data = v1Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v1Beams[model] = nil
    end
end

local function createV1Path(model, root)
    if v1Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) -- Yellow
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    v1Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.BatteryMasterLoop then _G.BatteryMasterLoop:Disconnect() end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    -- Check if Toggle is ON in Menu
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v1Beams) do removeV1Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- 1. SHOW BEAMS
            if dist <= MAX_VISUAL_DIST and not processed[item] then
                createV1Path(item, root)
            else
                removeV1Path(item)
            end

            -- 2. RANGE COLLECTION (NO TELEPORT)
            if dist <= COLLECT_DIST and not processed[item] then
                processed[item] = true
                removeV1Path(item)

                task.spawn(function()
                    -- Fire collection remotes
                    PickUpRemote:FireServer(item)
                    task.wait(0.1)
                    
                    if item and item.Parent then
                        AdjustRemote:FireServer(item)
                    end
                    
                    -- Cooldown for this specific item
                    task.wait(2)
                    processed[item] = nil
                end)
            end
        end
    end
end)

print("Battery Range Collect Loaded.") like this 
