

--// Auto Collect Bill Script
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

------------------------------------------------------------
-- FIND REAL TYCOON SAFELY (No index, no owner check)
------------------------------------------------------------
local function GetRealTycoon()
    local Tycoons = workspace:WaitForChild("Tycoons")

    while true do
        for _, t in ipairs(Tycoons:GetChildren()) do
            local items = t:FindFirstChild("Items")
            local surface = items and items:FindFirstChild("Surface")

            if surface then
                print("Found Tycoon:", t.Name)
                return t, items, surface
            end
        end

        task.wait(0.2)
    end
end

local Tycoon, Items, SurfaceItems = GetRealTycoon()

------------------------------------------------------------
-- Collect Bill function (your original logic)
------------------------------------------------------------
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill")
        or furniture:WaitForChild("Bill", 3)

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

------------------------------------------------------------
-- When new furniture appears
------------------------------------------------------------
local function onNewFurniture(furniture)
    -- If Bill already exists
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

------------------------------------------------------------
-- Scan existing furniture
------------------------------------------------------------
for _, furniture in ipairs(SurfaceItems:GetChildren()) do
    onNewFurniture(furniture)
end

------------------------------------------------------------
-- New furniture added
------------------------------------------------------------
SurfaceItems.ChildAdded:Connect(function(furniture)
    onNewFurniture(furniture)
end)

print("Auto-bill collector enabled!")
