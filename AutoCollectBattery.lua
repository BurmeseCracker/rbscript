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
                
                print("🔋 Teleporting to Side of Battery...")

                -- [ SIDE LOOP TELEPORT LOGIC ]
                local startTime = tick()
                while item and item.Parent and (tick() - startTime) < 5 do
                    -- Battery ရဲ့ ဘေးနား (X axis + 2) မှာ ပေါ်စေခြင်း
                    -- မြေကြီးထဲ မနစ်အောင် Y ကို 0.5 လောက်ပဲ မြှင့်ထားတယ်
                    root.CFrame = CFrame.new(pos) * CFrame.new(2, 0.5, 0)
                    
                    -- Remote ပစ်ခြင်း
                    if (tick() - startTime) < 0.2 then
                        PickUpRemote:FireServer(item)
                    end
                    
                    RunService.Heartbeat:Wait()
                end
                
                -- Backpack ညှိခြင်း
                AdjustRemote:FireServer(item)

                isCollecting = false
                
                -- ကောက်ပြီးသား item ကို list ထဲက ပြန်ဖြုတ်မည်
                task.delay(1.5, function() 
                    processed[item] = nil 
                end)
                
                break 
            end
        end
    end
end)

print("Battery Side-TP Loop Loaded!")

