-- [[ trackerv2.lua - Scrap Master ]] --
local scriptID = "trackerv2" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local DROP_FOLDER = workspace:WaitForChild("DroppedItems")
local PILE_FOLDER = workspace:WaitForChild("Structures")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

local TRACK_DIST = 150
local BRING_DIST = 60
local COLLECT_DIST = 10
local PILE_NAME = "Scrap Pile"
local ITEM_NAME = "Scrap"

local activeBeams = {}
local processed = {}
local isCollecting = false

local function removePath(model)
    local data = activeBeams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        activeBeams[model] = nil
    end
end

local function createPath(model, root)
    if activeBeams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end
    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)) -- Cyan
    beam.Width0, beam.Width1 = 0.4, 0.4
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(activeBeams) do removePath(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Track Piles
    for _, pile in pairs(PILE_FOLDER:GetChildren()) do
        if pile.Name == PILE_NAME then
            local dist = (root.Position - pile:GetPivot().Position).Magnitude
            if dist <= TRACK_DIST then createPath(pile, root) else removePath(pile) end
        end
    end

    -- Collect Items
    for _, item in pairs(DROP_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME then
            local dist = (root.Position - item:GetPivot().Position).Magnitude
            if dist <= BRING_DIST then
                item:PivotTo(root.CFrame * CFrame.new(0, -2, -2))
                if dist <= COLLECT_DIST and not processed[item] and not isCollecting then
                    isCollecting = true
                    processed[item] = true
                    task.wait(0.1)
                    PickUpRemote:FireServer(item)
                    task.wait(0.1)
                    if item and item.Parent then AdjustRemote:FireServer(item) end
                    task.wait(0.1)
                    isCollecting = false
                    task.delay(5, function() processed[item] = nil end)
                end
            end
        end
    end
end)
