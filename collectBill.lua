local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

-- // Find your tycoon dynamically
local TycoonsFolder = workspace:WaitForChild("Tycoons")

local function getMyTycoon()
    for _, t in ipairs(TycoonsFolder:GetChildren()) do
        if t:GetAttribute("Owner") == LocalPlayer then
            return t
        end
    end
    return nil
end

local Tycoon = getMyTycoon()
if not Tycoon then
    warn("No tycoon found for player!")
    return
end

-- // Wait for server-generated folders
local Items = Tycoon:WaitForChild("Items", 10)
local SurfaceItems = Items and Items:WaitForChild("Surface", 10)

if not SurfaceItems then
    warn("SurfaceItems missing!")
    return
end

-- // Collect bill
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") or furniture:WaitForChild("Bill", 3)
    if not bill then return end

    TaskCompleted:FireServer({
        Name = "CollectBill";
        FurnitureModel = furniture;
        Tycoon = Tycoon;
    })

    print("Collected Bill")
end

-- // When furniture loads
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

-- // Scan existing
for _, furniture in ipairs(SurfaceItems:GetChildren()) do
    onNewFurniture(furniture)
end

-- // Listen for new furniture
SurfaceItems.ChildAdded:Connect(onNewFurniture)

print("Auto Bill Collector Loaded")
