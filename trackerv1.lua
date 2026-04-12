-- [[ BATTERY MASTER - SEPARATE BRING & COLLECT ]] --
local scriptID = "trackerv1" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DISTANCE = 200     -- Beam distance
local BRING_DIST = 200        -- Distance to start pulling item to you
local COLLECT_DIST = 200      -- Distance to actually fire the PickUp Remote
local TARGET_NAMES = {
    ["Battery"] = true, 
    ["Battery Pack"] = true
}

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
    beam.Width0, beam.Width1, beam.Texture, beam.TextureSpeed, beam.FaceCamera = 0.5, 0.5, "rbxassetid://44611181", 2, true
    v1Beams[model] = {beam = beam, aP = attP, aB = attB}
end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end

            local dist = (root.Position - pos).Magnitude

            if dist <= MAX_DISTANCE then
                createV1Path(item, root)
                
                -- [[ 1. BRING LOGIC ]] --
                -- If item is within 60 studs, pull it to your feet constantly
                if dist <= BRING_DIST then
                    item:PivotTo(root.CFrame * CFrame.new(0, -2, -2))
                end

                -- [[ 2. COLLECT LOGIC ]] --
                -- Only fire remotes if the item is successfully brought within 10 studs
                if dist <= COLLECT_DIST and not processed[item] and not isCollecting then
                    isCollecting = true
                    processed[item] = true
                    
                    task.wait(0.1) -- Small delay to let the game register item position
                    PickUpRemote:FireServer(item)
                    
                    task.wait(0.1)
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end

                    task.wait(0.2)
                    isCollecting = false
                    task.delay(3, function() processed[item] = nil end)
                end
            else
                removeV1Path(item)
            end
        end
    end

    for model, _ in pairs(v1Beams) do
        if not model:IsDescendantOf(workspace) then removeV1Path(model) end
    end
end)
