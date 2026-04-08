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
local START_DIST = 40 -- အနီးနား 40 studs အရင်ရှာမည်
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

    -- အနီးကနေ အဝေးကို အဆင့်ဆင့် ရှာဖွေခြင်း
    for step = 1, 50 do 
        local currentMaxDist = step * START_DIST
        local foundInStep = false

        for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
            if TARGET_NAMES[item.Name] and not processed[item] then
                local success, pos = pcall(function() return item:GetPivot().Position end)
                if not success then continue end
                
                local dist = (root.Position - pos).Magnitude
                
                if dist <= currentMaxDist then
                    isCollecting = true
                    processed[item] = true 
                    
                    -- ၁။ Teleport လုပ်ခြင်း
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                    
                    -- ၂။ TP မြန်လွန်းတာကို ထိန်းရန် ဒီမှာ ၀.၃ စက္ကန့် စောင့်ခိုင်းလိုက်ပါတယ် (Video ပုံစံအတိုင်းဖြစ်စေရန်)
                    task.wait(5) 
                    
                    local fuelTarget = item:FindFirstChild("Union") or item:FindFirstChildWhichIsA("BasePart") or item
                    PickUpRemote:FireServer(fuelTarget)
                    
                    task.wait(0.1)
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end

                    -- ၃။ နောက်တစ်ခုကို မသွားခင် ခဏနားမည်
                    task.wait(0.2)
                    isCollecting = false
                    
                    task.delay(3, function() 
                        processed[item] = nil 
                    end)
                    
                    foundInStep = true
                    break 
                end
            end
        end

        if foundInStep then break end
    end
end)

print("Fuel TP (Adjusted Speed) Loaded!")
