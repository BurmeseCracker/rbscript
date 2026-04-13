-- [[ trackerv1.lua - Battery Master (FULL TELEPORT FORCE) ]] --
local scriptID = "trackerv1" 

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
local MAX_VISUAL_DIST = 500  -- ၅၀၀ အထိမြှင့်ထားမှ အဝေးကပစ္စည်းကို လှမ်းဖမ်းမိမှာပါ
local COLLECT_DIST = 100     -- ၁၀၀ အကွာအဝေးရောက်ရင် Teleport စလုပ်မယ်
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
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            -- Target Part ကို ပိုသေချာအောင်ရှာမယ်
            local targetPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")) or item
            if not targetPart or not targetPart:IsA("BasePart") then continue end
            
            local pos = targetPart.Position
            local dist = (root.Position - pos).Magnitude

            -- 1. Visual Beam (Show up to 500 studs)
            if dist <= MAX_VISUAL_DIST then
                createV1Path(item, root)
            else
                removeV1Path(item)
            end

            -- 2. Force Teleport & Collection
            if dist <= COLLECT_DIST then
                processed[item] = true
                print("Battery Found! Attempting Force Teleport...") -- Console (F9) မှာ စစ်လို့ရအောင်

                task.spawn(function()
                    local targetCFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- Teleport Loop (0.3s အထိ Server ကို Force လုပ်မယ်)
                    local startTime = tick()
                    while tick() - startTime < 0.3 do
                        root.CFrame = targetCFrame
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0) -- Velocity reset
                        RunService.RenderStepped:Wait()
                    end
                    
                    -- Instant Jump (Force physics update)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- Remote Fire
                    AdjustRemote:FireServer(item)
                    
                    task.wait(0.2)
                    removeV1Path(item)
                    
                    task.wait(2.0) -- Cooldown
                    processed[item] = nil
                    print("Battery Collected successfully.")
                end)
            end
        end
    end
    
    -- Cleanup orphaned beams
    for model, _ in pairs(v1Beams) do
        if not model or not model.Parent or not model:IsDescendantOf(workspace) then
            removeV1Path(model)
        end
    end
end)

print("Battery Master (Force TP + Range 500) Loaded.")
