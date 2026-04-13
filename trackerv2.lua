-- [[ trackerv2.lua - Scrap Master (COLLECT + AUTO-HIT PILES) ]] --
local scriptID = "trackerv2" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

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
local COLLECT_DIST = 40    -- Bring distance
local ATTACK_RANGE = 40    -- Hit distance
local SWING_COOLDOWN = 0.2 
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
    for model, _ in pairs(activeBeams) do removePath(model) end
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
    if _G[scriptID] ~= true then 
        clearAllBeams()
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not root then return end

    -- 1. AUTO-HIT SCRAP PILES (CYAN BEAM)
    local targets = {}
    local canHit = false
    
    for _, pile in pairs(PILE_FOLDER:GetChildren()) do
        if pile.Name == PILE_NAME then
            local pilePart = pile.PrimaryPart or pile:FindFirstChildWhichIsA("BasePart")
            if pilePart then
                local dist = (root.Position - pilePart.Position).Magnitude
                
                -- Visual Path
                if dist <= TRACK_DIST then
                    createPath(pile, root, Color3.fromRGB(0, 255, 255))
                else
                    removePath(pile)
                end

                -- Hit Detection
                if dist <= ATTACK_RANGE then
                    table.insert(targets, pile)
                    canHit = true
                end
            end
        end
    end

    -- Execute Hit if tool is equipped and cooldown is over
    if canHit and tool and tick() - lastSwing >= SWING_COOLDOWN then
        local hitRemote = tool:FindFirstChild("HitTargets")
        local swingRemote = tool:FindFirstChild("Swing")
        if hitRemote and swingRemote then
            hitRemote:FireServer(targets)
            swingRemote:FireServer()
            lastSwing = tick()
        end
    end

    -- 2. TRACK & BRING DROPPED SCRAP (WHITE BEAM)
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

                -- Bring and Collect
                if dist <= COLLECT_DIST then
                    processedItems[item] = true
                    task.spawn(function()
                        local startTime = tick()
                        while tick() - startTime < 1 do
                            if not item or not item.Parent or not itemPart then break end
                            -- Bring item to you
                            itemPart.CFrame = root.CFrame * CFrame.new(0, 0, -2)
                            -- Remote fire
                            if tick() - startTime < 0.1 then
                                PickUpRemote:FireServer(item)
                                AdjustRemote:FireServer(item)
                            end
                            RunService.RenderStepped:Wait()
                        end
                        removePath(item)
                        task.wait(1.5)
                        processedItems[item] = nil
                    end)
                end
            end
        end
    end
    
    -- Cleanup
    for model, _ in pairs(activeBeams) do
        if not model or not model.Parent then removePath(model) end
    end
end)

print("Scrap Master V2: Auto-Hit + Bring Loaded.")
