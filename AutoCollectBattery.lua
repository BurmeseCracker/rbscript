-- GitHub Script: AutoCollectBattery.lua
local scriptID = "AutoCollectBattery" -- This matches the Menu Toggle

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER_NAME = "DroppedItems"

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 12 -- Slightly increased for better pick-up on mobile
local TARGET_NAME = "Battery"
local processed = {} 

-- THE MAIN LOOP
task.spawn(function()
    print("Auto Battery: STARTED")
    
    -- Only runs while the Menu Toggle is [ON]
    while _G[scriptID] == true do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local folder = workspace:FindFirstChild(SEARCH_FOLDER_NAME)

        if root and folder then
            for _, item in pairs(folder:GetChildren()) do
                -- Only target Batteries that haven't been picked up yet
                if item.Name == TARGET_NAME and not processed[item] then
                    local itemPos = item:GetPivot().Position
                    local dist = (root.Position - itemPos).Magnitude

                    if dist <= MAX_DIST then
                        processed[item] = true 
                        
                        -- STEP 1: Physical Pick Up
                        PickUpRemote:FireServer(item)
                        
                        -- STEP 2: Register to Backpack
                        task.delay(0.1, function()
                            if item and item.Parent then
                                AdjustRemote:FireServer(item)
                            end
                        end)

                        -- Cleanup the 'processed' list after 5 seconds
                        task.delay(5, function() 
                            processed[item] = nil 
                        end)
                    end
                end
            end
        end
        
        -- Wait a small amount of time to prevent lag
        task.wait(0.3) 
    end

    print("Auto Battery: STOPPED")
end)
