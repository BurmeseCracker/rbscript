-- [[ trackerv4.lua - Fuel Master (SYNC FIX) ]] --
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

-- [[ CONFIG ]] --
local COLLECTION_DIST = 20 
local TARGET_NAMES = {["Fuel"] = true, ["Refined Fuel"] = true}

local v4Beams = {}
local processed = {}

-- ... (Beam functions remain the same as previous) ...

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end

            local dist = (root.Position - targetPart.Position).Magnitude

            if dist <= COLLECTION_DIST then
                processed[item] = true
                
                task.spawn(function()
                    -- 1. DELAY BEFORE FIRE
                    task.wait(0.1) 
                    
                    -- 2. FIRE PICKUP
                    PickUpRemote:FireServer(item)
                    
                    -- 3. WAIT FOR DISAPPEARANCE 
                    -- We wait until the item actually leaves workspace before adjusting bag
                    local timeout = 0
                    while item.Parent == SEARCH_FOLDER and timeout < 10 do
                        task.wait(0.05)
                        timeout = timeout + 1
                    end
                    
                    -- 4. FINAL INVENTORY SLOT
                    AdjustRemote:FireServer(item)
                    
                    task.wait(1)
                    processed[item] = nil
                end)
            end
        end
    end
end)
