-- [[ trackerv1.lua - Battery Master (OWNERSHIP FIX) ]] --
local scriptID = "trackerv1" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local TRIGGER_DIST = 40 
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local processed = {}
local isCollecting = false

if _G.BatteryMasterLoop then _G.BatteryMasterLoop:Disconnect() end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local mainPart = item:FindFirstChild("MainPart") or item.PrimaryPart
            local dragRemote = item:FindFirstChild("ItemDrag") and item.ItemDrag:FindFirstChild("RequestNetworkOwnership")
            
            if not mainPart or not dragRemote then continue end

            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            if dist <= TRIGGER_DIST then
                isCollecting = true
                processed[item] = true
                
                task.spawn(function()
                    -- [ 1. TELEPORT CHAR ]
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- [ 2. REQUEST OWNERSHIP ]
                    -- This stops the item from snapping back to its original spot
                    dragRemote:FireServer(mainPart)
                    task.wait(0.1)
                    
                    -- [ 3. BRING & COLLECT ]
                    local startTime = tick()
                    while tick() - startTime < 1.0 and item and item.Parent do
                        item:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                        
                        if tick() - startTime > 0.05 then
                            PickUpRemote:FireServer(item)
                        end
                        RunService.Heartbeat:Wait()
                    end
                    
                    if item and item.Parent then AdjustRemote:FireServer(item) end
                    task.wait(0.1)
                    isCollecting = false
                    task.delay(2, function() processed[item] = nil end)
                end)
                break 
            end
        end
    end
end)
