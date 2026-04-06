local scriptID = "AutoCollectScrap" -- Menu ထဲက နာမည်နဲ့ ကိုက်အောင်ပြင်ထားသည်
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER_NAME = "DroppedItems"

-- Remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Interaction = Remotes:WaitForChild("Interaction")
local Tools = Remotes:WaitForChild("Tools")

local PickUpRemote = Interaction:WaitForChild("PickUpItem")
local AdjustRemote = Tools:WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 15 -- အကွာအဝေးကို နည်းနည်းတိုးပေးထားသည်
local TARGET_NAME = "Scrap" 
local processed = {} 

-- အရင်ရှိနေတဲ့ Loop ကို အရင်ဖျက်ထုတ်ခြင်း
if _G.AutoScrapLoop then 
    _G.AutoScrapLoop:Disconnect() 
    _G.AutoScrapLoop = nil
end

-- Main Loop ကို တစ်ကြိမ်ပဲ ဖွင့်မည်
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
    
    if not root or not folder then return end

    for _, item in pairs(folder:GetChildren()) do
        -- Scrap ဖြစ်ရမည်၊ အရင်က ကောက်ပြီးသား မဖြစ်ရပါ
        if item.Name == TARGET_NAME and not processed[item] then
            local dist = (root.Position - item:GetPivot().Position).Magnitude

            if dist <= MAX_DIST then
                processed[item] = true 
                
                -- STEP 1: Server ဆီ ကောက်ခိုင်းရန် ပို့ခြင်း
                PickUpRemote:FireServer(item)
                
                -- STEP 2: Backpack ထဲ ထည့်ခိုင်းခြင်း
                task.delay(0.1, function()
                    if item and item.Parent then
                        AdjustRemote:FireServer(item)
                    end
                end)

                -- ၅ စက္ကန့်ကြာရင် List ထဲက ပြန်ထုတ်မည် (နောက်တစ်ခါ ထပ်ပေါ်လာရင် ကောက်နိုင်ရန်)
                task.delay(5, function() 
                    processed[item] = nil 
                end)
            end
        end
    end
end)

print("AutoCollect Scrap: Loop Started!")
