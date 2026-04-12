-- [[ trackerv4.lua - Fuel Master (GLOBAL RANGE - NO TP) ]] --
local scriptID = "trackerv4" 

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
local MAX_VISUAL_DIST = 20
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
    local targetPart = model:FindFirstChild("Union") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
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
        if TARGET_NAMES[item.Name] and not processed[item] then
            local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end
            
            local dist = (root.Position - targetPart.Position).Magnitude

            -- 1. SHOW BEAMS
            if dist <= MAX_VISUAL_DIST then
                createV4Path(item, root)
            end

            -- 2. AUTOMATIC COLLECTION (NO DISTANCE / NO TP)
            processed[item] = true

            task.spawn(function()
                -- Delay before fire as requested
                task.wait(0.1)
                
                -- Fire collection remotes
                PickUpRemote:FireServer(item)
                
                -- Wait for server to process
                local timeout = 0
                while item.Parent == SEARCH_FOLDER and timeout < 20 do
                    task.wait(0.05)
                    timeout = timeout + 1
                end
                
                -- Finalize in backpack if server removed it from workspace
                if item.Parent ~= SEARCH_FOLDER then
                    AdjustRemote:FireServer(item)
                    removeV4Path(item)
                end
                
                -- 3 second cooldown per item slot
                task.wait(3)
                processed[item] = nil
            end)
        end
    end
end)

print("Fuel Global Remote Collect Loaded (No TP).")
