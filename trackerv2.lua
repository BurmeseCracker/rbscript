-- [[ trackerv2.lua - Scrap Master (VISUAL BEAMS + REMOTE COLLECT) ]] --
local scriptID = "trackerv2" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Folders
local DROP_FOLDER = workspace:WaitForChild("DroppedItems") -- Where Scrap items drop
local PILE_FOLDER = workspace:WaitForChild("Structures")   -- Where Piles are located

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local TRACK_DIST = 150     -- Distance to see Beams
local COLLECT_DIST = 40    -- Manual range to auto-fire the pickup remote
local ITEM_NAME = "Scrap"
local PILE_NAME = "Scrap Pile"

local activeBeams = {}
local processedItems = {}

-- [[ BEAM LOGIC ]] --
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

local function createPath(model, root, color)
    if activeBeams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(color)
    beam.Width0, beam.Width1 = 0.35, 0.35
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

if _G.ScrapMasterLoop then _G.ScrapMasterLoop:Disconnect() end

_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(activeBeams) do removePath(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- [[ 1. TRACK SCRAP PILES (CYAN BEAMS) ]] --
    for _, pile in pairs(PILE_FOLDER:GetChildren()) do
        if pile.Name == PILE_NAME then
            local dist = (root.Position - pile:GetPivot().Position).Magnitude
            if dist <= TRACK_DIST then
                createPath(pile, root, Color3.fromRGB(0, 255, 255))
            else
                removePath(pile)
            end
        end
    end

    -- [[ 2. TRACK & COLLECT DROPPED SCRAP (WHITE BEAMS) ]] --
    for _, item in pairs(DROP_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- Show Beam for loose items
            if dist <= TRACK_DIST and not processedItems[item] then
                createPath(item, root, Color3.fromRGB(255, 255, 255))
            else
                removePath(item)
            end

            -- Auto-PickUp when you walk close enough
            if dist <= COLLECT_DIST and not processedItems[item] then
                processedItems[item] = true
                removePath(item)
                
                task.spawn(function()
                    local start = tick()
                    -- Spam the remote briefly to ensure capture
                    while tick() - start < 1.0 and item and item.Parent do
                        PickUpRemote:FireServer(item)
                        task.wait(0.1)
                    end
                    
                    if item and item.Parent then AdjustRemote:FireServer(item) end
                    task.wait(2)
                    processedItems[item] = nil
                end)
            end
        end
    end
end)

print("Scrap Master (Visuals Only) Loaded.")
