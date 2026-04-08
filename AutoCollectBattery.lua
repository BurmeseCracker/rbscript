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
local MAX_DIST = 70
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
    if _G[scriptID] ~= true then return end

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
                
                -- [ STABILIZER ဖန်တီးခြင်း ]
                -- Character ကို မတ်မတ်ရပ်နေအောင် ထိန်းပေးမည်
                local gyro = Instance.new("BodyGyro")
                gyro.P = 3000
                gyro.D = 500
                gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
                gyro.CFrame = root.CFrame -- လက်ရှိကြည့်နေတဲ့ လားရာအတိုင်း ငြိမ်အောင်ထားမည်
                gyro.Parent = root

                local startTime = tick()
                while item and item.Parent and (tick() - startTime) < 5 do
                    -- Battery ရဲ့ ဘေးနား ၂ ပေ အကွာ၊ မြေပြင်ပေါ် ၀.၅ ပေမှာ Loop TP လုပ်မည်
                    root.CFrame = CFrame.new(pos) * CFrame.new(2, 0.5, 0)
                    
                    -- Remote ပစ်ခြင်း
                    if (tick() - startTime) < 0.2 then
                        PickUpRemote:FireServer(item)
                    end
                    
                    RunService.Heartbeat:Wait()
                end
                
                -- ပြီးသွားရင် Stabilizer ကို ပြန်ဖျက်မည်
                gyro:Destroy()
                AdjustRemote:FireServer(item)

                isCollecting = false
                task.delay(1.5, function() processed[item] = nil end)
                break 
            end
        end
    end
end)

print("Battery TP with BodyGyro Stabilizer Loaded!")
