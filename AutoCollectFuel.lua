local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 15 -- အကွာအဝေးကို နည်းနည်း ထပ်တိုးထားပေးတယ်
local TARGET_NAMES = {
    ["Fuel"] = true, 
    ["Refined Fuel"] = true
}
local processed = {} 

if _G.AutoFuelLoop then 
    _G.AutoFuelLoop:Disconnect() 
    _G.AutoFuelLoop = nil
end

_G.AutoFuelLoop = RunService.Heartbeat:Connect(function()
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
        -- ပြင်လိုက်တဲ့နေရာ: Table ထဲမှာ ဒီ item name ရှိလား စစ်တာ
        if TARGET_NAMES[item.Name] and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                processed[item] = true 
                
                -- Fuel Union ကို ရှာမယ်၊ မရှိရင် item တစ်ခုလုံးကို သုံးမယ်
                local fuelTarget = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart") or item
                
                PickUpRemote:FireServer(fuelTarget)
                
                task.delay(0.1, function()
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end
                end)

                -- ၂ စက္ကန့်လောက်ဆိုရင် processed ထဲက ပြန်ထုတ်လို့ရပြီ (၅ စက္ကန့်က ကြာလွန်းလို့)
                task.delay(2, function() 
                    processed[item] = nil 
                end)
            end
        end
    end
end)
