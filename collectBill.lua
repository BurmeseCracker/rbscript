--// Auto Collect Bill Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

-- Your Tycoon path:
local Tycoon = workspace:WaitForChild("Tycoons"):WaitForChild("Tycoon")
local SurfaceItems = Tycoon.Items:WaitForChild("Surface")

--// Collects bill safely
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") 
        or furniture:WaitForChild("Bill", 3) -- wait max 3 sec

    if not bill then
        warn("No Bill found")
        return
    end

    -- Fire task to server
    TaskCompleted:FireServer({
        Name = "CollectBill";
        FurnitureModel = furniture;
        Tycoon = Tycoon;
    })

    print("Collected Bill from furniture")
end

--// Connect when Bill appears
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

--// Scan existing furniture
for _, furniture in ipairs(SurfaceItems:GetChildren()) do
    onNewFurniture(furniture)
end

--// Detect new furniture
SurfaceItems.ChildAdded:Connect(function(furniture)
    onNewFurniture(furniture)
end)

print("Auto-bill collector enabled!") -- FIXED
