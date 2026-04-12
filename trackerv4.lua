-- [[ trackerv4.lua - Fuel Master (SYNC FIXED) ]] --
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

local MAX_VISUAL_DIST = 150 
local COLLECT_DIST = 40     
local TARGET_NAMES = {["Fuel"] = true, ["Refined Fuel"] = true}

local v4Beams = {}
local processed = {}

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
    local targetPart = model:FindFirstChild("Union") or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) 
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    v4Beams[model] = {beam = beam, aP = attP, aB = attB}
end

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
        if TARGET_NAMES[item.Name] and not processed[item] then
            local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end
            
            local targetCFrame = targetPart.CFrame
            local dist = (root.Position - targetCFrame.Position).Magnitude

            if dist <= MAX_VISUAL_DIST then
                createV4Path(item, root)
            else
                removeV4Path(item)
            end

            if dist <= COLLECT_DIST then
                processed[item] = true

                task.spawn(function()
                    -- 1. TELEPORT & FREEZE
                    root.Anchored = true
                    char:PivotTo(targetCFrame * CFrame.new(0, 3, 0))
                    
                    -- 2. WAIT FOR SERVER SYNC
                    task.wait(0.25) 
                    
                    -- 3. ATTEMPT COLLECTION
                    PickUpRemote:FireServer(item)
                    task.wait(0.1)
                    
                    -- 4. SUCCESS CHECK
                    if item.Parent ~= SEARCH_FOLDER then
                        AdjustRemote:FireServer(item)
                        removeV4Path(item) 
                    end
                    
                    -- 5. UNFREEZE & COOLDOWN
                    root.Anchored = false
                    task.wait(1.5)
                    processed[item] = nil
                end)
            end
        end
    end
end)
