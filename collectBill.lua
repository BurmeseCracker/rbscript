--// Auto Collect Bill Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

-- Wait for tycoon (NO owner checks, you keep your own “Tycoon” name)
local Tycoon = workspace:WaitForChild("Tycoons"):WaitForChild("Tycoon")

-- Items sometimes loads late, so wait safely
local Items = Tycoon:WaitForChild("Items", 10)
if not Items then
    warn("Items folder did NOT load")
    return
end

-- Surface folder also loads later
local SurfaceItems = Items:WaitForChild("Surface", 10)
if not SurfaceItems then
    warn("Surface folder missing")
    return
end

--// Collects bill safely
local function CollectBill(furniture)
    -- FIX: FireServer must exist before calling it
    if not TaskCompleted then
        warn("TaskCompleted event missing!")
        return
    end

    local bill = furniture:FindFirstChild("Bill") 
        or furniture:WaitForChild("Bill", 3)

    if not bill then
        return
    end

    -- FIX: Correct FireServer call so it doesn't error
    TaskCompleted:FireServer({
        Name = "CollectBill",
        FurnitureModel = furniture,
        Tycoon = Tycoon,
    })

    print("Collected bill")
end

--// Detect Bill on furniture
local function onNewFurniture(furniture)
    if furniture:FindFirstChild("Bill") then
        CollectBill(furniture)
    end

    furniture.ChildAdded:Connect(function(child)
        if child.Name == "Bill" then
            CollectBill(furniture)
        end
    end)
end

--// Scan old
for _, furniture in ipairs(SurfaceItems:GetChildren()) do
    onNewFurniture(furniture)
end

--// Scan new
SurfaceItems.ChildAdded:Connect(onNewFurniture)

print("Auto Bill Collector Loaded!")
