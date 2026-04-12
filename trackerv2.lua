-- [[ SCRAP MASTER: PILE TRACKER & ITEM COLLECTOR ]] --
local scriptID = "trackerv2" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Folders
local DROP_FOLDER = workspace:WaitForChild("DroppedItems")
local PILE_FOLDER = workspace:WaitForChild("Structures")

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local TRACK_DIST = 100      -- How far to see Scrap Piles
local COLLECT_DIST = 60    -- How far to Bring & Collect Scrap items
local PILE_NAME = "Scrap Pile"
local ITEM_NAME = "Scrap"

local activeBeams = {}
local processed = {}
local isCollecting = false

-- [[ BEAM LOGIC FOR PILES ]] --
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
    beam.Width0, beam.Width1, beam.Texture, beam.TextureSpeed, beam.FaceCamera = 0.4, 0.4, "rbxassetid://44611181", 2, true
    
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

-- Stop existing loops
if _G.ScrapMasterLoop then _G.ScrapMasterLoop:Disconnect() end

-- [[ MAIN MASTER LOOP ]] --
_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- 1. TRACK SCRAP PILES (In Structures)
    if PILE_FOLDER then
        for _, pile in pairs(PILE_FOLDER:GetChildren()) do
            if pile.Name == PILE_NAME then
                local dist = (root.Position - pile:GetPivot().Position).Magnitude
                if dist <= TRACK_DIST then
                    createPath(pile, root)
                else
                    removePath(pile)
                end
            end
        end
    end

    -- 2. BRING & COLLECT SCRAP ITEMS (In DroppedItems)
    if DROP_FOLDER and not isCollecting then
        for _, item in pairs(DROP_FOLDER:GetChildren()) do
            if item.Name == ITEM_NAME and not processed[item] then
                local itemPos = item:GetPivot().Position
                local dist = (root.Position - itemPos).Magnitude

                if dist <= COLLECT_DIST then
                    isCollecting = true
                    processed[item] = true

                    -- Bring item to you
                    item:PivotTo(root.CFrame * CFrame.new(0, -2, 2))
                    
                    task.wait(0.1)
                    PickUpRemote:FireServer(item)
                    
                    task.wait(0.1)
                    if item and item.Parent then
                        AdjustRemote:FireServer(item)
                    end

                    task.wait(0.1)
                    isCollecting = false
                    task.delay(5, function() processed[item] = nil end)
                    break
                end
            end
        end
    end

    -- Cleanup beams for gone piles
    for model, _ in pairs(activeBeams) do
        if not model:IsDescendantOf(workspace) then
            removePath(model)
        end
    end
end)

print("Scrap Master: Tracking Piles & Collecting Items!")
