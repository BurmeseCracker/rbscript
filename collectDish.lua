local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local TaskCompleted = ReplicatedStorage.Events.Restaurant.TaskCompleted
local TaskEnum = require(ReplicatedStorage.Source.Enums.Restaurant.Task)
local TweenInfo_new = TweenInfo.new(0.25)

-- Wait for the Tycoons folder
local TycoonsFolder = workspace:WaitForChild("Tycoons")

-- Find the first tycoon that has Items.Surface
local Tycoon
repeat
    task.wait(1)
    for _, t in ipairs(TycoonsFolder:GetChildren()) do
        if t:FindFirstChild("Items") and t.Items:FindFirstChild("Surface") then
            Tycoon = t
            print("✅ Found Tycoon:", Tycoon.Name)
            break
        end
    end
until Tycoon

local Surface = Tycoon.Items.Surface

-- Animation function
local function PlayCollectionAnimation(trashModel)
    local Character = LocalPlayer.Character
    if not Character or not Character:FindFirstChild("HumanoidRootPart") then 
        return 
    end
    local Position = Character.HumanoidRootPart.Position
    for _, part in ipairs(trashModel:GetChildren()) do
        if part:IsA("BasePart") and part.Transparency ~= 1 then
            part.CanCollide = false
            TweenService:Create(part, TweenInfo_new, {
                Position = Vector3.new(Position.X, part.Position.Y, Position.Z),
                Size = part.Size / 2,
                Transparency = 1,
            }):Play()
        end
    end
end

-- Collect Trash function
local function CollectTrash(furniture)
    local Trash = furniture:FindFirstChild("Trash")
    if not Trash then
        return
    end

    for _, part in ipairs(Trash:GetChildren()) do
        if part.Name ~= "Drink" then
            PlayCollectionAnimation(part)
        end
    end

    -- Fire server to collect dishes
    TaskCompleted:FireServer({
        Name = TaskEnum.CollectDishes,
        FurnitureModel = furniture,
        Tycoon = Tycoon
    })

    print("Collected Trash from furniture:", furniture.Name)
end

-- Handle furniture and dynamic Trash
local function HandleFurniture(furniture)
    -- Collect Trash immediately if exists
    if furniture:FindFirstChild("Trash") then
        CollectTrash(furniture)
    end

    -- Listen for Trash added later
    furniture.ChildAdded:Connect(function(child)
        if child.Name == "Trash" then
            CollectTrash(furniture)
        end
    end)
end

-- Scan existing furniture
for _, furniture in ipairs(Surface:GetChildren()) do
    HandleFurniture(furniture)
end

-- Detect new furniture added dynamically
Surface.ChildAdded:Connect(function(furniture)
    HandleFurniture(furniture)
end)

print("✅ Auto-Trash collector enabled!")

