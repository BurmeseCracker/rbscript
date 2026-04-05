local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("Structures")
local TARGET_NAME = "Scrap Pile"
local MAX_DISTANCE = 100 

if _G.TrackerV2Loop then _G.TrackerV2Loop:Disconnect() end
_G.activeBeams = _G.activeBeams or {}

-- Beam အားလုံးကို ဖျက်ဆီးပစ်မယ့် function
local function clearAllBeams()
    for model, data in pairs(_G.activeBeams) do
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
    end
    _G.activeBeams = {}
end

local function createPath(model, root)
    if _G.activeBeams[model] then return end
    local targetPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not targetPart then return end

    local attP = Instance.new("Attachment", root)
    local attB = Instance.new("Attachment", targetPart)
    local beam = Instance.new("Beam")
    beam.Attachment0 = attP
    beam.Attachment1 = attB
    beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255)) 
    beam.Width0, beam.Width1 = 0.35, 0.35 
    beam.Texture = "rbxassetid://44611181" 
    beam.TextureSpeed = 2.5 
    beam.FaceCamera = true
    beam.Parent = root
    
    _G.activeBeams[model] = {beam = beam, aP = attP, aB = attB}
end

_G.TrackerV2Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv2"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if item:IsA("Model") and item.Name == TARGET_NAME then
                local dist = (root.Position - item:GetPivot().Position).Magnitude
                if dist <= MAX_DISTANCE then
                    createPath(item, root)
                else
                    if _G.activeBeams[item] then
                        _G.activeBeams[item].beam:Destroy()
                        _G.activeBeams[item].aP:Destroy()
                        _G.activeBeams[item].aB:Destroy()
                        _G.activeBeams[item] = nil
                    end
                end
            end
        end
    else
        -- Menu မှာ OFF လိုက်တာနဲ့ အကုန်ဖြတ်မယ်
        clearAllBeams()
        _G.TrackerV2Loop:Disconnect()
        _G.TrackerV2Loop = nil
    end
end)
