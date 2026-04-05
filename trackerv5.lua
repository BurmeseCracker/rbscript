local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local CRATE_FOLDER = workspace:WaitForChild("Map"):WaitForChild("Crates")

local MAX_DISTANCE = 500 
local PURPLE_COLOR = ColorSequence.new(Color3.fromRGB(170, 0, 255))

if _G.TrackerV5Loop then _G.TrackerV5Loop:Disconnect() end
_G.v5Beams = _G.v5Beams or {}

local function clearV5()
    for model, data in pairs(_G.v5Beams) do
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
    end
    _G.v5Beams = {}
end

_G.TrackerV5Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv5"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not CRATE_FOLDER then return end

        for _, crate in pairs(CRATE_FOLDER:GetChildren()) do
            local targetPart = crate:FindFirstChild("MainPart")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                if dist <= MAX_DISTANCE then
                    if not _G.v5Beams[crate] then
                        local attP = Instance.new("Attachment", root)
                        local attB = Instance.new("Attachment", targetPart)
                        local beam = Instance.new("Beam", root)
                        beam.Attachment0, beam.Attachment1 = attP, attB
                        beam.Color = PURPLE_COLOR
                        beam.Width0, beam.Width1, beam.Texture, beam.TextureSpeed, beam.FaceCamera = 0.4, 0.4, "rbxassetid://44611181", 2.5, true
                        _G.v5Beams[crate] = {beam = beam, aP = attP, aB = attB}
                    end
                else
                    if _G.v5Beams[crate] then
                        _G.v5Beams[crate].beam:Destroy(); _G.v5Beams[crate].aP:Destroy(); _G.v5Beams[crate].aB:Destroy()
                        _G.v5Beams[crate] = nil
                    end
                end
            end
        end
    else
        clearV5()
        _G.TrackerV5Loop:Disconnect()
        _G.TrackerV5Loop = nil
    end
end)
