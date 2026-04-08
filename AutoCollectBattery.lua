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
local MAX_DIST = 100 
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
                
                print("🔋 Starting Loop Teleport to Battery...")

                -- [ LOOP TELEPORT LOGIC ]
                -- Item ပျောက်သွားတဲ့အထိ (သို့မဟုတ်) ၆ စက္ကန့်ပြည့်တဲ့အထိ အဲ့ဒီနေရာကိုပဲ အတင်းပို့နေမယ်
                local startTime = tick()
                while item and item.Parent and (tick() - startTime) < 6 do
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
                    
                    -- Remote ကို တစ်ခါပဲ ပစ်မယ်
                    if (tick() - startTime) < 0.2 then
                        PickUpRemote:FireServer(item)
                    end
                    
                    RunService.Heartbeat:Wait() -- တစ်စက္ကန့်ကို အကြိမ် ၆၀ နီးပါး TP ပြန်လုပ်ပေးနေမှာပါ
                end
                
                -- Backpack ထဲ ထည့်မယ်
                AdjustRemote:FireServer(item)

                isCollecting = false
                
                -- ကောက်ပြီးသား item ကို list ထဲက ပြန်ဖြုတ်မည်
                task.delay(2, function() 
                    processed[item] = nil 
                end)
                
                break 
            end
        end
    end
end)

print("Battery Loop Teleport Loaded!")
