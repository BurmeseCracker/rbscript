-- [[ trackerv1.lua - Battery Master (BACKPACK SYNC FIXED) ]] --
local scriptID = "trackerv1" 

-- Wait for Menu Toggle
if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local MAX_VISUAL_DIST = 150 -- Beam မြင်ရမယ့် အကွာအဝေး
local COLLECT_DIST = 30     -- အနားရောက်မှ ကောက်မယ့် အကွာအဝေး
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}

-- [[ BEAM LOGIC ]] --
local function removeV1Path(model)
    local data = v1Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v1Beams[model] = nil
    end
end

local function createV1Path(model, root)
    if v1Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart") or model:FindFirstChild("Handle")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) -- Yellow
    beam.Width0, beam.Width1 = 0.5, 0.5
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    v1Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.BatteryMasterLoop then _G.BatteryMasterLoop:Disconnect() end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v1Beams) do removeV1Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- 1. SHOW BEAMS (Visual Only)
            if dist <= MAX_VISUAL_DIST then
                createV1Path(item, root)
            else
                removeV1Path(item)
            end

            -- 2. BACKPACK SYNC COLLECTION
            -- အရင်ကလို PickUpRemote မသုံးတော့ဘဲ Backpack logic အတိုင်း တိုက်ရိုက်သိမ်းမယ်
            if dist <= COLLECT_DIST then
                processed[item] = true

                task.spawn(function()
                    -- Server ဆီကို item model တိုက်ရိုက်ပို့ပြီး သိမ်းခိုင်းမယ်
                    AdjustRemote:FireServer(item)
                    
                    task.wait(0.2)
                    removeV1Path(item)
                    
                    task.wait(1.5) -- Cooldown နည်းနည်းလျှော့ထားတယ်
                    processed[item] = nil
                end)
            end
        end
    end
    
    -- Orphaned beams ရှင်းမယ် (ပစ္စည်းပျောက်သွားရင် beam ဖျက်မယ်)
    for model, _ in pairs(v1Beams) do
        if not model or not model.Parent or not model:IsDescendantOf(workspace) then
            removeV1Path(model)
        end
    end
end)

print("Battery Master (Backpack Sync Mode) Loaded.")
