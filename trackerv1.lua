-- [[ trackerv1.lua - Battery Master (DEBUG & FORCE TP) ]] --
local scriptID = "trackerv1" 

-- Force start the logic even if the menu variable is slow to update
_G[scriptID] = true 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- Ensure the folder exists
local SEARCH_FOLDER = workspace:FindFirstChild("DroppedItems")
if not SEARCH_FOLDER then
    warn("CRITICAL: DroppedItems folder not found in Workspace!")
end

local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local PickUpRemote = Remotes and Remotes:FindFirstChild("Interaction"):FindFirstChild("PickUpItem")
local AdjustRemote = Remotes and Remotes:FindFirstChild("Tools"):FindFirstChild("AdjustBackpack")

-- Config
local TRIGGER_DIST = 40    -- You must be within 40 studs to TP
local TARGET_NAMES = {["Battery"] = true, ["Battery Pack"] = true}

local v1Beams = {}
local processed = {}
local isCollecting = false

-- [[ BEAM LOGIC ]] --
local function createV1Path(model, root)
    if v1Beams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
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

if _G.BatteryMasterLoop then _G.BatteryMasterLoop:Disconnect() end

_G.BatteryMasterLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    local items = SEARCH_FOLDER and SEARCH_FOLDER:GetChildren() or {}
    
    for _, item in pairs(items) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local pos = item:GetPivot().Position
            local dist = (root.Position - pos).Magnitude

            -- TRIGGER TELEPORT
            if dist <= TRIGGER_DIST then
                isCollecting = true
                processed[item] = true
                print("DEBUG: Teleporting to " .. item.Name .. " at distance: " .. math.floor(dist))
                
                task.spawn(function()
                    -- 1. SNAPS YOU TO ITEM
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- 2. WAIT FOR SERVER
                    task.wait(0.15)
                    
                    -- 3. FORCE ITEM TO FEET & COLLECT
                    local startTime = tick()
                    while tick() - startTime < 1.0 and item and item.Parent do
                        item:PivotTo(root.CFrame * CFrame.new(0, -3, 0))
                        if PickUpRemote then PickUpRemote:FireServer(item) end
                        RunService.Heartbeat:Wait()
                    end
                    
                    if AdjustRemote and item and item.Parent then AdjustRemote:FireServer(item) end
                    
                    task.wait(0.1)
                    isCollecting = false
                    task.delay(3, function() processed[item] = nil end)
                end)
                break 
            end
        end
    end
end)

print("Battery Master Loaded! Walk within 40 studs of a Battery to TP.")
