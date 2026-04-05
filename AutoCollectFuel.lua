local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 12 
local TARGET_NAME = "Fuel" -- Fuel အတွက် သီးသန့်
local processed = {} 

-- အရင် Loop ရှိခဲ့ရင် Disconnect အရင်လုပ်မယ်
if _G.AutoFuelLoop then 
    _G.AutoFuelLoop:Disconnect() 
    _G.AutoFuelLoop = nil
end

_G.AutoFuelLoop = RunService.Heartbeat:Connect(function()
    -- Menu မှာ Toggle OFF လိုက်ရင် Loop ကိုပါ အပြီးသတ် ဖျက်မယ်
    if _G["AutoCollectFuel"] ~= true then 
        if _G.AutoFuelLoop then
            _G.AutoFuelLoop:Disconnect()
            _G.AutoFuelLoop = nil
        end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        -- Fuel ဖြစ်ရမယ်၊ ပြီးတော့ တစ်ခါမှ မကောက်ရသေးတဲ့ Item ဖြစ်ရမယ်
        if item.Name == TARGET_NAME and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                processed[item] = true 
                
                -- Fuel ကို Remote နဲ့ လှမ်းကောက်မယ်
                local fuelUnion = item:FindFirstChild("Union") or item
                PickUpRemote:FireServer(fuelUnion)
                
                task.delay(0.1, function()
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end
                end)

                -- ၅ စက္ကန့်အကြာမှာ list ထဲက ပြန်ထုတ်ပေးမယ်
                task.delay(5, function() 
                    processed[item] = nil 
                end)
            end
        end
    end
end)
