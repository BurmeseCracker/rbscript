local parent_folder = workspace:WaitForChild("segmentSystem")

local chest = workspace.Finish.Chest

local player = game.Players.LocalPlayer


local btn = game:GetService("StarterGui").HUD.RewardPopup.ClaimButton



for _, child_folder in ipairs(parent_folder:GetChildren()) do
	for _, part in ipairs(child_folder:GetDescendants()) do
		if part:IsA("BasePart") then
			local val = part:FindFirstChild("breakable")
			if val and val:IsA("BoolValue") and val.Value == true then
				part:Destroy()
			end
		end
	end
end

task.wait(7)
player.Character:MoveTo(chest.Position)

btn:Activate()
btn.MouseButton1Click:Fire()





