-- [[ trackerv2.lua - Scrap Master (NON-CONFLICT EDITION) ]] --
local scriptID = "trackerv2" 
local GITHUB_URL = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/kill.lua"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local DROP_FOLDER = workspace:FindFirstChild("DroppedItems") or workspace:FindFirstChild("Items")
local PILE_FOLDER = workspace:FindFirstChild("Structures") or (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Crates"))
local CHAR_FOLDER = workspace:FindFirstChild("Characters")

local Remotes = ReplicatedStorage:WaitForChild("Remotes", 5)
local PickUpRemote = Remotes and Remotes:FindFirstChild("Interaction") and Remotes.Interaction:FindFirstChild("PickUpItem")

local TRACK_DIST = 100    
local COLLECT_DIST = 18   
local ATTACK_RANGE = 40    
local SWING_COOLDOWN = 0.1
local lastSwing = 0

_G.ScrapBeams = _G.ScrapBeams or {} 
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

if _G.ScrapMasterLoop then _G.ScrapMasterLoop:Disconnect() end

_G.ScrapMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(_G.ScrapBeams) do removePath(model) end
        _G["kill"] = false 
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not root then return end

    -------------------------------------------------------
    -- ၁။ ENEMY CHECK & AUTO-KILL
    -------------------------------------------------------
    local enemyNearby = false
    if CHAR_FOLDER then
        for _, enemy in pairs(CHAR_FOLDER:GetChildren()) do
            if enemy ~= char and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
                local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                if eRoot and (root.Position - eRoot.Position).Magnitude <= ATTACK_RANGE then
                    enemyNearby = true
                    break
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
        -- STOP EVERYTHING ELSE IN THIS SCRIPT SO KILL.LUA CAN WORK
        for model, _ in pairs(_G.ScrapBeams) do removePath(model) end
        return 
    else
        _G["kill"] = false
    end

    -------------------------------------------------------
    -- ၂။ SCRAP PILES (Only runs if NO enemy is nearby)
    -------------------------------------------------------
    local pileTargets = {}
    if PILE_FOLDER then
        for _, pile in pairs(PILE_FOLDER:GetChildren()) do
            if pile.Name == "Scrap Pile" then
                local pPart = pile.PrimaryPart or pile:FindFirstChildWhichIsA("BasePart")
                if pPart then
                    local dist = (root.Position - pPart.Position).Magnitude
                    if dist <= TRACK_DIST then
                        -- Beam logic here...
                        if dist <= ATTACK_RANGE then table.insert(pileTargets, pile) end
                    else
                        removePath(pile)
                    end
                end
            end
        end

        -- SCRAP HIT LOGIC
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
    -- ၃။ SILENT COLLECT
    -------------------------------------------------------
    if DROP_FOLDER and PickUpRemote then
        for _, item in pairs(DROP_FOLDER:GetChildren()) do
            if item.Name == "Scrap" and not processedItems[item] then
                local iPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if iPart and (root.Position - iPart.Position).Magnitude <= COLLECT_DIST then
                    processedItems[item] = true
                    task.spawn(function()
                        PickUpRemote:FireServer(item)
                        task.wait(0.5)
                        processedItems[item] = nil
                    end)
                end
            end
        end
    end
end)
