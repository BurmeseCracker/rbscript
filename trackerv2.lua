-- [[ trackerv2.lua - Scrap Master (TP + OWNERSHIP + BRING) ]] --
local scriptID = "trackerv2" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local DROP_FOLDER = workspace:WaitForChild("DroppedItems")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local TRIGGER_DIST = 40    -- Teleport trigger range
local ITEM_NAME = "Scrap"

local processed = {}
local isCollecting = false

if _G.ScrapMasterLoop then _G.ScrapMasterLoop:Disconnect() end

_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    for _, item in pairs(DROP_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME and not processed[item] then
            -- Find specific components for Ownership
            local mainPart = item:FindFirstChild("MainPart") or item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            local itemDrag = item:FindFirstChild("ItemDrag")
            local ownershipRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")

            if not mainPart or not ownershipRemote then continue end

            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- TRIGGER AT 40 STUDS
            if dist <= TRIGGER_DIST then
                isCollecting = true
                processed[item] = true

                task.spawn(function()
                    -- 1. TELEPORT CHAR TO SCRAP
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- 2. CLAIM OWNERSHIP
                    ownershipRemote:FireServer(mainPart)
                    task.wait(0.1)
                    
                    -- 3. BRING & COLLECT LOOP
                    local startTime = tick()
                    while tick() - startTime < 1.0 and item and item.Parent do
                        -- Force Scrap to your feet
                        item:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                        
                        -- Fire the collect remote
                        if tick() - startTime > 0.05 then
                            PickUpRemote:FireServer(item)
                        end
                        RunService.Heartbeat:Wait()
                    end
                    
                    -- 4. CLEAN UP
                    if item and item.Parent then AdjustRemote:FireServer(item) end
                    task.wait(0.1)
                    isCollecting = false
                    
                    -- Cooldown for this specific piece of scrap
                    task.delay(3, function() processed[item] = nil end)
                end)
                break -- Focus on one item at a time
            end
        end
    end
end)
