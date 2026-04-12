-- [[ trackerv1.lua - Battery Master (TP -> DELAY -> COLLECT) ]] --
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

-- Config
local MAX_VISUAL_DIST = 100
local TRIGGER_DIST = 40    -- Only starts the sequence if within 40 studs
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}
local isCollecting = false

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
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
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
    if not root or isCollecting then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            local dist = (root.Position - pos).Magnitude

            -- Show beams for awareness
            if dist <= MAX_VISUAL_DIST then createV1Path(item, root) end

            -- Start the sequence at 40 range
            if dist <= TRIGGER_DIST and not processed[item] then
                isCollecting = true
                processed[item] = true
                
                task.spawn(function()
                    -- STEP 1: Teleport YOU to the item
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- STEP 2: Tiny delay (Let the server register your new position)
                    task.wait(0.1)
                    
                    -- STEP 3: Bring item to feet and fire remotes
                    local startTime = tick()
                    while tick() - startTime < 1.0 and item and item.Parent do
                        -- Keep item at your feet while you are at its location
                        item:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                        
                        if tick() - startTime > 0.05 then
                            PickUpRemote:FireServer(item)
                        end
                        RunService.Heartbeat:Wait()
                    end
                    
                    if item and item.Parent then AdjustRemote:FireServer(item) end
                    
                    task.wait(0.1)
                    isCollecting = false
                    task.wait(2) -- Reset cooldown
                    processed[item] = nil
                end)
                break 
            end
        end
    end
end)
