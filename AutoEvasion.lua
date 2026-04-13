-- [[ Universal Layered Aura - Multi-Tool Version ]] --
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Configuration
local ATTACK_RANGE = 40
local SWING_COOLDOWN = 0.1 -- Prevents crashing/kicks
local lastSwing = 0

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Find ANY tool currently equipped
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    -- Look for the attack remotes inside the held tool
    local swingRemote = tool:FindFirstChild("Swing")
    local hitRemote = tool:FindFirstChild("HitTargets")
    
    -- Characters folder check
    local charactersFolder = workspace:FindFirstChild("Characters")
    if not (swingRemote and hitRemote and charactersFolder) then return end

    -- Rate limiting to prevent server lag
    if tick() - lastSwing < SWING_COOLDOWN then return end

    local myPos = char.PrimaryPart and char.PrimaryPart.Position
    if not myPos then return end

    local targets = {}
    local hitAny = false

    for _, enemy in pairs(charactersFolder:GetChildren()) do
        if enemy:IsA("Model") and enemy ~= char then
            local root = enemy:FindFirstChild("HumanoidRootPart")
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            
            if root and hum and hum.Health > 0 then
                local dist = (myPos - root.Position).Magnitude
                
                if dist <= ATTACK_RANGE then
                    table.insert(targets, enemy)
                    hitAny = true
                    
                    -- Damage Trigger
                    hitRemote:FireServer(targets)
                    
                    -- Extra speed for close combat
                    if dist <= 12 then
                        swingRemote:FireServer()
                    end
                end
            end
        end
    end
    
    if hitAny then
        swingRemote:FireServer()
        lastSwing = tick()
    end
end)

print("Universal Aura Loaded: Compatible with all Melee tools.")
