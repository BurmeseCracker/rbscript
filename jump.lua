-- [[ JumpPower Script - Menu Version ]] --
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local JUMP_POWER_CUSTOM = 100 
local JUMP_POWER_DEFAULT = 50 -- Roblox standard jump power

local function applyJumpLogic(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    -- We use a loop or a property change signal to ensure it stays 
    -- at the desired value while the toggle is ON.
    task.spawn(function()
        while character and character:IsDescendantOf(workspace) do
            if _G["jump"] then
                humanoid.UseJumpPower = true
                humanoid.JumpPower = JUMP_POWER_CUSTOM
            else
                -- If Toggle is OFF, reset to default and stop the loop
                humanoid.JumpPower = JUMP_POWER_DEFAULT
                break
            end
            task.wait(0.5) -- Check every half second to prevent lag
        end
    end)
end

-- Run when script is first loaded
if player.Character then
    applyJumpLogic(player.Character)
end

-- Run when player respawns
player.CharacterAdded:Connect(function(character)
    applyJumpLogic(character)
end)

print("Jump Script Loaded: Monitoring _G['jump']")
