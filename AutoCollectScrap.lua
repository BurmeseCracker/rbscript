local scriptID = "AutoCollectScrap" -- Menu ထဲက နာမည်နဲ့ ကိုက်အောင်ပြင်ထားသည်

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER_NAME = "DroppedItems"

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local PickUpRemote = Remotes:WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = Remotes:WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 40 -- Scrap ကို လှမ်းရှာမည့် အကွာအဝေး (Teleport Range)
local TARGET_NAME = "Scrap" 
local processed = {} 
local isCollecting = false -- TP လုပ်နေစဉ် နောက်တစ်ခု ထပ်မလုပ်အောင် Lock ထားရန်

-- အရင်ရှိနေတဲ့ Loop ကို အရင်ဖျက်ထုတ်ခြင်း
if _G.AutoScrapLoop then 
    _G.AutoScrapLoop:Disconnect() 
    _G.AutoScrapLoop = nil
end

-- Main Loop
_G.AutoScrapLoop = RunService.Heartbeat:Connect(function()
    -- Menu မှာ OFF ထားလျှင် Loop ကို ရပ်ပစ်မည်
    if _G[scriptID] ~= true then 
        if _G.AutoScrapLoop then
            _G.AutoScrapLoop:Disconnect()
            _G.AutoScrapLoop = nil
        end
        return 
    end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local folder = workspace:FindFirstChild(SEARCH_FOLDER_NAME)
    
    -- Root မရှိရင် သို့မဟုတ် တစ်ခုကောက်နေတုန်းဆိုရင် ခဏစောင့်မည်
    if not root or not folder or isCollecting then return end

    for _, item in pairs(folder:GetChildren()) do
        -- Scrap ဖြစ်ရမည်၊ အရင်က ကောက်ပြီးသား မဖြစ်ရပါ
        if item.Name == TARGET_NAME and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end

            local dist = (root.Position - pos).Magnitude

            if dist <= MAX_DIST then
                isCollecting = true
                processed[item] = true 
                
                -- ၁။ Scrap ဆီသို့ Teleport လုပ်ခြင်း
                root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                
                -- ၂။ ခဏစောင့်ပြီး Remote ဖြင့် ကောက်ယူခြင်း
                task.wait(0.1) -- TP ငြိမ်အောင် ခဏစောင့်ခြင်း
                PickUpRemote:FireServer(item)
                
                task.wait(0.1)
                if item and item.Parent then
                    AdjustRemote:FireServer(item)
                end

                -- ၃။ နောက်တစ်ခုကို ကူးနိုင်ရန် Lock ပြန်ဖွင့်ခြင်း
                task.wait(0.1)
                isCollecting = false

                -- ၅ စက္ကန့်ကြာရင် List ထဲက ပြန်ထုတ်မည် (ပစ္စည်းအသစ်ပြန်ပေါ်ရင် ကောက်နိုင်ရန်)
                task.delay(5, function() 
                    processed[item] = nil 
                end)

                break -- တစ်ခုပြီးမှ နောက်တစ်ခုကို အစဉ်လိုက် TP လုပ်ရန်
            end
        end
    end
end)

print("AutoCollect Scrap (TP Version) Started!")
