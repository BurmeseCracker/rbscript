-- [[ ZOMBIE HITBOX EXPANDER - VISIBILITY OPTIMIZED ]] --

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local targetFolder = workspace:FindFirstChild("Characters")
local HITBOX_SIZE = Vector3.new(15, 15, 15)

RunService.RenderStepped:Connect(function()
    if _G["hitbox"] == true then
        if not targetFolder then return end

        for _, npc in pairs(targetFolder:GetChildren()) do
            -- စစ်ဆေးချက်: Model ဖြစ်ရမည်၊ Player character မဟုတ်ရပါ၊ Hunger script မရှိရပါ
            if npc:IsA("Model") and npc ~= player.Character then
                
                -- Skip players using the Hunger script check
                if npc:FindFirstChild("Hunger") then 
                    continue 
                end

                local hrp = npc:FindFirstChild("HumanoidRootPart")
                local hum = npc:FindFirstChildOfClass("Humanoid")

                if hrp and hum and hum.Health > 0 then
                    hrp.Size = HITBOX_SIZE
                    
                    -- [[ VISIBILITY FIX ]] --
                    hrp.Transparency = 0.9 -- 0.9 is much clearer than 0.7
                    hrp.Color = Color3.fromRGB(255, 255, 255) -- White (less blinding than red)
                    
                    hrp.CanCollide = false
                    hrp.Massless = true
                end
            end
        end
    else
        -- Reset logic
        if targetFolder then
            for _, npc in pairs(targetFolder:GetChildren()) do
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Size ~= Vector3.new(2, 2, 1) then
                    hrp.Size = Vector3.new(2, 2, 1)
                    hrp.Transparency = 1
                end
            end
        end
    end
end)
