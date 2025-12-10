local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

--// Fix Tycoon path
local TycoonsFolder = workspace:WaitForChild("Tycoons")
local Tycoon = TycoonsFolder:GetChildren()[2] -- pick the 2nd tycoon

if not Tycoon then
    warn("Tycoon not found!")
    return
end

--// Use Items folder directly
local SurfaceItems = Tycoon:WaitForChild("Items")

--// Collects bill safely
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") or furniture:WaitForChild("Bill", 3)
    if not bill then
        warn("No Bill found in:", furniture.Name)
        return
    end

    TaskCompleted:FireServer({
        Name = "CollectBill";
        FurnitureModel = furniture;
        Tycoon = Tycoon;
    })

    print("Collected Bill from furniture:", furniture.Name)
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

--// Scan all existing furniture
for _, furniture in ipairs(SurfaceItems:GetChildren()) do
    onNewFurniture(furniture)
end

--// Detect new furniture added
SurfaceItems.ChildAdded:Connect(function(furniture)
    onNewFurniture(furniture)
end)

print("Auto-bill collector enabled!")
