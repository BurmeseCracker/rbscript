local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER_NAME = "DroppedItems"

-- Remotes
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 10
local TARGET_NAME = "Scrap" -- Only Battery now
local processed = {} 

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    -- Find the folder every frame in case it reloads
    local folder = workspace:FindFirstChild(SEARCH_FOLDER_NAME)
    if not root or not folder then return end

    for _, item in pairs(folder:GetChildren()) do
        -- Only check for Batteries
        if item.Name == TARGET_NAME and not processed[item] then
            local dist = (root.Position - item:GetPivot().Position).Magnitude

            if dist <= MAX_DIST then
                processed[item] = true 
                
                -- STEP 1: Physical Pick Up
                PickUpRemote:FireServer(item)
                
                -- STEP 2: Register to Backpack
                task.delay(0.1, function()
                    if item then
                        AdjustRemote:FireServer(item)
                    end
                end)

                -- Cleanup: remove from table after 5 seconds
                task.delay(5, function() 
                    processed[item] = nil 
                end)
            end
        end
    end
end)
