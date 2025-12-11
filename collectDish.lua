local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local module = require(LocalPlayer.PlayerScripts.Source.Modules.Tasks.CollectDishes)
local TaskEnum = require(ReplicatedStorage.Source.Enums.Restaurant.Task)
local FurnitureUtility = require(ReplicatedStorage.Source.Utility.FurnitureUtility)

local collectedParts = {}

-- Fast name check (skip 99% instantly)
local function IsLikelyTable(model)
	return model and model.Name:match("^T%d+$") ~= nil
end

local function TryCollect(Tycoon, PartModel)
	if not PartModel then return end
	if collectedParts[PartModel] then return end
	if not IsLikelyTable(PartModel) then return end

	-- Real check
	if not FurnitureUtility:IsTable(PartModel.Name) then
		return
	end

	local Trash = PartModel:FindFirstChild("Trash")
	if not Trash then
		return
	end

	if not Trash:GetAttribute("Collectable") then
		return
	end

	collectedParts[PartModel] = true

	-- Play animation
	for _, v in ipairs(Trash:GetChildren()) do
		if v.Name ~= "Drink" then
			module.PlayCollectionAnimation(v, Trash)
		end
	end

	-- Fire server
	ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
		Name = TaskEnum.CollectDishes,
		FurnitureModel = PartModel,
		Tycoon = Tycoon
	})
end

--------------------------------------------------------
-- AUTO WATCH SYSTEM
--------------------------------------------------------

local function WatchTable(Tycoon, PartModel)
	PartModel.ChildAdded:Connect(function(child)
		if child.Name == "Trash" then
			TryCollect(Tycoon, PartModel)
		end
	end)
end

local function WatchTycoon(tycoon)
	local items = tycoon:FindFirstChild("Items")
	if not items then
		tycoon.ChildAdded:Connect(function(c)
			if c.Name == "Items" then
				WatchTycoon(tycoon)
			end
		end)
		return
	end

	local surface = items:FindFirstChild("Surface")
	if not surface then
		items.ChildAdded:Connect(function(c)
			if c.Name == "Surface" then
				WatchTycoon(tycoon)
			end
		end)
		return
	end

	-- Watch existing tables
	for _, obj in ipairs(surface:GetChildren()) do
		if IsLikelyTable(obj) then
			WatchTable(tycoon, obj)
			TryCollect(tycoon, obj)
		end
	end

	-- Watch new server-created tables
	surface.ChildAdded:Connect(function(newPart)
		if IsLikelyTable(newPart) then
			WatchTable(tycoon, newPart)
			TryCollect(tycoon, newPart)
		end
	end)
end

-- Setup for all tycoons
for _, tycoon in ipairs(Workspace.Tycoons:GetChildren()) do
	WatchTycoon(tycoon)
end

Workspace.Tycoons.ChildAdded:Connect(WatchTycoon)

--------------------------------------------------------
-- SAFE LOOP (RUN FOREVER)
--------------------------------------------------------

task.spawn(function()
	while true do
		for _, tycoon in ipairs(Workspace.Tycoons:GetChildren()) do
			local items = tycoon:FindFirstChild("Items")
			if items then
				local surface = items:FindFirstChild("Surface")
				if surface then
					for _, part in ipairs(surface:GetChildren()) do
						TryCollect(tycoon, part)
                  
						task.wait() -- small yield avoids lag
					end
				end
			end
		end

		task.wait(3) -- re-run every 3 seconds
	end
end)
