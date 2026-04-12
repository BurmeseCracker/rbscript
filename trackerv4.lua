local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

local MAX_DISTANCE = 200 
local TRIGGER_DIST = 40    -- Distance to Teleport
local TARGET_NAMES = { ["Fuel"] = true, ["Refined Fuel"] = true }

if _G.TrackerV4Loop then _G.TrackerV4Loop:Disconnect() end
_G.v4Beams = _G.v4Beams or {}
local processed = {}
local isCollecting = false

local function clearV4()
    for model, data in pairs(_G.v4Beams) do
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
    end
    _G.v4Beams = {}
end

_G.TrackerV4Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv4"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if item:IsA("Model") and TARGET_NAMES[item.Name] then
                local itemPos = item:GetPivot().Position
                local dist = (root.Position - itemPos).Magnitude
                
                -- [[ 1. ORIGINAL BEAM LOGIC ]] --
                if dist <= MAX_DISTANCE and not processed[item] then
                    if not _G.v4Beams[item] then
                        local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            local attP = Instance.new("Attachment", root)
                            local attB = Instance.new("Attachment", targetPart)
                            local beam = Instance.new("Beam", root)
                            beam.Attachment0, beam.Attachment1 = attP, attB
                            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Red
                            beam.Width0, beam.Width1, beam.Texture, beam.TextureSpeed, beam.FaceCamera = 0.35, 0.35, "rbxassetid://44611181", 2.5, true
                            _G.v4Beams[item] = {beam = beam, aP = attP, aB = attB}
                        end
                    end
                else
                    if _G.v4Beams[item] then
                        pcall(function()
                            _G.v4Beams[item].beam:Destroy(); _G.v4Beams[item].aP:Destroy(); _G.v4Beams[item].aB:Destroy()
                        end)
                        _G.v4Beams[item] = nil
                    end
                end

                -- [[ 2. ADDED TELEPORT & BRING ]] --
                if dist <= TRIGGER_DIST and not processed[item] and not isCollecting then
                    local mainPart = item:FindFirstChild("MainPart") or item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                    local itemDrag = item:FindFirstChild("ItemDrag")
                    local ownershipRemote = itemDrag and itemDrag:FindFirstChild("RequestNetworkOwnership")

                    if mainPart and ownershipRemote then
                        isCollecting = true
                        processed[item] = true
                        
                        task.spawn(function()
                            -- Teleport Char
                            root.CFrame = CFrame.new(itemPos + Vector3.new(0, 3, 0))
                            
                            -- Ownership Fix
                            ownershipRemote:FireServer(mainPart)
                            task.wait(0.1)
                            
                            -- Bring & Collect Loop
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
                            task.delay(3, function() processed[item] = nil end)
                        end)
                        break 
                    end
                end
            end
        end
    else
        clearV4()
        _G.TrackerV4Loop:Disconnect()
        _G.TrackerV4Loop = nil
    end
end)
