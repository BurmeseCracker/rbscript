-- [[ trackerv1.lua - Battery Master (SMART PROGRESSIVE TP + RETURN) ]] --
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

    local itemsInRange = {}
    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart") or item:FindFirstChild("Handle")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                if dist <= 40 then 
                    table.insert(itemsInRange, {item = item, dist = dist, pos = targetPart.Position})
                end
                
                if dist <= MAX_VISUAL_DIST then createV1Path(item, root) end
            end
        end
    end

    table.sort(itemsInRange, function(a, b) return a.dist < b.dist end)

    local targetData = itemsInRange[1]
    if targetData then
        local item = targetData.item
        local pos = targetData.pos
        
        -- [[ GET BACK TO ORIGINAL PLACE LOGIC START ]] --
        local originalPos = root.CFrame -- Save your current location before TP
        -- [[ GET BACK TO ORIGINAL PLACE LOGIC END ]] --

        processed[item] = true
        
        task.spawn(function()
            local targetCFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            local startTime = tick()
            
            while tick() - startTime < 1 do
                if not item or not item.Parent then break end
                
                root.CFrame = targetCFrame
                root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                if tick() - startTime < 0.1 then
                    AdjustRemote:FireServer(item)
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
                RunService.RenderStepped:Wait()
            end
            
            -- [[ RETURN TO ORIGINAL POSITION ]] --
            root.CFrame = originalPos
            -- [[ RETURN TO ORIGINAL POSITION ]] --

            task.wait(0.2)
            removeV1Path(item)
            task.wait(1.5) 
            processed[item] = nil
        end)
    end
end)

print("Battery Master (Smart Priority 40-200 + Auto Return) Loaded.")
