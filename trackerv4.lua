-- [[ trackerv3.lua - Fuel Master ]] --
local scriptID = "trackerv4" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- [[ CONFIG ]] --
local MAX_VISUAL_DIST = 150
local TRIGGER_DIST = 40 
local TARGET_NAMES = {["Fuel"] = true, ["Refined Fuel"] = true}

local v3Beams = {}
local processed = {}
local isCollecting = false

local function removeV3Path(model)
    local data = v3Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v3Beams[model] = nil
    end
end

local function createV3Path(model, root)
    if v3Beams[model] then return end
    local targetPart = model:FindFirstChild("Union") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Red
    beam.Width0, beam.Width1 = 0.6, 0.6
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    v3Beams[model] = {beam = beam, aP = attP, aB = attB}
end

if _G.FuelMasterLoop then _G.FuelMasterLoop:Disconnect() end

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v3Beams) do removeV3Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- 1. SHOW RED BEAMS
            if dist <= MAX_VISUAL_DIST then
                createV3Path(item, root)
            else
                removeV3Path(item)
            end

            -- 2. TP & COLLECT LOGIC
            if dist <= TRIGGER_DIST then
                local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
                local dragRemote = item:FindFirstChild("ItemDrag") and item.ItemDrag:FindFirstChild("RequestNetworkOwnership")
                
                if targetPart and dragRemote then
                    isCollecting = true
                    processed[item] = true
                    
                    task.spawn(function()
                        -- TP Character
                        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        
                        -- Request Ownership of the Union
                        dragRemote:FireServer(targetPart)
                        task.wait(0.1)
                        
                        -- Force Bring Loop
                        local startTime = tick()
                        while tick() - startTime < 1.0 and item and item.Parent do
                            item:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                            if tick() - startTime > 0.05 then
                                PickUpRemote:FireServer(item)
                            end
                            RunService.Heartbeat:Wait()
                        end
                        
                        if item and item.Parent then AdjustRemote:FireServer(item) end
                        task.wait(0.1)
                        isCollecting = false
                        task.delay(3, function() processed[item] = nil end)
                    end)
                    break 
                end
            end
        end
    end
end)
