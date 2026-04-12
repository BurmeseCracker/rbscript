-- [[ trackerv1.lua - Battery Master ACTIVE FIX ]] --
local scriptID = "trackerv1" 

-- Force wait until the menu actually sets the value to true
if _G[scriptID] ~= true then
    repeat task.wait(0.5) until _G[scriptID] == true
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

local MAX_DISTANCE = 200
local BRING_DIST = 60
local COLLECT_DIST = 15 -- Increased slightly for better reliability
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}
local isCollecting = false

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
    beam.Texture = "rbxassetid://44611181"
    beam.TextureSpeed = 2; beam.FaceCamera = true
    v1Beams[model] = {beam = beam, aP = attP, aB = attB}
end

-- Clean up any old loops before starting a new one
if _G.BatteryMasterLoop then 
    _G.BatteryMasterLoop:Disconnect() 
    _G.BatteryMasterLoop = nil
end

print("Battery Master: Script Linked and Waiting for Logic")

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    -- If the menu toggle goes OFF, stop the visuals and wait
    if _G[scriptID] ~= true then 
        for model, _ in pairs(v1Beams) do removeV1Path(model) end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            local dist = (root.Position - pos).Magnitude

            if dist <= MAX_DISTANCE then
                createV1Path(item, root)
                
                -- BRING LOGIC
                if dist <= BRING_DIST then
                    item:PivotTo(root.CFrame * CFrame.new(0, -2, -3))
                    
                    -- COLLECT LOGIC
                    if dist <= COLLECT_DIST and not processed[item] and not isCollecting then
                        isCollecting = true
                        processed[item] = true
                        
                        task.spawn(function()
                            task.wait(0.1)
                            PickUpRemote:FireServer(item)
                            task.wait(0.2)
                            if item and item.Parent then AdjustRemote:FireServer(item) end
                            task.wait(0.2)
                            isCollecting = false
                            -- Item reset delay
                            task.wait(5)
                            processed[item] = nil
                        end)
                    end
                end
            else
                removeV1Path(item)
            end
        end
    end
end)
