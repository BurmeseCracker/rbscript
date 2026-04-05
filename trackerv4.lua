local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local MAX_DISTANCE = 200 
local TARGET_NAMES = { ["Fuel"] = true, ["Refined Fuel"] = true }

if _G.TrackerV4Loop then _G.TrackerV4Loop:Disconnect() end
_G.v4Beams = _G.v4Beams or {}

local function clearV4()
    for model, data in pairs(_G.v4Beams) do
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
    end
    _G.v4Beams = {}
end

_G.TrackerV4Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv4"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if item:IsA("Model") and TARGET_NAMES[item.Name] then
                local dist = (root.Position - item:GetPivot().Position).Magnitude
                if dist <= MAX_DISTANCE then
                    if not _G.v4Beams[item] then
                        local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                        if targetPart then
                            local attP = Instance.new("Attachment", root)
                            local attB = Instance.new("Attachment", targetPart)
                            local beam = Instance.new("Beam", root)
                            beam.Attachment0, beam.Attachment1 = attP, attB
                            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0)) -- Red
                            beam.Width0, beam.Width1, beam.Texture, beam.TextureSpeed, beam.FaceCamera = 0.35, 0.35, "rbxassetid://44611181", 2.5, true
                            _G.v4Beams[item] = {beam = beam, aP = attP, aB = attB}
                        end
                    end
                else
                    if _G.v4Beams[item] then
                        _G.v4Beams[item].beam:Destroy(); _G.v4Beams[item].aP:Destroy(); _G.v4Beams[item].aB:Destroy()
                        _G.v4Beams[item] = nil
                    end
                end
            end
        end
    else
        clearV4()
        _G.TrackerV4Loop:Disconnect()
        _G.TrackerV4Loop = nil
    end
end)

