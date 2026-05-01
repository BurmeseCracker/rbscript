-- [[ Infinite Yield Style Fly-Jump ]] --
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

UserInputService.JumpRequest:Connect(function()
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if humanoid and rootPart then
        -- 1. Force the Jumping State (Standard method)
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- 2. Force Upward Velocity (Fly-Jump Method)
        -- This kills your downward momentum and pushes you up 50 units
        rootPart.AssemblyLinearVelocity = Vector3.new(
            rootPart.AssemblyLinearVelocity.X, 
            50, 
            rootPart.AssemblyLinearVelocity.Z
        )
    end
end)
