-- [[ trackerv3.lua - Fuel Master (SPEED FIX) ]] --
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

local TRIGGER_DIST = 40 
local TARGET_NAMES = {["Fuel"] = true, ["Refined Fuel"] = true}

local processed = {}
local isCollecting = false

if _G.FuelMasterLoop then _G.FuelMasterLoop:Disconnect() end

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true or isCollecting then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] and item:FindFirstChild("Union") then
            local targetPart = item.Union
            local pos = targetPart.Position
            local dist = (root.Position - pos).Magnitude

            if dist <= TRIGGER_DIST then
                isCollecting = true
                processed[item] = true
                
                task.spawn(function()
                    -- 1. Immediate TP
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- 2. Claim Ownership
                    local drag = item:FindFirstChild("ItemDrag")
                    if drag and drag:FindFirstChild("RequestNetworkOwnership") then
                        drag.RequestNetworkOwnership:FireServer(targetPart)
                    end
                    
                    -- 3. Short buffer for Server Sync
                    task.wait(0.15) 
                    
                    -- 4. Multi-Fire Collection (Ensures it hits)
                    local tries = 0
                    while item and item.Parent == SEARCH_FOLDER and tries < 10 do
                        item:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                        PickUpRemote:FireServer(item)
                        RunService.Heartbeat:Wait()
                        tries = tries + 1
                    end
                    
                    -- 5. Finalize Inventory
                    AdjustRemote:FireServer(item)
                    
                    task.wait(0.1)
                    isCollecting = false
                    
                    -- Cleanup: Remove from processed if it's actually gone
                    task.delay(2, function() processed[item] = nil end)
                end)
                break 
            end
        end
    end
end)
