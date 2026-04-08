-- [[ AutoCollectBattery - No Anchor Version ]] --
local scriptID = "AutoCollectBattery" 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local SEARCH_FOLDER = workspace:WaitForChild("DroppedItems")

local PickUpRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Interaction"):WaitForChild("PickUpItem")
local AdjustRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Tools"):WaitForChild("AdjustBackpack")

-- Config
local MAX_DIST = 100 
local HOLD_TIME = 6 
local TARGET_NAMES = { ["Battery"] = true, ["Battery Pack"] = true }

local processed = {} 
local isCollecting = false

_G.AutoBatteryLoop = RunService.Heartbeat:Connect(function()
    if _G[scriptID] ~= true then return end

    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root or isCollecting then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if TARGET_NAMES[item.Name] and not processed[item] then
            local success, pos = pcall(function() return item:GetPivot().Position end)
            if not success then continue end
            
            if (root.Position - pos).Magnitude <= MAX_DIST then
                isCollecting = true
                processed[item] = true 
                
                -- ၁။ Teleport လုပ်မယ်
                root.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))

                -- ၂။ FORCE HOLD (Anchor အစားသုံးသည်)
                -- Character ကို အင်အားသုံးပြီး နေရာမှာ ရပ်ခိုင်းထားမယ်
                local attachment = Instance.new("Attachment", root)
                local alignPos = Instance.new("AlignPosition", root)
                alignPos.Attachment0 = attachment
                alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
                alignPos.Position = root.Position
                alignPos.MaxForce = 9999999
                alignPos.Responsiveness = 200

                -- ၃။ Remote ဖြင့် ကောက်မယ်
                task.spawn(function()
                    PickUpRemote:FireServer(item)
                    task.wait(0.2)
                    if item and item.Parent then AdjustRemote:FireServer(item) end
                end)

                -- ၄။ စောင့်ဆိုင်းပြီး Force ပြန်ဖြုတ်မယ်
                task.wait(HOLD_TIME)
                alignPos:Destroy()
                attachment:Destroy()
                
                isCollecting = false
                task.delay(2, function() processed[item] = nil end)
                break 
            end
        end
    end
end)
