-- GitHub Script: AutoCollectBattery.lua
local scriptID = "AutoCollectBattery" 

-- Wait for the Menu Toggle
repeat task.wait(0.1) until _G[scriptID] == true

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 12 
local TARGET_NAME = "Battery"
local processed = {} 

task.spawn(function()
    print("Auto Collect: ACTIVE")
    while _G[scriptID] == true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if root then
            for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
                if item.Name == TARGET_NAME and not processed[item] then
                    local dist = (root.Position - item:GetPivot().Position).Magnitude
                    if dist <= MAX_DIST then
                        processed[item] = true 
                        
                        -- Pick up logic
                        PickUpRemote:FireServer(item)
                        task.delay(0.1, function()
                            if item then AdjustRemote:FireServer(item) end
                        end)

                        -- Reset timer so it can pick up again if needed
                        task.delay(5, function() processed[item] = nil end)
                    end
                end
            end
        end
        task.wait(0.3)
    end
    print("Auto Collect: STOPPED")
end)
