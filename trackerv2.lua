-- [[ trackerv2.lua - Scrap Master (FULL BEAMS + AUTO-TOGGLE KILL) ]] --
local scriptID = "trackerv2" 
local GITHUB_URL = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/kill.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local DROP_FOLDER = workspace:WaitForChild("DroppedItems")
local PILE_FOLDER = workspace:WaitForChild("Structures") 
local CHAR_FOLDER = workspace:WaitForChild("Characters")

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

-- [[ BEAM SYSTEM ]] --
if _G.ScrapBeams then
    for model, data in pairs(_G.ScrapBeams) do
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
    end
end
_G.ScrapBeams = {} 
local processedItems = {}

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

local function clearAllBeams()
    for model, _ in pairs(_G.ScrapBeams) do removePath(model) end
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
    -- Ensure script stays alive based on global variable
    if _G[scriptID] ~= true then 
        clearAllBeams()
        _G["kill"] = false 
        _G.ScrapMasterLoop:Disconnect()
        _G.ScrapMasterLoop = nil
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not root then return end

    local currentModels = {} 

    -------------------------------------------------------
    -- ၁။ SMART ENEMY CHECK (AUTO ON/OFF)
    -------------------------------------------------------
    local enemyNearby = false
    for _, targetChar in pairs(CHAR_FOLDER:GetChildren()) do
        if targetChar ~= char and targetChar:FindFirstChild("Humanoid") and targetChar.Humanoid.Health > 0 then
            local tRoot = targetChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local dist = (root.Position - tRoot.Position).Magnitude
                if dist <= ATTACK_RANGE then
                    enemyNearby = true
                    break
                end
            end
        end
    end

    if enemyNearby then
        if _G["kill"] ~= true then
            _G["kill"] = true
            task.spawn(function()
                local success, code = pcall(function() return game:HttpGet(GITHUB_URL) end)
                if success then loadstring(code)() end
            end)
        end
        clearAllBeams() 
        return 
    else
        if _G["kill"] == true then
            _G["kill"] = false
        end
    end

    -------------------------------------------------------
    -- ၂။ Scrap Pile Beams & Targets
    -------------------------------------------------------
    local pileTargets = {}
    for _, pile in pairs(PILE_FOLDER:GetChildren()) do
        if pile.Name == PILE_NAME then
            currentModels[pile] = true
            local pilePart = pile.PrimaryPart or pile:FindFirstChildWhichIsA("BasePart")
            if pilePart then
                local dist = (root.Position - pilePart.Position).Magnitude
                
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

    -------------------------------------------------------
    -- ၃။ HIT LOGIC (FIXED Pathing to Melee Folder)
    -------------------------------------------------------
    if tool and #pileTargets > 0 and tick() - lastSwing >= SWING_COOLDOWN then
        -- Find Melee Folder inside Tool
        local meleeFolder = tool:FindFirstChild("Melee")
        if meleeFolder then
            local hitRemote = meleeFolder:FindFirstChild("HitTargets")
            local swingRemote = meleeFolder:FindFirstChild("Swing")
            if hitRemote and swingRemote then
                hitRemote:FireServer(pileTargets)
                swingRemote:FireServer()
                lastSwing = tick()
            end
        end
    end

    -------------------------------------------------------
    -- ၄။ SILENT COLLECT
    -------------------------------------------------------
    for _, item in pairs(DROP_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME and not processedItems[item] then
            local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if itemPart and (root.Position - itemPart.Position).Magnitude <= COLLECT_DIST then
                processedItems[item] = true
                task.spawn(function()
                    PickUpRemote:FireServer(item)
                    AdjustRemote:FireServer(item)
                    task.wait(1)
                    processedItems[item] = nil
                end)
            end
        end
    end
    
    -- Cleanup beams
    for model, _ in pairs(_G.ScrapBeams) do
        if not model or not model.Parent or (model.Parent == PILE_FOLDER and not currentModels[model]) then
            removePath(model)
        end
    end
end)
