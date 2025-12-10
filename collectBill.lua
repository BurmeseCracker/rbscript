local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TaskCompleted = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Restaurant"):WaitForChild("TaskCompleted")

-- Wait for Tycoons folder
local TycoonsFolder = workspace:WaitForChild("Tycoons")

-- Wait until your own Tycoon exists
local MyTycoon
repeat
    task.wait(1)
    MyTycoon = TycoonsFolder:FindFirstChild(LocalPlayer.Name)
until MyTycoon

-- If Tycoon is not yours (failsafe)
if not MyTycoon then
    warn("Your Tycoon was not found! Script will not run.")
    LocalPlayer:Kick("No Tycoon found for your player!")
    return
end

-- Get Surface folder inside Items
local Surface = MyTycoon:WaitForChild("Items"):WaitForChild("Surface")

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
        Tycoon = MyTycoon;
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

print("✅ Auto-bill collector enabled! Only working on your Tycoon:", MyTycoon.Name)
