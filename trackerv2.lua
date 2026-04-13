-- [[ trackerv2.lua - Scrap Master (TOTAL BEAM FIX) ]] --
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
    -- ၁။ MENU OFF ရင် ချက်ချင်း Beam အကုန်ဖျက်မယ်
    if _G[scriptID] ~= true then 
        clearAllBeams()
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local tool = char and char:FindFirstChildOfClass("Tool")
    if not root then return end

    -- ၂။ Scrap Pile များ (Cyan Beam)
    local currentPiles = {}
    local targets = {}
    local canHit = false
    
    for _, pile in pairs(PILE_FOLDER:GetChildren()) do
        if pile.Name == PILE_NAME then
            currentPiles[pile] = true -- လက်ရှိရှိနေတဲ့ pile ကို မှတ်ထားမယ်
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

    -- ၃။ Auto-Hit Logic
    if canHit and tool and tick() - lastSwing >= SWING_COOLDOWN then
        local hitRemote = tool:FindFirstChild("HitTargets")
        local swingRemote = tool:FindFirstChild("Swing")
        if hitRemote and swingRemote then
            hitRemote:FireServer(targets)
            swingRemote:FireServer()
            lastSwing = tick()
        end
    end

    -- ၄။ Silent Collect (Dropped Scrap)
    for _, item in pairs(DROP_FOLDER:GetChildren()) do
        if item.Name == ITEM_NAME and not processedItems[item] then
            local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if itemPart then
                local dist = (root.Position - itemPart.Position).Magnitude
                if dist <= COLLECT_DIST then
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
    end
    
    -- ၅။ (CRITICAL FIX) ရှိမနေတော့တဲ့ model တွေရဲ့ beam တွေကို အတင်းဖျက်မယ်
    for model, _ in pairs(activeBeams) do
        if not model or not model.Parent or (model.Parent == PILE_FOLDER and not currentPiles[model]) then
            removePath(model)
        end
    end
end)

print("Scrap Master V2: Beam Removal Fix Loaded.")
