local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER_NAME = "DroppedItems"

-- Remotes (Wait safely)
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 12
local FUEL_NAME = "Fuel"
local processed = {} 

-- Use a variable for the connection so we can track it
local connection
connection = RunService.Heartbeat:Connect(function()
    -- 1. Check if Character and Folder exist every frame
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local folder = workspace:FindFirstChild(SEARCH_FOLDER_NAME)
    
    if not root or not folder then return end

    -- 2. Scan items
    local items = folder:GetChildren()
    for _, item in pairs(items) do
        if item.Name == FUEL_NAME and not processed[item] then
            -- GetPivot() is better for Models on mobile
            local success, fuelPos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - fuelPos).Magnitude

            if dist <= MAX_DIST then
                local fuelUnion = item:FindFirstChild("Union")
                
                if fuelUnion then
                    processed[item] = true
                    
                    -- Physical Pick Up
                    PickUpRemote:FireServer(fuelUnion)
                    
                    -- Inventory Register
                    task.delay(0.1, function()
                        if item and item.Parent then
                            AdjustRemote:FireServer(item)
                        end
                    end)
                    
                    -- Remove from "processed" list if the item is actually gone
                    -- This keeps the script memory clean
                    task.delay(5, function()
                        if not item or not item.Parent then
                            processed[item] = nil
                        else
                            -- If it failed to pick up, let us try again
                            processed[item] = nil 
                        end
                    end)
                end
            end
        end
    end
end)
