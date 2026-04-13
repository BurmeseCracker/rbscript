-- [[ TRACKER V3 - SMART BRING ITEMS ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local MAX_DISTANCE = 40 -- Bring distance
local MAX_VISUAL_DIST = 100 -- Beam distance
local TARGET_NAMES = {
    ["Chips"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["Bloxy Cola"] = true
}

if _G.TrackerV3Loop then _G.TrackerV3Loop:Disconnect() end
_G.v3Beams = _G.v3Beams or {}
local processed = {}

local function clearV3()
    for model, data in pairs(_G.v3Beams) do
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
    end
    _G.v3Beams = {}
end

_G.TrackerV3Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv3"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local itemsInRange = {}

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if TARGET_NAMES[item.Name] and not processed[item] then
                local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
                
                if targetPart then
                    local dist = (root.Position - targetPart.Position).Magnitude
                    
                    -- Visual Beam Logic
                    if dist <= MAX_VISUAL_DIST then
                        if not _G.v3Beams[item] then
                            local attP = Instance.new("Attachment", root)
                            local attB = Instance.new("Attachment", targetPart)
                            local beam = Instance.new("Beam", root)
                            beam.Attachment0, beam.Attachment1 = attP, attB
                            beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0)) 
                            beam.Width0, beam.Width1 = 0.35, 0.35
                            beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2.5; beam.FaceCamera = true
                            _G.v3Beams[item] = {beam = beam, aP = attP, aB = attB}
                        end
                    elseif _G.v3Beams[item] then
                        _G.v3Beams[item].beam:Destroy(); _G.v3Beams[item].aP:Destroy(); _G.v3Beams[item].aB:Destroy()
                        _G.v3Beams[item] = nil
                    end

                    -- Collection Logic
                    if dist <= MAX_DISTANCE then
                        table.insert(itemsInRange, {item = item, part = targetPart, dist = dist})
                    end
                end
            end
        end

        -- Sort by distance and Bring the closest item
        table.sort(itemsInRange, function(a,b) return a.dist < b.dist end)
        local targetData = itemsInRange[1]

        if targetData then
            local item = targetData.item
            local itemPart = targetData.part
            processed[item] = true

            task.spawn(function()
                local startTime = tick()
                while tick() - startTime < 1 do
                    if not item or not item.Parent or not itemPart then break end
                    
                    -- Bring item to you
                    itemPart.CFrame = root.CFrame * CFrame.new(0, 0, -2)
                    
                    -- Fire pickup
                    if tick() - startTime < 0.1 then
                        AdjustRemote:FireServer(item)
                    end
                    RunService.RenderStepped:Wait()
                end

                if _G.v3Beams[item] then
                    _G.v3Beams[item].beam:Destroy(); _G.v3Beams[item].aP:Destroy(); _G.v3Beams[item].aB:Destroy()
                    _G.v3Beams[item] = nil
                end
                task.wait(1)
                processed[item] = nil
            end)
        end
    else
        clearV3()
        _G.TrackerV3Loop:Disconnect()
        _G.TrackerV3Loop = nil
    end
end)

print("Tracker V3 (Bring Mode) Loaded.")
