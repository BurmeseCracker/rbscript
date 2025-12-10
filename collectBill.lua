local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

--// Find the correct Tycoon that belongs to the local player
local TycoonFolder = workspace:WaitForChild("Tycoons")
local MyTycoon = nil

-- Find tycoon that has your name OR pick index-2 safely
for _, t in ipairs(TycoonFolder:GetChildren()) do
    if t:FindFirstChild("Owner") and t.Owner.Value == LocalPlayer then
        MyTycoon = t
        break
    end
end

-- Fallback (your example: GetChildren()[2])
if not MyTycoon then
    MyTycoon = TycoonFolder:GetChildren()[2]
end

if not MyTycoon then
    warn("Tycoon not found!")
    return
end

-- Items folder inside the Tycoon
local Items = MyTycoon:WaitForChild("Items")

--// Collect Bill
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") or furniture:WaitForChild("Bill", 2)

    if not bill then
        return
    end

    TaskCompleted:FireServer({
        Name = "CollectBill",
        FurnitureModel = furniture,
        Tycoon = MyTycoon
    })

    print("Collected Bill from:", furniture.Name)
end

-- When a Furniture has Bill added
local function onFurniture(furniture)
    -- Bill already exists
    if furniture:FindFirstChild("Bill") then
        CollectBill(furniture)
    end

    -- Bill appears later
    furniture.ChildAdded:Connect(function(child)
        if child.Name == "Bill" then
            CollectBill(furniture)
        end
    end)
end

-- Scan existing items
for _, furniture in ipairs(Items:GetChildren()) do
    onFurniture(furniture)
end

-- Detect new items
Items.ChildAdded:Connect(function(furniture)
    onFurniture(furniture)
end)

print("Auto Bill Collector: ENABLED")
