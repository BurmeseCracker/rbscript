local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted
local TaskEnum = require(ReplicatedStorage.Source.Enums.Restaurant.Task)
local FurnitureUtility = require(ReplicatedStorage.Source.Utility.FurnitureUtility)

-- Wait for LocalPlayer's Tycoon
local Tycoon
repeat
    task.wait(1)
    Tycoon = workspace.Tycoons:FindFirstChild(LocalPlayer.Name)
until Tycoon and Tycoon:FindFirstChild("Items") and Tycoon.Items:FindFirstChild("Surface")

local Surface = Tycoon.Items:WaitForChild("Surface")

-- Collect Trash/Dishes instantly
local function CollectTrash(furniture)
    local trash = furniture:FindFirstChild("Trash")
    if trash and trash:GetAttribute("Collectable") then
        TaskCompleted:FireServer({
            Name = TaskEnum.CollectDishes;
            FurnitureModel = furniture;
            Tycoon = Tycoon;
        })
        print("Collected Trash from furniture:", furniture.Name)
    end
end

-- Handle all furniture in Surface
local function HandleFurniture(furniture)
    if FurnitureUtility:IsTable(furniture.Name) then
        CollectTrash(furniture)

        furniture.ChildAdded:Connect(function(child)
            if child.Name == "Trash" then
                CollectTrash(furniture)
            end
        end)
    end
end

-- Initial scan
for _, furniture in ipairs(Surface:GetChildren()) do
    HandleFurniture(furniture)
end

-- Detect new furniture
Surface.ChildAdded:Connect(function(furniture)
    HandleFurniture(furniture)
end)

-- Loop every second to catch any missed Trash/Dishes
task.spawn(function()
    while true do
        task.wait(1)
        for _, furniture in ipairs(Surface:GetChildren()) do
            HandleFurniture(furniture)
        end
    end
end)

print("Auto-Trash collector enabled for LocalPlayer!")
