local scriptID = "AutoCollectFuel" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 40 -- Battery script အတိုင်း 40 studs ထားပေးထားတယ်
local TARGET_NAMES = {
    ["Fuel"] = true, 
    ["Refined Fuel"] = true
}

local processed = {} 
local isCollecting = false -- ထပ်မကောက်အောင်ထိန်းဖို့

-- Loop ဟောင်းရှိလျှင် ပိတ်မည်
if _G.AutoFuelLoop then 
    _G.AutoFuelLoop:Disconnect() 
    _G.AutoFuelLoop = nil
end

_G.AutoFuelLoop = RunService.Heartbeat:Connect(function()
    -- Menu က OFF ထားလျှင် ရပ်မည်
    if _G[scriptID] ~= true then 
        if _G.AutoFuelLoop then
            _G.AutoFuelLoop:Disconnect()
            _G.AutoFuelLoop = nil
        end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            -- အကွာအဝေး စစ်ဆေးခြင်း
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                isCollecting = true
                processed[item] = true 
                
                -- ၁။ Fuel ဆီသို့ တိုက်ရိုက် Teleport လုပ်ခြင်း (ဒီနေရာက တုန်ခါမှုကို ဖြစ်စေတာပါ)
                root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                
                -- ၂။ ခဏစောင့်ပြီး Remote ဖြင့် ကောက်ယူခြင်း
                task.wait(0.1) 
                
                -- Fuel Union ကို ရှာမယ်၊ မရှိရင် item ကို သုံးမယ်
                local fuelTarget = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart") or item
                PickUpRemote:FireServer(fuelTarget)
                
                task.wait(0.1)
                if item and item.Parent then 
                    AdjustRemote:FireServer(item) 
                end

                -- ၃။ Delay ခဏပေးပြီး နောက်တစ်ခု ထပ်ကောက်နိုင်အောင်လုပ်မယ်
                task.wait(0.2)
                isCollecting = false
                
                -- ၄။ ကောက်ပြီးသား item ကို list ထဲက ပြန်ဖြုတ်မည်
                task.delay(3, function() 
                    processed[item] = nil 
                end)
                
                break -- တစ်ကြိမ်လျှင် တစ်ခုစီ လျှင်မြန်စွာ သွားမည်
            end
        end
    end
end)

print("Fast Fuel TP (Video Style) Loaded!")
