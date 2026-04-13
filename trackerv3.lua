-- [[ trackerv3.lua - Food Master (SMART LIMITS) ]] --
local scriptID = "trackerv3" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG (V4 STYLE)
local TRACK_DIST = 100    -- Beam distance
local COLLECT_DIST = 40   -- Bring distance
local TARGET_NAMES = { ["Chips"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["Bloxy Cola"] = true, ["MRE"] = true}

local v3Beams = {}
local processed = {}

local function removeV3Path(model)
    local data = v3Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v3Beams[model] = nil
    end
end

local function createV3Path(model, root)
    if v3Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0)) 
    beam.Width0, beam.Width1 = 0.35, 0.35
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2.5; beam.FaceCamera = true
    v3Beams[model] = {beam = beam, aP = attP, aB = attB}
end

if _G.TrackerV3Loop then _G.TrackerV3Loop:Disconnect() end

_G.TrackerV3Loop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v3Beams) do removeV3Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude

                -- 1. Visual Beam (TRACK_DIST)
                if dist <= TRACK_DIST then
                    createV3Path(item, root)
                else
                    removeV3Path(item)
                end

                -- 2. Collection Logic (COLLECT_DIST)
                if dist <= COLLECT_DIST then
                    processed[item] = true
                    task.spawn(function()
                        local startTime = tick()
                        while tick() - startTime < 1 do
                            if not item or not item.Parent or not targetPart then break end
                            targetPart.CFrame = root.CFrame * CFrame.new(0, 0, -2)
                            if tick() - startTime < 0.1 then
                                AdjustRemote:FireServer(item)
                            end
                            RunService.RenderStepped:Wait()
                        end
                        removeV3Path(item)
                        task.wait(1)
                        processed[item] = nil
                    end)
                end
            end
        end
    end
end)
