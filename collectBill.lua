local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

-- Your Tycoon path:
local Tycoon = workspace:WaitForChild("Tycoons"):WaitForChild("Tycoon")
local SurfaceItems = Tycoon.Items:WaitForChild("Surface")

local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") 
        or furniture:WaitForChild("Bill", 3)

    if not bill then
        warn("No Bill found")
        return
    end

    -- ✨ IMPORTANT FIX — the game requires this
    if bill:GetAttribute("Taken") then
        warn("Bill exists but not ready (Taken = true)")
        return
    end

    TaskCompleted:FireServer({
        Name = "CollectBill";
        FurnitureModel = furniture;
        Tycoon = Tycoon;
    })

    print("Collected Bill")
end

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

for _, furniture in ipairs(SurfaceItems:GetChildren()) do
    onNewFurniture(furniture)
end

SurfaceItems.ChildAdded:Connect(function(furniture)
    onNewFurniture(furniture)
end)

print("Auto-bill collector enabled!")
