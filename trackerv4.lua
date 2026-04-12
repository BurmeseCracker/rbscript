-- [[ trackerv4.lua - Fuel Master (UNSTORE FIX) ]] --
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

local COLLECTION_DIST = 40 
local FIRE_DELAY = 0.1
local TARGET_NAMES = {["Fuel"] = true, ["Refined Fuel"] = true}

local processed = {}

if _G.FuelMasterLoop then _G.FuelMasterLoop:Disconnect() end

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        -- Only target if name matches and we aren't currently processing it
        if TARGET_NAMES[item.Name] and not processed[item] then
            
            -- Look for the Union specifically
            local targetPart = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end
            
            local dist = (root.Position - targetPart.Position).Magnitude

            if dist <= COLLECTION_DIST then
                processed[item] = true
                
                task.spawn(function()
                    task.wait(FIRE_DELAY) 
                    
                    -- Safety check: Ensure item is still there after the delay
                    if not item or not item.Parent then 
                        processed[item] = nil 
                        return 
                    end

                    PickUpRemote:FireServer(item)
                    
                    -- Wait to see if server actually takes the item
                    local success = false
                    local timeout = 0
                    while timeout < 15 do
                        if item.Parent ~= SEARCH_FOLDER then
                            success = true
                            break
                        end
                        task.wait(0.05)
                        timeout = timeout + 1
                    end
                    
                    -- Only fire Adjust if the server confirmed the pickup
                    if success then
                        AdjustRemote:FireServer(item)
                    end
                    
                    -- Long cooldown to prevent "Re-grabbing" the same item if you drop it
                    task.wait(5) 
                    processed[item] = nil
                end)
            end
        end
    end
end)
