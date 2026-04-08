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
local MAX_DIST = 20 
local TARGET_NAMES = {
    ["Battery"] = true, 
    ["Battery Pack"] = true

}
local processed = {} 

-- အရင် Loop ရှိရင် ဖြတ်မယ်
if _G.AutoBatteryLoop then 
    _G.AutoBatteryLoop:Disconnect() 
    _G.AutoBatteryLoop = nil
end

_G.AutoBatteryLoop = RunService.Heartbeat:Connect(function()
    -- Menu မှာ OFF ထားရင် Loop ကို ရပ်ပစ်မယ်
    if _G[scriptID] ~= true then 
        if _G.AutoBatteryLoop then
            _G.AutoBatteryLoop:Disconnect()
            _G.AutoBatteryLoop = nil
        end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        -- Error တက်ခဲ့တဲ့နေရာကို ပြင်ထားတယ်: TARGET_NAMES[item.Name]
        if TARGET_NAMES[item.Name] and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            local dist = (root.Position - pos).Magnitude
            if dist <= MAX_DIST then
                processed[item] = true 
                
                -- Remote နဲ့ ကောက်မယ်
                PickUpRemote:FireServer(item)
                
                task.delay(0.1, function()
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end
                end)

                -- ၂ စက္ကန့်အကြာမှာ list ထဲက ပြန်ထုတ်မယ်
                task.delay(2, function() 
                    processed[item] = nil 
                end)
            end
        end
    end
end)
