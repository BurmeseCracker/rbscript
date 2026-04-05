local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER_NAME = "DroppedItems"

-- Remotes (Wait safely)
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 12
local FUEL_NAME = "Fuel"
local processed = {} 

-- အရင် Loop ရှိခဲ့ရင် Disconnect လုပ်မယ်
if _G.AutoFuelLoop then 
    _G.AutoFuelLoop:Disconnect() 
    _G.AutoFuelLoop = nil
end

_G.AutoFuelLoop = RunService.Heartbeat:Connect(function()
    -- Menu မှာ OFF လိုက်ရင် Loop ကိုပါ အပြီးဖြတ်မယ်
    if _G["AutoCollectFuel"] ~= true then 
        if _G.AutoFuelLoop then
            _G.AutoFuelLoop:Disconnect()
            _G.AutoFuelLoop = nil
        end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local folder = workspace:FindFirstChild(SEARCH_FOLDER_NAME)
    
    if not root or not folder then return end

    for _, item in pairs(folder:GetChildren()) do
        if item.Name == FUEL_NAME and not processed[item] then
            local success, fuelPos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - fuelPos).Magnitude

            if dist <= MAX_DIST then
                local fuelUnion = item:FindFirstChild("Union")
                
                if fuelUnion then
                    processed[item] = true
                    
                    -- Physical Pick Up
                    PickUpRemote:FireServer(fuelUnion)
                    
                    -- Inventory Register
                    task.delay(0.1, function()
                        if item and item.Parent then
                            AdjustRemote:FireServer(item)
                        end
                    end)
                    
                    -- Processed table ကို ရှင်းပေးမယ် (နောက်တစ်ခါ ပြန်ကောက်နိုင်အောင်)
                    task.delay(2, function()
                        processed[item] = nil 
                    end)
                end
            end
        end
    end
end)
