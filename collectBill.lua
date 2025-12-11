-- Auto Bill Collector (robust + debug)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

-- get event safely
local okEvent, TaskCompleted = pcall(function()
	return ReplicatedStorage:WaitForChild("Events"):WaitForChild("Restaurant"):WaitForChild("TaskCompleted")
end)
if not okEvent or not TaskCompleted then
	warn("TaskCompleted event not found under ReplicatedStorage.Events.Restaurant")
	return
end

-- try to require the Task enum (safe)
local TaskEnum
pcall(function()
	TaskEnum = require(ReplicatedStorage.Source.Enums.Restaurant.Task)
end)

-- helper: find the tycoon model for a furniture (tries ancestors and a few heuristics)
local function FindTycoonForModel(model)
	local a = model
	while a and a ~= Workspace do
		-- if parent is the Tycoons folder, 'a' is the tycoon model
		if a.Parent == Workspace:FindFirstChild("Tycoons") then
			return a
		end
		-- if this ancestor has Items folder, assume it's the tycoon
		if a:FindFirstChild("Items") then
			return a
		end
		a = a.Parent
	end
	-- fallback: the nearest Model ancestor
	return model:FindFirstAncestorWhichIsA("Model")
end

-- small helper to build payload name (enum preferred)
local function GetCollectName()
	if TaskEnum and TaskEnum.CollectBill then
		return TaskEnum.CollectBill
	end
	return "CollectBill"
end

local function InstantCollectBill(furniture, bill)
	if not furniture or not bill then return end

	-- wait briefly to let server populate attributes (value, taken)
	task.wait(0.2)

	-- debug info
	local tycoon = FindTycoonForModel(furniture)
	print("Attempting Collect -> Furniture:", furniture:GetFullName())
	print("  Tycoon detected:", (tycoon and tycoon:GetFullName()) or "nil")
	print("  Bill exists:", bill and "yes" or "no")
	if bill then
		local attrs = bill:GetAttributes()
		if next(attrs) then
			print("  Bill attributes:")
			for k,v in pairs(attrs) do
				print("    ", k, "=", v)
			end
		end
	end

	-- if bill was already taken, skip
	if bill:GetAttribute("Taken") then
		print("  -> skip: Bill.Taken == true")
		return
	end

	-- build payload like the game expects
	local payload = {
		Name = GetCollectName(),
		FurnitureModel = furniture,
		Tycoon = tycoon
	}

	print("  -> firing TaskCompleted with payload:", payload)

	-- fire the server
	local ok, err = pcall(function()
		TaskCompleted:FireServer(payload)
	end)
	if not ok then
		warn("Failed to fire TaskCompleted:", err)
	else
		print("  -> fired TaskCompleted")
	end
end

-- Handle furniture: collect existing bill and watch for new bills
local function HandleFurniture(furniture)
	-- immediate collect if Bill already present
	local bill = furniture:FindFirstChild("Bill")
	if bill then
		InstantCollectBill(furniture, bill)
	end

	-- watch for Bill added later
	furniture.ChildAdded:Connect(function(child)
		if child.Name == "Bill" then
			-- wait up to 3 seconds for Bill children/attributes to appear
			local ok, theBill = pcall(function()
				return child -- child is the bill instance
			end)
			if ok and theBill then
				task.wait(3) -- allow server to set attributes before collecting
				InstantCollectBill(furniture, theBill)
			end
		end
	end)
end

-- Watch a tycoon surface folder
local function WatchTycoon(tycoon)
	if not tycoon then return end
	local items = tycoon:FindFirstChild("Items")
	if not items then return end
	local surface = items:FindFirstChild("Surface")
	if not surface then return end

	-- existing furniture
	for _, f in ipairs(surface:GetChildren()) do
		-- only attempt on likely table names to avoid unnecessary checks (optional)
		-- if f.Name:match("^T%d+$") then
			HandleFurniture(f)
		-- end
	end

	-- new furniture
	surface.ChildAdded:Connect(function(newF)
		-- if newF.Name:match("^T%d+$") then
			HandleFurniture(newF)
		-- end
	end)
end

-- initial setup for all existing tycoons
local tycoonsFolder = Workspace:WaitForChild("Tycoons")
for _, t in ipairs(tycoonsFolder:GetChildren()) do
	WatchTycoon(t)
end
tycoonsFolder.ChildAdded:Connect(function(t)
	WatchTycoon(t)
end)

print("Instant bill collector running (listening for Bill children). Watch F9 for debug output.")
