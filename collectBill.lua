local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted

--// Wait for Tycoons folder
local TycoonsFolder = workspace:WaitForChild("Tycoons")

--// Wait until a Tycoon with Items exists
local Tycoon
repeat
    task.wait(1) -- check every second
    for _, t in ipairs(TycoonsFolder:GetChildren()) do
        if t:FindFirstChild("Items") then
            Tycoon = t
            break
        end
    end
until Tycoon

--// Wait for the Items folder inside that Tycoon
local SurfaceItems = Tycoon:WaitForChild("Items")

--// Collects bill safely
local function CollectBill(furniture)
    local bill = furniture:FindFirstChild("Bill") or furniture:WaitForChild("Bill", 3)
    if not bill then
        warn("No Bill found in:", furniture.Name)
        return
    end

    -- Fire task to server
    TaskCompleted:FireServer({
        Name = "CollectBill";
        FurnitureModel = furniture;
        Tycoon = Tycoon;
    })

    print("Collected Bill from furniture:", furniture.Name)
end

--// Connect when Bill appears
local function onNewFurniture(furniture)
    -- If Bill already exists immediately
    if furniture:FindFirstChild("Bill") then
        CollectBill(furniture)
    end

    -- Listen for Bill added later
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
