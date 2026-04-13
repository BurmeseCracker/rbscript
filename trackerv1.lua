-- [[ trackerv1.lua - Battery Master (SMART PROGRESSIVE TP) ]] --
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
local MAX_VISUAL_DIST = 100
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

    -- အနားကပစ္စည်းကို အရင်ရှာဖို့အတွက် ပစ္စည်းစာရင်းကို အကွာအဝေးအလိုက် စီမယ်
    local itemsInRange = {}
    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                if dist <= 40 then -- Max limit 200
                    table.insert(itemsInRange, {item = item, dist = dist, pos = targetPart.Position})
                end
                
                -- Visual Beam (500 studs အထိပြမယ်)
                if dist <= MAX_VISUAL_DIST then createV1Path(item, root) end
            end
        end
    end

    -- အနီးဆုံးပစ္စည်းကို အပေါ်ဆုံးရောက်အောင် စီလိုက်တာ (Sorting)
    table.sort(itemsInRange, function(a, b) return a.dist < b.dist end)

    -- ပစ္စည်းရှိရင် အနီးဆုံးတစ်ခုကိုပဲ Teleport အရင်လုပ်မယ်
    local targetData = itemsInRange[1]
    if targetData then
        local item = targetData.item
        local pos = targetData.pos
        local currentDist = targetData.dist

        -- ပထမဆုံး 40 အတွင်းရှိတာကို အရင်ကောက်မယ်၊ ပြီးမှ 200 အထိ တိုးသွားမယ်
        -- (Sorting လုပ်ထားတဲ့အတွက် 40 ထဲမှာရှိနေရင် သူက နံပါတ် ၁ အနေနဲ့ အရင်ပါလာမှာပါ)
        processed[item] = true
        
        task.spawn(function()
            local targetCFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            local startTime = tick()
            
            -- Force Loop 10 seconds (Auto-break ပါမယ်)
            while tick() - startTime < 5 do
                if not item or not item.Parent then break end
                
                root.CFrame = targetCFrame
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                if tick() - startTime < 0.1 then
                    AdjustRemote:FireServer(item)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                RunService.RenderStepped:Wait()
            end
            
            task.wait(0.2)
            removeV1Path(item)
            task.wait(1.5) -- Priority collection အတွက် cooldown နည်းနည်းလျှော့ပေးထားတယ်
            processed[item] = nil
        end)
    end
end)

print("Battery Master (Smart Priority 40-200) Loaded.")
