-- [[ trackerv3.lua - Dual Remote PickUp (Priority) ]] --
local scriptID = "trackerv3" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")
local CHAR_FOLDER = workspace:FindFirstChild("Characters")

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local MAX_VISUAL_DIST = 100
local COLLECT_RANGE = 40 
local TARGET_NAMES = { ["Chips"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["Bloxy Cola"] = true, ["MRE"] = true}

local v3Beams = {}
local processed = {}

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
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0)) 
    beam.Width0, beam.Width1 = 0.35, 0.35
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2.5; beam.FaceCamera = true
    v3Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.TrackerV3Loop then _G.TrackerV3Loop:Disconnect() end

_G.TrackerV3Loop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v3Beams) do removeV3Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local itemsInRange = {}
    local allItems = {}

    for _, v in pairs(SEARCH_FOLDER:GetChildren()) do table.insert(allItems, v) end
    if CHAR_FOLDER then
        for _, person in pairs(CHAR_FOLDER:GetChildren()) do
            if person ~= char then
                for _, item in pairs(person:GetChildren()) do
                    table.insert(allItems, item)
                end
            end
        end
    end

    for _, item in pairs(allItems) do
        local inMyPossession = item:IsDescendantOf(char) or (player:FindFirstChild("Backpack") and item:IsDescendantOf(player.Backpack))
        
        if TARGET_NAMES[item.Name] and not processed[item] and not inMyPossession then
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                
                if dist <= MAX_VISUAL_DIST then 
                    createV3Path(item, root) 
                else
                    removeV3Path(item)
                end
                
                local isHeldByOther = item:IsDescendantOf(CHAR_FOLDER)
                if dist <= COLLECT_RANGE and not isHeldByOther then 
                    table.insert(itemsInRange, {item = item, dist = dist, pos = targetPart.Position})
                end
            end
        end
    end

    table.sort(itemsInRange, function(a, b) return a.dist < b.dist end)
    local targetData = itemsInRange[1]

    if targetData then
        local item = targetData.item
        local pos = targetData.pos
        local originalPos = root.CFrame 
        processed[item] = true
        
        task.spawn(function()
            local targetCFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            local startTime = tick()
            
            while tick() - startTime < 0.5 do 
                if not item or not item.Parent then break end

                root.CFrame = targetCFrame
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                
                if tick() - startTime < 0.1 then
                    -- FIRE REMOTES IN ORDER
                    pcall(function()
                        PickUpRemote:InvokeServer(item) -- First: Interaction PickUp
                        AdjustRemote:FireServer(item)   -- Second: Backpack Adjustment
                    end)
                end
                RunService.RenderStepped:Wait()
            end
            
            root.CFrame = originalPos
            root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            
            task.wait(0.1)
            removeV3Path(item)
            task.wait(1.0)
            processed[item] = nil
        end)
    end
end)

print("Food Master: Dual Remote (PickUp -> Adjust) Loaded.")
