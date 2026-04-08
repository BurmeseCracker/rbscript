local scriptID = "AutoCollectBattery" 

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

-- Remotes
local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 300 -- Teleport လုပ်မှာဖြစ်လို့ Distance ကို တိုးထားလိုက်ပါပြီ
local TARGET_NAMES = {
    ["Battery"] = true, 
    ["Battery Pack"] = true
}

local processed = {} 
local isCollecting = false -- Battery ကောက်နေတုန်း တခြားဟာ ထပ်မကောက်အောင်

-- အရင် Loop ရှိရင် ဖြတ်မယ်
if _G.AutoBatteryLoop then 
    _G.AutoBatteryLoop:Disconnect() 
    _G.AutoBatteryLoop = nil
end

_G.AutoBatteryLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then 
        if _G.AutoBatteryLoop then
            _G.AutoBatteryLoop:Disconnect()
            _G.AutoBatteryLoop = nil
        end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end -- ကောက်နေတုန်းဆိုရင် ထပ်မလုပ်ဘူး

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                isCollecting = true -- Collecting State Start
                processed[item] = true 
                
                -- ၁။ Battery ဆီ Teleport လုပ်မယ်
                -- မြေပြင်ထဲ မနစ်အောင် Battery ရဲ့ အပေါ် ၃ ပေကို ပို့ပေးမယ်
                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                
                -- ၂။ မူလနေရာ ပြန်မရောက်သွားအောင် ခဏ Freeze လုပ်မယ် (Stun Logic)
                root.Anchored = true 
                
                -- ၃။ Remote နဲ့ ကောက်မယ်
                PickUpRemote:FireServer(item)
                
                task.wait(0.2) -- ကောက်တာ သေချာအောင် ခဏစောင့်မယ်
                
                if item and item.Parent then 
                    AdjustRemote:FireServer(item) 
                end

                task.wait(0.3) -- Item ပျောက်သွားတာ သေချာအောင် ထပ်စောင့်မယ်

                -- ၄။ ပြန်လွှတ်ပေးမယ် (Unfreeze)
                root.Anchored = false
                isCollecting = false
                
                -- ၅။ ၂ စက္ကန့်အကြာမှာ list ထဲက ပြန်ထုတ်မယ်
                task.delay(2, function() 
                    processed[item] = nil 
                end)
                
                break -- တစ်ကြိမ်မှာ တစ်ခုပဲ ကောက်မယ် (Teleport ဖြစ်လို့)
            end
        end
    end
end)

print("Battery TP Collect with Anchor Loaded!")
