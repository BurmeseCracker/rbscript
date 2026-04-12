-- [[ trackerv1.lua - Battery Master (FIXED BEAMS + TP) ]] --
local scriptID = "trackerv1" 

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

-- CONFIG
local MAX_VISUAL_DIST = 100 -- Distance to see beams
local TRIGGER_DIST = 40     -- Distance to teleport
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}
local isCollecting = false

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

if _G.BatteryMasterLoop then _G.BatteryMasterLoop:Disconnect() end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
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

            -- 1. SHOW BEAMS (Always run this if not collected)
            if dist <= MAX_VISUAL_DIST and not processed[item] then
                createV1Path(item, root)
            else
                removeV1Path(item)
            end

            -- 2. TRIGGER TP & OWNERSHIP & COLLECT
            if dist <= TRIGGER_DIST and not processed[item] and not isCollecting then
                local mainPart = item:FindFirstChild("MainPart") or item.PrimaryPart
                local itemDrag = item:FindFirstChild("ItemDrag")
                local ownershipRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")

                if mainPart and ownershipRemote then
                    isCollecting = true
                    processed[item] = true
                    removeV1Path(item) -- Clean beam before TP
                    
                    task.spawn(function()
                        -- TP
                        root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                        
                        -- Claim Physics
                        ownershipRemote:FireServer(mainPart)
                        task.wait(0.1)
                        
                        -- Bring & Collect
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
