-- [[ trackerv1.lua - Battery Master (STRICT FORCE TELEPORT) ]] --
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
local MAX_VISUAL_DIST = 150 
local COLLECT_DIST = 60     
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}

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
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) 
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
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if not targetPart then continue end
            
            local pos = targetPart.Position
            local dist = (root.Position - pos).Magnitude

            if dist <= MAX_VISUAL_DIST then
                createV1Path(item, root)
            else
                removeV1Path(item)
            end

            -- STRICT FORCE TELEPORT & COLLECTION
            if dist <= COLLECT_DIST then
                processed[item] = true

                task.spawn(function()
                    local targetCFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- ၁။ Loop ခံပြီး Teleport ကို Force လုပ်မယ် (Server ပြန်ဆွဲတာကို တားဖို့)
                    -- ၀.၂ စက္ကန့်အတွင်းမှာ မူလနေရာပြန်ရောက်မသွားအောင် အတင်းချုပ်ထားတာပါ
                    local startTime = tick()
                    while tick() - startTime < 0.25 do
                        root.CFrame = targetCFrame
                        root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        RunService.RenderStepped:Wait()
                    end
                    
                    -- ၂။ ခုန်ခိုင်းမယ် (Physics refresh လုပ်ဖို့)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- ၃။ Remote ကို Fire လုပ်မယ်
                    AdjustRemote:FireServer(item)
                    
                    -- ၄။ Cleanup
                    task.wait(0.2)
                    removeV1Path(item)
                    
                    task.wait(2.0) -- Cooldown
                    processed[item] = nil
                end)
            end
        end
    end
end)

print("Battery Master (Strict Force Teleport) Loaded.")
