-- [[ trackerv4.lua - Fuel Master (WITH COLLECT DISTANCE) ]] --
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
local TRACK_DIST = 100    -- ပစ္စည်းကို အနီရောင်တန်းလေးနဲ့ လှမ်းမြင်ရမယ့် အကွာအဝေး
local COLLECT_DIST = 60   -- ပစ္စည်းကို တကယ်ကောက်မယ့် အကွာအဝေး (အနားရောက်မှကောက်မယ်)
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

            -- ၁။ Visual Beam ပြသခြင်း (TRACK_DIST အတွင်းရှိရင် Beam ပြမယ်)
            if dist <= TRACK_DIST then
                createV4Path(item, root)
            else
                removeV4Path(item)
            end

            -- ၂။ ပစ္စည်းသိမ်းခြင်း (COLLECT_DIST အတွင်း ရောက်မှသာ Fire လုပ်မယ်)
            if dist <= COLLECT_DIST then
                processedItems[item] = true 

                task.spawn(function()
                    -- Backpack remote ကို fire လုပ်မယ်
                    AdjustRemote:FireServer(item)
                    
                    task.wait(0.2)
                    removeV4Path(item)
                    
                    -- ၁ စက္ကန့် Cooldown ထားမယ်
                    task.wait(1)
                    processedItems[item] = nil
                end)
            end
        end
    end
    
    -- ပစ္စည်းမရှိတော့ရင် Beam ရှင်းမယ်
    for model, _ in pairs(v4Beams) do
        if not model or not model.Parent or not model:IsDescendantOf(workspace) then
            removeV4Path(model)
        end
    end
end)

print("Fuel Master: Collect Distance (Limit) Enabled.")
