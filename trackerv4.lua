-- [[ trackerv4.lua - Fuel Master (FIXED COLLECTION) ]] --
local scriptID = "trackerv4" 

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
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- CONFIG
local TRACK_DIST = 150    
local COLLECT_DIST = 25   -- အကွာအဝေးကို နည်းနည်းလျှော့ထားတယ် (ပိုသေချာအောင်)
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
        if item.Name == TARGET_NAME and not processedItems[item] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- Visual Beam
            if dist <= TRACK_DIST then
                createV4Path(item, root)
            else
                removeV4Path(item)
            end

            -- Sync Collection Logic
            if dist <= COLLECT_DIST then
                processedItems[item] = true
                
                task.spawn(function()
                    -- ၁။ အရင်ဆုံး PickUp လုပ်မယ်
                    PickUpRemote:FireServer(item)
                    
                    -- ၂။ ခဏစောင့်မယ် (Server က inventory ထဲထည့်တာ confirm ဖြစ်အောင်)
                    task.wait(0.2) 
                    
                    -- ၃။ ပြီးမှ Backpack ကို update လုပ်မယ်
                    AdjustRemote:FireServer() -- အချို့ game တွေမှာ parameter မလိုဘူး၊ ရှိသမျှ update လုပ်တာ
                    
                    removeV4Path(item)
                    
                    -- ၄။ ပစ္စည်းတကယ်ပျောက်သွားလား စစ်မယ်
                    task.wait(2)
                    processedItems[item] = nil
                end)
            end
        end
    end
    
    -- Cleanup
    for model, _ in pairs(v4Beams) do
        if not model or not model.Parent or not model:IsDescendantOf(workspace) then
            removeV4Path(model)
        end
    end
end)

print("Fuel Master: Collection Fixed Version Loaded.")
