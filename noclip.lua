-- FINAL ANTI-KICK NOCLIP
local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer

if _G.NoclipLoop then _G.NoclipLoop:Disconnect() end

_G.NoclipLoop = RunService.Stepped:Connect(function()
    if _G["noclip"] == true then
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
            
            if hum then hum:ChangeState(11) end
            
            -- Server က ပြန်မဆွဲအောင် Velocity ကို ထိန်းညှိမယ်
            if root and root.Velocity.Magnitude > 50 then
                root.Velocity = Vector3.new(0, 0, 0)
            end
        end
    else
        -- OFF
        if player.Character then
            for _, v in pairs(player.Character:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.CanCollide = true
                end
            end
        end
        _G.NoclipLoop:Disconnect()
        _G.NoclipLoop = nil
    end
end)
