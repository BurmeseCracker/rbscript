local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local MAX_DISTANCE = 200 
local COLLECT_DIST = 35    
local TARGET_NAMES = { ["Fuel"] = true, ["Refined Fuel"] = true }

if _G.TrackerV4Loop then _G.TrackerV4Loop:Disconnect() end
_G.v4Beams = _G.v4Beams or {}
local processed = {}

-- Function to remove a single beam
local function removeSingleV4(item)
    local data = _G.v4Beams[item]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        _G.v4Beams[item] = nil
    end
end

-- Function to clear all beams
local function clearAllV4()
    for item, _ in pairs(_G.v4Beams) do
        removeSingleV4(item)
    end
    _G.v4Beams = {}
end

_G.TrackerV4Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv4"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            -- Identify strictly by name and physical type (Union/Part)
            if TARGET_NAMES[item.Name] and (item:IsA("BasePart") or item:IsA("UnionOperation")) then
                local itemPos = item.Position
                local dist = (root.Position - itemPos).Magnitude
                
                -- [[ 1. BEAM LOGIC ]] --
                if dist <= MAX_DISTANCE and not processed[item] then
                    if not _G.v4Beams[item] then
                        local attP = Instance.new("Attachment", root)
                        local attB = Instance.new("Attachment", item)
                        local beam = Instance.new("Beam", root)
                        
                        beam.Attachment0, beam.Attachment1 = attP, attB
                        beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Red
                        beam.Width0, beam.Width1 = 0.35, 0.35
                        beam.Texture = "rbxassetid://44611181"
                        beam.TextureSpeed = 2.5
                        beam.FaceCamera = true
                        
                        _G.v4Beams[item] = {beam = beam, aP = attP, aB = attB}
                    end
                else
                    removeSingleV4(item)
                end

                -- [[ 2. COLLECTION LOGIC ]] --
                if dist <= COLLECT_DIST and not processed[item] then
                    processed[item] = true
                    removeSingleV4(item) -- Beam gone on collect
                    
                    task.spawn(function()
                        -- Direct Remote Fire on the object
                        PickUpRemote:FireServer(item)
                        
                        task.wait(0.2)
                        
                        if item and item.Parent then 
                            AdjustRemote:FireServer(item) 
                        end
                        
                        task.wait(2) -- Cooldown
                        processed[item] = nil
                    end)
                end
            end
        end
    else
        clearAllV4()
        if _G.TrackerV4Loop then
            _G.TrackerV4Loop:Disconnect()
            _G.TrackerV4Loop = nil
        end
    end
end)
