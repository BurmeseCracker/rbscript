-- [[ kill.lua - Instant Kill (Priority Edition) ]] --
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ATTACK_RANGE = 40
local SWING_COOLDOWN = 0.1 
local lastSwing = 0

task.spawn(function()
    print("Instant Kill: Activation Loop Started")
    
    while _G["kill"] == true do
        local char = player.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        local charactersFolder = workspace:FindFirstChild("Characters")
        
        -- Flexible pathing for Melee folder
        local remoteContainer = tool and (tool:FindFirstChild("Melee") or tool)
        
        if remoteContainer and charactersFolder then
            local swingRemote = remoteContainer:FindFirstChild("Swing")
            local hitRemote = remoteContainer:FindFirstChild("HitTargets")
            
            if swingRemote and hitRemote then
                if tick() - lastSwing >= SWING_COOLDOWN then
                    local myPos = char.PrimaryPart and char.PrimaryPart.Position
                    local targets = {}

                    if myPos then
                        for _, enemy in pairs(charactersFolder:GetChildren()) do
                            if enemy:IsA("Model") and enemy ~= char then
                                local root = enemy:FindFirstChild("HumanoidRootPart")
                                local hum = enemy:FindFirstChildOfClass("Humanoid")

                                if root and hum and hum.Health > 0 then
                                    local dist = (myPos - root.Position).Magnitude
                                    if dist <= ATTACK_RANGE then
                                        table.insert(targets, enemy)
                                    end
                                end
                            end
                        end
                    end

                    if #targets > 0 then
                        hitRemote:FireServer(targets)
                        swingRemote:FireServer()
                        lastSwing = tick()
                    end
                end
            end
        end
        task.wait() 
    end
    print("Instant Kill: Activation Loop Stopped")
end)
