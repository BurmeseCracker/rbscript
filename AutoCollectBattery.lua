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
local MAX_DIST = 50 -- အနီးနား 100 studs အတွင်း ရှာမည်
local TARGET_NAMES = {
    ["Battery"] = true, 
    ["Battery Pack"] = true
}

local processed = {} 
local isCollecting = false

-- Loop ဟောင်းရှိလျှင် ပိတ်မည်
if _G.AutoBatteryLoop then 
    _G.AutoBatteryLoop:Disconnect() 
    _G.AutoBatteryLoop = nil
end

_G.AutoBatteryLoop = RunService.Heartbeat:Connect(function()
    -- Menu က OFF ထားလျှင် ရပ်မည်
    if _G[scriptID] ~= true then 
        if _G.AutoBatteryLoop then
            _G.AutoBatteryLoop:Disconnect()
            _G.AutoBatteryLoop = nil
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
                
                -- ၁။ Battery ဆီသို့ တိုက်ရိုက် Teleport လုပ်ခြင်း
                root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                
                -- ၂။ ခဏစောင့်ပြီး Remote ဖြင့် ကောက်ယူခြင်း
                task.wait(0.1) -- TP ပြီးတာနဲ့ ချက်ချင်းကောက်ရန်
                PickUpRemote:FireServer(item)
                
                task.wait(0.1)
                if item and item.Parent then 
                    AdjustRemote:FireServer(item) 
                end

                -- ၃။ နောက်တစ်ခုကို ချက်ချင်းသွားနိုင်ရန် Delay အနည်းငယ်သာထားမည်
                task.wait(0.1)
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

print("Fast Battery TP (No Stun) Loaded!")
