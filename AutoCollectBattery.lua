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
    local hum = char and char:FindFirstChild("Humanoid")
    if not root or not hum or isCollecting then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                isCollecting = true
                processed[item] = true 
                
                -- [ LOOP TELEPORT + INSTANT JUMP LOGIC ] 
                local startTime = tick()
                while item and item.Parent and (tick() - startTime) < 3 do
                    -- Battery ရဲ့ ဘေးနားကို Loop TP လုပ်မယ်
                    root.CFrame = CFrame.new(pos) * CFrame.new(2, 0.5, 0)
                    
                    -- Instant Jumping (Loop ထဲမှာ ခုန်ခိုင်းထားမယ်)
                    hum.Jump = true
                    
                    -- Remote ပစ်ခြင်း (ကောက်ရန် အမိန့်ပေးခြင်း)
                    if (tick() - startTime) < 0.2 then
                        PickUpRemote:FireServer(item)
                    end
                    
                    RunService.Heartbeat:Wait()
                end
                
                -- Backpack ညှိခြင်း
                AdjustRemote:FireServer(item)

                isCollecting = false
                
                -- ကောက်ပြီးသား item ကို list ထဲက ပြန်ဖြုတ်မည်
                task.delay(3, function() 
                    processed[item] = nil 
                end)
                
                break 
            end
        end
    end
end)

print("Fast Side-Loop TP + Instant Jump Loaded!")
