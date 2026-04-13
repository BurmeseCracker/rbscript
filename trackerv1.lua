-- [[ trackerv1.lua - Battery Master (SMART LIMITS) ]] --
local scriptID = "trackerv1" 

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
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}

local function removeV1Path(model)
    local data = v1Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v1Beams[model] = nil
    end
end

local function createV1Path(model, root)
    if v1Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) 
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    v1Beams[model] = {beam = beam, aP = attP, aB = attB}
end

if _G.BatteryMasterLoop then _G.BatteryMasterLoop:Disconnect() end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v1Beams) do removeV1Path(model) end
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
                    createV1Path(item, root)
                else
                    removeV4Path(item)
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
                        removeV1Path(item)
                        task.wait(1)
                        processed[item] = nil
                    end)
                end
            end
        end
    end
end)
