-- [[ trackerv2.lua - Scrap Master (FIXED SYNC & DISABLE) ]] --
local scriptID = "trackerv2" 

-- REMOVED THE REPEAT LOOP TO FIX THE DISABLE BUG

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local DROP_FOLDER = workspace:WaitForChild("DroppedItems")
local PILE_FOLDER = workspace:WaitForChild("Structures") 

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local TRACK_DIST = 100    
local COLLECT_DIST = 15    
local ATTACK_RANGE = 40    
local SWING_COOLDOWN = 0.1
local lastSwing = 0

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

local function clearAllBeams()
    for model, _ in pairs(activeBeams) do 
        removePath(model) 
    end
end

local function createPath(model, root, color)
    if activeBeams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
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

-- [[ MAIN LOOP ]] --
if _G.ScrapMasterLoop then _G.ScrapMasterLoop:Disconnect() end

_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    -- IF MENU IS OFF, THIS NOW RUNS IMMEDIATELY
    if _G[scriptID] ~= true then 
        clearAllBeams()
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not root then return end

    -- 1. AUTO-HIT SCRAP PILES
    local targets = {}
    local canHit = false
    
    for _, pile in pairs(PILE_FOLDER:GetChildren()) do
        if pile.Name == PILE_NAME then
            local pilePart = pile.PrimaryPart or pile:FindFirstChildWhichIsA("BasePart")
            if pilePart then
                local dist = (root.Position - pilePart.Position).Magnitude
                
                if dist <= TRACK_DIST then
                    createPath(pile, root, Color3.fromRGB(0, 255, 255))
                else
                    removePath(pile)
                end

                if dist <= ATTACK_RANGE then
                    table.insert(targets, pile)
                    canHit = true
                end
            end
        end
    end

    if canHit and tool and tick() - lastSwing >= SWING_COOLDOWN then
        local hitRemote = tool:FindFirstChild("HitTargets")
        local swingRemote = tool:FindFirstChild("Swing")
        if hitRemote and swingRemote then
            hitRemote:FireServer(targets)
            swingRemote:FireServer()
            lastSwing = tick()
        end
    end

    -- 2. TRACK & COLLECT DROPPED SCRAP
    for _, item in pairs(DROP_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME and not processedItems[item] then
            local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if itemPart then
                local dist = (root.Position - itemPart.Position).Magnitude

                if dist <= TRACK_DIST then
                    createPath(item, root, Color3.fromRGB(255, 255, 255))
                else
                    removePath(item)
                end

                if dist <= COLLECT_DIST then
                    processedItems[item] = true
                    task.spawn(function()
                        PickUpRemote:FireServer(item)
                        AdjustRemote:FireServer(item)
                        task.wait(0.2)
                        removePath(item)
                        task.wait(1)
                        processedItems[item] = nil
                    end)
                end
            end
        end
    end
    
    for model, _ in pairs(activeBeams) do
        if not model or not model.Parent then removePath(model) end
    end
end)

print("Scrap Master V2: Sync Fixed & Fully Disablable.")
