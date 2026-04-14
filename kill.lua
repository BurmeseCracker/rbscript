-- [[ kill.lua - Instant Kill (Updated Pathing) ]] --
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Config
local ATTACK_RANGE = 40
local SWING_COOLDOWN = 0.1 
local lastSwing = 0

-- This thread will run as long as the toggle is active
task.spawn(function()
    print("Instant Kill: Activation Loop Started")
    
    while _G["kill"] do
        local char = player.Character
        if char then
            -- 1. Find the Tool
            local tool = char:FindFirstChildOfClass("Tool")
            local charactersFolder = workspace:FindFirstChild("Characters")
            
            -- Check for Tool and the Melee folder inside it
            local meleeFolder = tool and tool:FindFirstChild("Melee")
            
            if meleeFolder and charactersFolder then
                -- 2. Find Remotes inside the Melee folder
                local swingRemote = meleeFolder:FindFirstChild("Swing")
                local hitRemote = meleeFolder:FindFirstChild("HitTargets")
                
                if swingRemote and hitRemote then
                    -- 3. Performance/Cooldown check
                    if tick() - lastSwing >= SWING_COOLDOWN then
                        local myPos = char.PrimaryPart and char.PrimaryPart.Position
                        local targets = {}
                        local hitAny = false

                        -- 4. Target Detection
                        if myPos then
                            for _, enemy in pairs(charactersFolder:GetChildren()) do
                                if enemy:IsA("Model") and enemy ~= char then
                                    local root = enemy:FindFirstChild("HumanoidRootPart")
                                    local hum = enemy:FindFirstChildOfClass("Humanoid")

                                    if root and hum and hum.Health > 0 then
                                        local dist = (myPos - root.Position).Magnitude
                                        if dist <= ATTACK_RANGE then
                                            table.insert(targets, enemy)
                                            hitAny = true
                                        end
                                    end
                                end
                            end
                        end

                        -- 5. Attack Execution
                        if hitAny then
                            hitRemote:FireServer(targets) -- Send damage to all in range
                            swingRemote:FireServer()      -- Play animation
                            lastSwing = tick()
                        end
                    end
                end
            end
        end
        task.wait() -- Fast check
    end
    
    print("Instant Kill: Activation Loop Stopped")
end)
