-- TRACKER V3 (ITEM TRACKER) WITH AUTO-CLEANUP
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")
local MAX_DISTANCE = 100 

local TARGET_NAMES = {
    ["Chips"] = true, ["Bloxiade"] = true, ["Beans"] = true, ["Bloxy Cola"] = true
}

if _G.TrackerV3Loop then _G.TrackerV3Loop:Disconnect() end
_G.v3Beams = _G.v3Beams or {}

local function clearV3()
    for model, data in pairs(_G.v3Beams) do
        if data.beam then data.beam:Destroy() end
        if data.aP then data.aP:Destroy() end
        if data.aB then data.aB:Destroy() end
    end
    _G.v3Beams = {}
end

_G.TrackerV3Loop = RunService.Heartbeat:Connect(function()
    if _G["trackerv3"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if item:IsA("Model") and TARGET_NAMES[item.Name] then
                local dist = (root.Position - item:GetPivot().Position).Magnitude
                if dist <= MAX_DISTANCE then
                    if not _G.v3Beams[item] then
                        local attP, attB = Instance.new("Attachment", root), Instance.new("Attachment", item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart"))
                        local beam = Instance.new("Beam", root)
                        beam.Attachment0, beam.Attachment1 = attP, attB
                        beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0)) -- Lime Green
                        beam.Width0, beam.Width1, beam.Texture, beam.TextureSpeed, beam.FaceCamera = 0.35, 0.35, "rbxassetid://44611181", 2.5, true
                        _G.v3Beams[item] = {beam = beam, aP = attP, aB = attB}
                    end
                else
                    if _G.v3Beams[item] then
                        _G.v3Beams[item].beam:Destroy(); _G.v3Beams[item].aP:Destroy(); _G.v3Beams[item].aB:Destroy()
                        _G.v3Beams[item] = nil
                    end
                end
            end
        end
    else
        -- OFF လိုက်ရင် အကုန်ရှင်းပစ်မယ်
        clearV3()
        _G.TrackerV3Loop:Disconnect()
        _G.TrackerV3Loop = nil
    end
end)
