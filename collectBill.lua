
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

-- Wait for Tycoons folder
local TycoonsFolder = workspace:WaitForChild("Tycoons")

-- Wait until a Tycoon with Items exists
local Tycoon
repeat
    task.wait(1)
    for _, t in ipairs(TycoonsFolder:GetChildren()) do
        if t:FindFirstChild("Items") and t.Items:FindFirstChild("Surface") then
            Tycoon = t
            break
        end
    end
until Tycoon

-- Get Surface folder inside Items
local Surface = Tycoon.Items:WaitForChild("Surface")

-- Function to collect a Bill from furniture safely
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") or furniture:WaitForChild("Bill", 3)
    if not bill then
        warn("No Bill found in:", furniture.Name)
        return
    end

    -- Fire server to collect the Bill
    TaskCompleted:FireServer({
        Name = "CollectBill";
        FurnitureModel = furniture;
        Tycoon = Tycoon;
    })

    print("Collected Bill from furniture:", furniture.Name)
end

-- Function to handle furniture
local function HandleFurniture(furniture)
    -- Check if Bill already exists
    if furniture:FindFirstChild("Bill") then
        CollectBill(furniture)
    end

    -- Listen for new Bill added later
    furniture.ChildAdded:Connect(function(child)
        if child.Name == "Bill" then
            CollectBill(furniture)
        end
    end)
end

-- Scan existing furniture in Surface
for _, furniture in ipairs(Surface:GetChildren()) do
    HandleFurniture(furniture)
end

-- Detect new furniture added to Surface
Surface.ChildAdded:Connect(function(furniture)
    HandleFurniture(furniture)
end)

print("Auto-bill collector enabled! All Bills will be collected automatically.")
