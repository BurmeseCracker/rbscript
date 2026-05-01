-- [[ trackerv2.lua - Scrap & Screws Master (FULL FIX) ]] --
local scriptID = "trackerv2" 
local GITHUB_URL = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/kill.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Better Folder Detection
local function findFolder(names)
    for _, name in pairs(names) do
        local f = workspace:FindFirstChild(name)
        if f then return f end
    end
    return nil
end

local DROP_FOLDER = findFolder({"DroppedItems", "Items", "Debris"})
local PILE_FOLDER = findFolder({"Structures", "Map", "Crates", "Interactables"})
local CHAR_FOLDER = findFolder({"Characters", "Players", "NPCs"})

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local PickUpRemote = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")

local TRACK_DIST = 100    
local COLLECT_DIST = 20 -- Increased slightly for reliability
local ATTACK_RANGE = 50 -- Matches your kill script range   
local SWING_COOLDOWN = 0.1
local lastSwing = 0

_G.ScrapBeams = _G.ScrapBeams or {} 
local processedItems = {}

-- [[ BEAM FUNCTIONS ]] --
local function removePath(model)
    local data = _G.ScrapBeams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        _G.ScrapBeams[model] = nil
    end
end

local function createPath(model, root, color)
    if _G.ScrapBeams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(color)
    beam.Width0, beam.Width1 = 0.35, 0.35
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    _G.ScrapBeams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.ScrapMasterLoop then _G.ScrapMasterLoop:Disconnect() end

_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(_G.ScrapBeams) do removePath(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not root then return end

    -------------------------------------------------------
    -- 1. ENEMY CHECK (AUTO-KILL TOGGLE)
    -------------------------------------------------------
    local enemyNearby = false
    if CHAR_FOLDER then
        for _, enemy in pairs(CHAR_FOLDER:GetChildren()) do
            if enemy ~= char and enemy:IsA("Model") then
                local eHum = enemy:FindFirstChildOfClass("Humanoid")
                local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                if eRoot and eHum and eHum.Health > 0 then
                    if (root.Position - eRoot.Position).Magnitude <= ATTACK_RANGE then
                        enemyNearby = true
                        break
                    end
                end
            end
        end
    end

    if enemyNearby then
        if not _G["kill"] then
            _G["kill"] = true
            task.spawn(function()
                local success, code = pcall(function() return game:HttpGet(GITHUB_URL) end)
                if success then loadstring(code)() end
            end)
        end
        -- Hide beams when fighting to reduce lag
        for model, _ in pairs(_G.ScrapBeams) do removePath(model) end
        return 
    else
        _G["kill"] = false
    end

    -------------------------------------------------------
    -- 2. SCRAP PILES (BEAMS + ATTACK)
    -------------------------------------------------------
    local currentModels = {}
    local pileTargets = {}
    
    if PILE_FOLDER then
        for _, pile in pairs(PILE_FOLDER:GetDescendants()) do -- Use GetDescendants to find deep piles
            if pile.Name == "Scrap Pile" or pile:FindFirstChild("Scrap") then
                currentModels[pile] = true
                local pPart = pile:IsA("BasePart") and pile or pile.PrimaryPart or pile:FindFirstChildWhichIsA("BasePart")
                if pPart then
                    local dist = (root.Position - pPart.Position).Magnitude
                    
                    if dist <= TRACK_DIST then
                        createPath(pile, root, Color3.fromRGB(0, 255, 255))
                    else
                        removePath(pile)
                    end

                    if dist <= ATTACK_RANGE then
                        table.insert(pileTargets, pile)
                    end
                end
            end
        end

        if tool and #pileTargets > 0 and tick() - lastSwing >= SWING_COOLDOWN then
            local container = tool:FindFirstChild("Melee") or tool
            local hr = container:FindFirstChild("HitTargets")
            local sr = container:FindFirstChild("Swing")
            if hr and sr then
                hr:FireServer(pileTargets)
                sr:FireServer()
                lastSwing = tick()
            end
        end
    end

    -------------------------------------------------------
    -- 3. SILENT COLLECT (SCRAP + SCREWS)
    -------------------------------------------------------
    if DROP_FOLDER and PickUpRemote then
        for _, item in pairs(DROP_FOLDER:GetChildren()) do
            if (item.Name == "Scrap" or item.Name == "Screws") and not processedItems[item] then
                local iPart = item:IsA("BasePart") and item or item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if iPart then
                    local dist = (root.Position - iPart.Position).Magnitude
                    if dist <= COLLECT_DIST then
                        processedItems[item] = true
                        task.spawn(function()
                            PickUpRemote:FireServer(item)
                            -- Force adjustment remote if it exists
                            local adj = Remotes:FindFirstChild("Tools") and Remotes.Tools:FindFirstChild("AdjustBackpack")
                            if adj then adj:FireServer(item) end
                            
                            task.wait(0.5)
                            processedItems[item] = nil
                        end)
                    end
                end
            end
        end
    end

    -- CLEANUP OLD BEAMS
    for model, _ in pairs(_G.ScrapBeams) do
        if not model or not model.Parent or (not currentModels[model]) then
            removePath(model)
        end
    end
end)

print("Scrap & Screws Master: Fully Fixed & Optimized.")
