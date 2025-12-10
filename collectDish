local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted
local TaskEnum = require(ReplicatedStorage.Source.Enums.Restaurant.Task)
local FurnitureUtility = require(ReplicatedStorage.Source.Utility.FurnitureUtility)

local collecting = false

-- Wait until LocalPlayer's Tycoon exists
local Tycoon
repeat
    task.wait(1)
    for _, t in ipairs(workspace.Tycoons:GetChildren()) do
        if t.Name == LocalPlayer.Name or (t:FindFirstChild("Owner") and t.Owner.Value == LocalPlayer) then
            Tycoon = t
            break
        end
    end
until Tycoon

-- Wait for Items folder
local ItemsFolder = Tycoon:WaitForChild("Items")
local Surface = ItemsFolder:WaitForChild("Surface")

-- Collect trash/dishes instantly
local function CollectTrash(furniture)
    if FurnitureUtility:IsTable(furniture.Name) then
        local trash = furniture:FindFirstChild("Trash")
        if trash and trash:GetAttribute("Collectable") then
            TaskCompleted:FireServer({
                Name = TaskEnum.CollectDishes;
                FurnitureModel = furniture;
                Tycoon = Tycoon;
            })
            print("Collected trash from furniture:", furniture.Name)
        end
    end
end

-- Handle furniture
local function HandleFurniture(furniture)
    CollectTrash(furniture)
end

-- Initial scan of furniture
for _, furniture in ipairs(Surface:GetChildren()) do
    HandleFurniture(furniture)
end

-- Detect new furniture added
Surface.ChildAdded:Connect(function(furniture)
    HandleFurniture(furniture)
end)

-- Loop periodically to catch any missed trash
while true do
    task.wait(1)
    for _, furniture in ipairs(Surface:GetChildren()) do
        HandleFurniture(furniture)
    end
end

print("Auto-trash collector enabled for LocalPlayer!")
