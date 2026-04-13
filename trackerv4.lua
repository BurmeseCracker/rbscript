-- [[ trackerv4.lua - Fuel Master (NO DISTANCE LIMIT) ]] --
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
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local TRACK_DIST = 300    -- ပစ္စည်းလှမ်းမြင်ရမယ့်အကွာအဝေး (Visual Only)
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
        -- Distance မစစ်တော့ဘဲ Name တူတာနဲ့ တန်းလုပ်မယ်
        if item.Name == TARGET_NAME and not processedItems[item] then
            processedItems[item] = true -- Repeat မဖြစ်အောင် Lock လုပ်မယ်
            
            -- Visual အတွက် Beam ပြပေးမယ်
            createV4Path(item, root)

            task.spawn(function()
                -- Backpack script logic အတိုင်း item ကို တန်းသိမ်းမယ်
                AdjustRemote:FireServer(item)
                
                -- သိမ်းပြီးရင် Beam ကို 0.2s နေရင်ဖျက်မယ်
                task.wait(0.2)
                removeV4Path(item)
                
                -- 1 စက္ကန့်နေမှ နောက်တစ်ခါ ထပ်စစ်မယ်
                task.wait(1)
                processedItems[item] = nil
            end)
        end
    end
    
    -- ပစ္စည်းမရှိတော့ရင် Beam ရှင်းမယ်
    for model, _ in pairs(v4Beams) do
        if not model or not model.Parent or not model:IsDescendantOf(workspace) then
            removeV4Path(model)
        end
    end
end)

print("Fuel Master: No Collect Distance (Instant Pick) Loaded.")
