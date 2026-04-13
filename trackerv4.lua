-- [[ trackerv4.lua - Fuel Master (BACKPACK SYNC FIXED) ]] --
local scriptID = "trackerv4" 

if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
-- Backpack script ထဲက logic အတိုင်း remote ကို ယူမယ်
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local TRACK_DIST = 150    
local COLLECT_DIST = 20   -- Range ကို backpack script ထဲက 12+ အတိုင်း ပိုနီးအောင် ထားတယ်
local TARGET_NAME = "Fuel"

local v4Beams = {}
local processedItems = {}

-- [[ BEAM LOGIC ]] --
local function removeV4Path(model)
    local data = v4Beams[model]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        v4Beams[model] = nil
    end
end

local function createV4Path(model, root)
    if v4Beams[model] then return end
    local targetPart = model:FindFirstChild("Union") or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam", root)
    beam.Attachment0, beam.Attachment1 = attP, attB
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) 
    beam.Width0, beam.Width1 = 0.4, 0.4
    beam.Texture = "rbxassetid://44611181"; beam.TextureSpeed = 2; beam.FaceCamera = true
    v4Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- [[ MAIN LOOP ]] --
if _G.FuelMasterLoop then _G.FuelMasterLoop:Disconnect() end

_G.FuelMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v4Beams) do removeV4Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        -- Item name စစ်ဆေးမယ်
        if item.Name == TARGET_NAME and not processedItems[item] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- Visual Beam ပြမယ်
            if dist <= TRACK_DIST then
                createV4Path(item, root)
            else
                removeV4Path(item)
            end

            -- Backpack Logic အရ Pickup လုပ်မယ်
            if dist <= COLLECT_DIST then
                processedItems[item] = true
                
                task.spawn(function()
                    -- Backpack script logic အတိုင်း item model ကို တိုက်ရိုက်ပို့မယ်
                    AdjustRemote:FireServer(item)
                    
                    -- ခေတ္တစောင့်ပြီး Visual ဖျောက်မယ်
                    task.wait(0.2)
                    removeV4Path(item)
                    
                    -- Cooldown (ပစ္စည်း တကယ် ပျောက်/မပျောက် စောင့်ကြည့်မယ်)
                    task.wait(1.5)
                    processedItems[item] = nil
                end)
            end
        end
    end
    
    -- Orphaned beams ရှင်းမယ်
    for model, _ in pairs(v4Beams) do
        if not model or not model.Parent or not model:IsDescendantOf(workspace) then
            removeV4Path(model)
        end
    end
end)

print("Fuel Master: Backpack-Style Sync Loaded.")
