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
local MAX_DIST = 50 -- အနီးနားတစ်ဝိုက် (၅၀ studs) အတွင်းပဲ ရှာမည်
local STUN_TIME = 30 -- မြေပေါ်ဆွဲချထားမည့် စက္ကန့်
local TARGET_NAMES = {
    ["Battery"] = true, 
    ["Battery Pack"] = true
}

local processed = {} 
local isCollecting = false

-- Character ကို မြေပြင်ပေါ် ဖိချထားမည့် Function
local function groundStun(hrp, duration)
    -- လှည့်မသွားအောင် ထိန်းချုပ်ခြင်း
    local bg = Instance.new("BodyGyro")
    bg.P = 9e4
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = hrp.CFrame
    bg.Parent = hrp

    -- အောက်ကို ဖိချထားခြင်း
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0, -60, 0) -- -60 အရှိန်ဖြင့် မြေပေါ်ဖိချမည်
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp

    task.wait(duration) -- ၃၀ စက္ကန့်စောင့်မည်

    bg:Destroy()
    bv:Destroy()
end

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
                
                -- ၁။ Teleport လုပ်ခြင်း (Battery ရဲ့ အပေါ် ၂ ပေ)
                root.CFrame = CFrame.new(pos + Vector3.new(0, 2, 0))
                
                -- ၂။ ကောက်ယူခြင်း (Background မှာ လုပ်မည်)
                task.spawn(function()
                    PickUpRemote:FireServer(item)
                    task.wait(0.3)
                    if item and item.Parent then 
                        AdjustRemote:FireServer(item) 
                    end
                end)

                -- ၃။ မြေပေါ်မှာ ၃၀ စက္ကန့် ဆွဲချထားခြင်း
                print("🔋 Battery found nearby! Stunned for 30s.")
                groundStun(root, STUN_TIME)
                
                -- ၄။ Stun ပြီးမှ နောက်တစ်ခု ထပ်ရှာခွင့်ပေးမည်
                isCollecting = false
                
                -- ၅။ ကောက်ပြီးသား Item ကို list ထဲက ခဏဖယ်မည်
                task.delay(5, function() 
                    processed[item] = nil 
                end)
                
                break -- တစ်ကြိမ်လျှင် တစ်ခုသာ လုပ်ဆောင်မည်
            end
        end
    end
end)

print("Radius Battery TP (30s Stun) Loaded!")
