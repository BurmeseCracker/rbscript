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
local MAX_DIST = 60 
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
    -- Menu က OFF ထားလျှင် Loop ကို ဖြတ်မည်
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
            
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                isCollecting = true
                processed[item] = true 
                
                -- [ STABILIZER ] Character ငြိမ်အောင် အရင်လုပ်မယ်
                local gyro = Instance.new("BodyGyro")
                gyro.P = 3000
                gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                gyro.CFrame = root.CFrame
                gyro.Parent = root

                -- [ LOOP TELEPORT LOGIC ] 
                -- ကောက်လို့ပြီးတဲ့အထိ (သို့) ၃ စက္ကန့်ပြည့်တဲ့အထိ Battery ဘေးမှာ ဇွတ်ကပ်နေမယ်
                local startTime = tick()
                while item and item.Parent and (tick() - startTime) < 3 do
                    -- Battery ရဲ့ ဘေးနား ၂ ပေ၊ မြေပြင်ပေါ် ၀.၅ ပေမှာ Loop TP လုပ်ခြင်း
                    root.CFrame = CFrame.new(pos) * CFrame.new(2, 0.5, 0)
                    
                    -- Remote ပစ်ခြင်း (ပထမ ၀.၂ စက္ကန့်အတွင်းပဲ ပစ်မယ်)
                    if (tick() - startTime) < 0.2 then
                        PickUpRemote:FireServer(item)
                    end
                    
                    RunService.Heartbeat:Wait() -- တစ်စက္ကန့်ကို အကြိမ် ၆၀ နီးပါး TP ပြန်လုပ်ပေးနေမှာပါ
                end
                
                -- Cleanup & Next
                gyro:Destroy()
                AdjustRemote:FireServer(item)

                isCollecting = false
                
                -- ၃ စက္ကန့်အကြာမှ ကောက်ပြီးသား item ကို list ထဲက ပြန်ဖြုတ်မည်
                task.delay(3, function() 
                    processed[item] = nil 
                end)
                
                break -- တစ်ကြိမ်လျှင် တစ်ခုစီ လျှင်မြန်စွာ သွားမည်
            end
        end
    end
end)

print("Fast Side-Loop Battery TP Loaded!")
