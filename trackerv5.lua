-- [[ trackerv5.lua - Crate Master (AUTO-REMOVE LINE ON OPEN) ]] --
local scriptID = "trackerv5"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local CRATE_FOLDER = workspace:WaitForChild("Map"):WaitForChild("Crates")

local MAX_DISTANCE = 500 
local OPEN_DISTANCE = 12 -- အနားရောက်ရင် ဖွင့်မယ်
local PURPLE_COLOR = ColorSequence.new(Color3.fromRGB(170, 0, 255))

if _G.TrackerV5Loop then _G.TrackerV5Loop:Disconnect() end
_G.v5Beams = _G.v5Beams or {}
local processedCrates = {} -- ဖွင့်ပြီးသား crate တွေကို မှတ်ထားဖို့

-- Beam တွေကို အကုန်ဖျက်တဲ့ function
local function clearV5()
    for crate, data in pairs(_G.v5Beams) do
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
    end
    _G.v5Beams = {}
end

-- Beam တစ်ခုတည်းကိုပဲ ဖျက်တဲ့ function
local function removeSingleBeam(crate)
    local data = _G.v5Beams[crate]
    if data then
        pcall(function()
            if data.beam then data.beam:Destroy() end
            if data.aP then data.aP:Destroy() end
            if data.aB then data.aB:Destroy() end
        end)
        _G.v5Beams[crate] = nil
    end
end

_G.TrackerV5Loop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not CRATE_FOLDER then return end

        for _, crate in pairs(CRATE_FOLDER:GetChildren()) do
            -- ဖွင့်ပြီးသား crate ဆိုရင် ဘာမှမလုပ်တော့ဘူး
            if processedCrates[crate] then continue end

            local targetPart = crate:FindFirstChild("MainPart") or crate:FindFirstChildWhichIsA("BasePart")
            if targetPart then
                local dist = (root.Position - targetPart.Position).Magnitude
                
                -- [[ BEAM LOGIC ]] --
                if dist <= MAX_DISTANCE then
                    if not _G.v5Beams[crate] then
                        local attP = Instance.new("Attachment", root)
                        local attB = Instance.new("Attachment", targetPart)
                        local beam = Instance.new("Beam", root)
                        beam.Attachment0, beam.Attachment1 = attP, attB
                        beam.Color = PURPLE_COLOR
                        beam.Width0, beam.Width1 = 0.4, 0.4
                        beam.Texture = "rbxassetid://44611181"
                        beam.TextureSpeed = 2.5
                        beam.FaceCamera = true
                        _G.v5Beams[crate] = {beam = beam, aP = attP, aB = attB}
                    end
                    
                    -- [[ AUTO OPEN & REMOVE LINE ]] --
                    if dist <= OPEN_DISTANCE then
                        local prompt = crate:FindFirstChildOfClass("ProximityPrompt") or crate:FindFirstChildWhichIsA("ProximityPrompt", true)
                        if prompt and prompt.Enabled then
                            -- 1. Prompt ပစ်မယ်
                            fireproximityprompt(prompt)
                            
                            -- 2. ခရမ်းရောင်လိုင်းကို ချက်ချင်းဖြတ်မယ်
                            processedCrates[crate] = true
                            removeSingleBeam(crate)
                        end
                    end
                else
                    -- Out of range ဖြစ်ရင် ဖျက်မယ်
                    removeSingleBeam(crate)
                end
            end
        end
        
        -- ပျောက်သွားတဲ့ crate (Cleanup) တွေအတွက် Beam ပြန်ဖျက်မယ်
        for crate, _ in pairs(_G.v5Beams) do
            if not crate or not crate.Parent then
                removeSingleBeam(crate)
            end
        end
    else
        -- Menu ကနေ OFF လိုက်ရင် အကုန်ရှင်းမယ်
        clearV5()
        processedCrates = {} -- Reset memory
    end
end)

print("Crate Tracker V5: Line removal on open - ENABLED.")
