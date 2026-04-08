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
local START_DIST = 40 -- အနီးနား စကင်ဖတ်မည့် အကွာအဝေး
local TARGET_NAMES = {
    ["Fuel"] = true, 
    ["Refined Fuel"] = true
}

local processed = {} 
local isCollecting = false

-- Loop ဟောင်းရှိလျှင် ပိတ်မည်
if _G.AutoFuelLoop then 
    _G.AutoFuelLoop:Disconnect() 
    _G.AutoFuelLoop = nil
end

_G.AutoFuelLoop = RunService.Heartbeat:Connect(function()
    -- Menu က OFF ထားလျှင် ရပ်မည်
    if _G[scriptID] ~= true then 
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    -- အနီးကနေ အဝေးကို အဆင့်ဆင့် ရှာဖွေခြင်း (40, 80, 120, 160...)
    for step = 1, 50 do -- 50 အထိဆိုလျှင် map အနှံ့နီးပါး ရောက်ပါသည်
        local currentMaxDist = step * START_DIST
        local foundInStep = false

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if TARGET_NAMES[item.Name] and not processed[item] then
                local success, pos = pcall(function() return item:GetPivot().Position end)
                if not success then continue end
                
                local dist = (root.Position - pos).Magnitude
                
                -- သတ်မှတ်ထားသော step အကွာအဝေးအတွင်း ရှိမရှိ စစ်ဆေးခြင်း
                if dist <= currentMaxDist then
                    isCollecting = true
                    processed[item] = true 
                    
                    -- ၁။ Fuel ဆီသို့ တိုက်ရိုက် Teleport လုပ်ခြင်း
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                    
                    -- ၂။ ခဏစောင့်ပြီး Remote ဖြင့် ကောက်ယူခြင်း
                    task.wait(0.1) 
                    
                    local fuelTarget = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart") or item
                    PickUpRemote:FireServer(fuelTarget)
                    
                    task.wait(0.1)
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end

                    -- ၃။ Delay ခဏပေးပြီး နောက်တစ်ခု ထပ်ကောက်နိုင်အောင်လုပ်မည်
                    task.wait(0.1)
                    isCollecting = false
                    
                    -- ၄။ ၃ စက္ကန့်ကြာလျှင် list ထဲက ပြန်ထုတ်မည်
                    task.delay(1, function() 
                        processed[item] = nil 
                    end)
                    
                    foundInStep = true
                    break 
                end
            end
        end

        -- တစ်ခုတွေ့ပြီး ကောက်လိုက်ပြီဆိုရင် Loop ကို ရပ်ပြီး နောက် Frame မှ ပြန်စမည်
        if foundInStep then break end
    end
end)

print("Fast Fuel TP (Auto Step Distance) Loaded!")
