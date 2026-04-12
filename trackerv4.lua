-- [[ trackerv4.lua - Fuel Master (UNIONS + RANGE COLLECT) ]] --
local scriptID = "trackerv4" 

-- 1. Sync with Menu Toggle
if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
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

-- Cleanup Helper
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

local function clearAllV4()
    for item, _ in pairs(_G.v4Beams) do
        removeSingleV4(item)
    end
    _G.v4Beams = {}
end

-- [[ MAIN LOOP ]] --
_G.TrackerV4Loop = RunService.Heartbeat:Connect(function()
    -- Stop loop if menu toggle is OFF
    if _G[scriptID] ~= true then
        clearAllV4()
        if _G.TrackerV4Loop then _G.TrackerV4Loop:Disconnect() end
        _G.TrackerV4Loop = nil
        return
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        -- Strict check for Unions/Parts named Fuel
        if TARGET_NAMES[item.Name] and (item:IsA("BasePart") or item:IsA("UnionOperation")) then
            local itemPos = item.Position
            local dist = (root.Position - itemPos).Magnitude
            
            -- A. Beam Logic
            if dist <= MAX_DISTANCE and not processed[item] then
                if not _G.v4Beams[item] then
                    local attP = Instance.new("Attachment", root)
                    local attB = Instance.new("Attachment", item)
                    local beam = Instance.new("Beam", root)
                    
                    beam.Attachment0, beam.Attachment1 = attP, attB
                    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Red
                    beam.Width0, beam.Width1 = 0.35, 0.35
                    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2.5; beam.FaceCamera = true
                    
                    _G.v4Beams[item] = {beam = beam, aP = attP, aB = attB}
                end
            else
                removeSingleV4(item)
            end

            -- B. Collection Logic (Range-based, no teleport)
            if dist <= COLLECT_DIST and not processed[item] then
                processed[item] = true
                removeSingleV4(item)
                
                task.spawn(function()
                    -- Direct pickup remote
                    PickUpRemote:FireServer(item)
                    task.wait(0.2)
                    
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end
                    
                    task.wait(2) -- Cooldown for this specific object
                    processed[item] = nil
                end)
            end
        end
    end
end)
