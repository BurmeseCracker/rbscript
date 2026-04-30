-- [[ kill.lua - Non-Stop Instant Kill (Infinite Loop Edition) ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- CONFIG
local ATTACK_RANGE = 50 
local SWING_COOLDOWN = 0.1 
local lastSwing = 0

-- Function to handle the killing logic
local function ProcessKill()
    if _G["kill"] ~= true then return end

    local char = player.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end

    local charactersFolder = workspace:FindFirstChild("Characters")
    if not charactersFolder then return end

    -- Check for Melee folder or Tool directly
    local remoteContainer = tool:FindFirstChild("Melee") or tool
    local swingRemote = remoteContainer:FindFirstChild("Swing")
    local hitRemote = remoteContainer:FindFirstChild("HitTargets")

    -- Ensure we have remotes and cooldown is ready
    if swingRemote and hitRemote and (tick() - lastSwing >= SWING_COOLDOWN) then
        local myRoot = char:FindFirstChild("HumanoidRootPart")
        if not myRoot then return end

        local targets = {}
        local myPos = myRoot.Position

        for _, enemy in pairs(charactersFolder:GetChildren()) do
            if enemy:IsA("Model") and enemy ~= char then
                local eRoot = enemy:FindFirstChild("HumanoidRootPart")
                local eHum = enemy:FindFirstChildOfClass("Humanoid")

                if eRoot and eHum and eHum.Health > 0 then
                    local dist = (myPos - eRoot.Position).Magnitude
                    
                    -- Kill everyone within 50 studs (from 0.1 to 50)
                    if dist <= ATTACK_RANGE then
                        table.insert(targets, enemy)
                    end
                end
            end
        end

        if #targets > 0 then
            lastSwing = tick()
            hitRemote:FireServer(targets)
            swingRemote:FireServer()
        end
    end
end

-- [[ PERSISTENT CONNECTION ]] --
-- Heartbeat is much more reliable than a while-wait() loop
if _G.KillConnection then _G.KillConnection:Disconnect() end

_G.KillConnection = RunService.Heartbeat:Connect(function()
    if _G["kill"] == true then
        local success, err = pcall(ProcessKill)
        if not success then
            -- Optional: print(err) for debugging if it breaks
        end
    else
        -- If toggle is off, stop the connection to save CPU
        if _G.KillConnection then
            _G.KillConnection:Disconnect()
            _G.KillConnection = nil
            print("Instant Kill: Stopped")
        end
    end
end)

print("Instant Kill: Persistent Loop Active (Range 50)")
