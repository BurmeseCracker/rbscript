local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

local MAX_DISTANCE = 200 
local COLLECT_DIST = 40    -- Distance to fire the pickup remote
local TARGET_NAMES = { ["Fuel"] = true, ["Refined Fuel"] = true }

if _G.TrackerV4Loop then _G.TrackerV4Loop:Disconnect() end
_G.v4Beams = _G.v4Beams or {}
local processed = {}

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
                
                -- [[ 1. BEAM LOGIC ]] --
                if dist <= MAX_DISTANCE and not processed[item] then
                    if not _G.v4Beams[item] then
                        -- Updated to find Union or BasePart
                        local targetPart = item.PrimaryPart 
                            or item:FindFirstChildWhichIsA("UnionOperation") 
                            or item:FindFirstChildWhichIsA("BasePart")

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

                -- [[ 2. AUTO-COLLECT (REMOTE ONLY) ]] --
                if dist <= COLLECT_DIST and not processed[item] then
                    processed[item] = true
                    
                    task.spawn(function()
                        -- Fire pickup remote immediately
                        PickUpRemote:FireServer(item)
                        task.wait(0.1)
                        
                        -- Finalize backpack adjustment
                        if item and item.Parent then 
                            AdjustRemote:FireServer(item) 
                        end
                        
                        -- Brief delay before this specific item can be tracked again (if it failed)
                        task.wait(2)
                        processed[item] = nil
                    end)
                end
            end
        end
    else
        clearV4()
        _G.TrackerV4Loop:Disconnect()
        _G.TrackerV4Loop = nil
    end
end)
