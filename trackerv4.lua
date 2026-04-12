-- [[ trackerv4.lua - Fuel Master (UNION + DELAYED REMOTE) ]] --
local scriptID = "trackerv4" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local MAX_VISUAL_DIST = 150 
local COLLECT_DIST = 40     -- Auto-collect range
local TARGET_NAMES = {["Fuel"] = true, ["Refined Fuel"] = true}

local v4Beams = {}
local processed = {}

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
    -- Targets Union first, then Part
    local targetPart = model:FindFirstChild("Union") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Red
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
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
        if TARGET_NAMES[item.Name] then
            -- Find the Union for position check
            local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end
            
            local pos = targetPart.Position
            local dist = (root.Position - pos).Magnitude

            -- 1. SHOW RED BEAMS
            if dist <= MAX_VISUAL_DIST and not processed[item] then
                createV4Path(item, root)
            else
                removeV4Path(item)
            end

            -- 2. DELAYED COLLECTION
            if dist <= COLLECT_DIST and not processed[item] then
                processed[item] = true
                removeV4Path(item)

                task.spawn(function()
                    -- Delay before fire as requested
                    task.wait(0.1)
                    
                    -- Remote Fire
                    PickUpRemote:FireServer(item)
                    
                    -- Wait for item to disappear from world
                    local timeout = 0
                    while item.Parent == SEARCH_FOLDER and timeout < 20 do
                        RunService.Heartbeat:Wait()
                        timeout = timeout + 1
                    end
                    
                    -- Finalize in backpack
                    AdjustRemote:FireServer(item)
                    
                    task.wait(2)
                    processed[item] = nil
                end)
            end
        end
    end
end)

print("Fuel Master v4 (Union Ready) Loaded.")
