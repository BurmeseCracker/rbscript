-- [[ trackerv1.lua - Battery Master (STEP SEARCH) ]] --
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
local MAX_VISUAL_DIST = 300
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

-- The steps you asked for
local DISTANCE_STEPS = {10, 20, 30, 40, 50, 60}

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

    -- Step-by-Step Search Logic
    local targetItem = nil
    
    for _, currentMaxDist in ipairs(DISTANCE_STEPS) do
        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if TARGET_NAMES[item.Name] and not processed[item] then
                local itemPos = item:GetPivot().Position
                local dist = (root.Position - itemPos).Magnitude
                
                -- Create beams for everything in range regardless of steps
                if dist <= MAX_VISUAL_DIST then createV1Path(item, root) end

                -- If we find an item within the current step distance
                if dist <= currentMaxDist then
                    targetItem = item
                    break 
                end
            end
        end
        if targetItem then break end -- Stop looking further if we found something close
    end

    -- If we found the "closest" item based on our steps
    if targetItem then
        isCollecting = true
        processed[targetItem] = true
        
        task.spawn(function()
            local startTime = tick()
            while tick() - startTime < 1.0 and targetItem and targetItem.Parent do
                -- Anchor style: Item comes to you
                targetItem:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                
                if tick() - startTime > 0.1 then
                    PickUpRemote:FireServer(targetItem)
                end
                RunService.Heartbeat:Wait()
            end
            
            if targetItem and targetItem.Parent then AdjustRemote:FireServer(targetItem) end
            
            task.wait(0.2)
            isCollecting = false
            task.wait(3)
            processed[targetItem] = nil
        end)
    end
end)
