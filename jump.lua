-- [[ JumpPower Script ]] --
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local JUMP_HEIGHT = 30 -- Set your desired jump power here

local function applyJumpPower(character)
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Ensure the character is allowed to use JumpPower instead of JumpHeight
    humanoid.UseJumpPower = true
    humanoid.JumpPower = JUMP_HEIGHT
    
    print("JumpPower set to: " .. JUMP_HEIGHT)
end

-- Apply to the current character
if player.Character then
    applyJumpPower(player.Character)
end

-- Apply again whenever the character respawns
player.CharacterAdded:Connect(function(character)
    applyJumpPower(character)
end)

