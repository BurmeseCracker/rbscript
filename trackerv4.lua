local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local pGui = player:WaitForChild("PlayerGui")
local SEARCH_FOLDER = workspace:WaitForChild("Structures")

-- Config
local TARGET_NAME = "Good BackPack"
local MAX_DISTANCE = 100

-- Create a simple ScreenGui and TextLabel
local function showPopup()
    local sg = Instance.new("ScreenGui")
    sg.Name = "BackpackFinderUI"
    sg.Parent = pGui
    
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(0, 250, 0, 50)
    txt.Position = UDim2.new(0.5, -125, 0.2, 0) -- Top center-ish
    txt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    txt.BackgroundTransparency = 0.5
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextScaled = true
    txt.Text = "🔥 GOOD BACKPACK FOUND NEARBY! 🔥"
    txt.Parent = sg
    
    -- Corner rounding for mobile look
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = txt

    -- Wait 10 seconds then remove UI and Script
    task.wait(10)
    sg:Destroy()
    script:Destroy() -- The script "kills" itself here
end

-- The loop that looks for the backpack
local connection
connection = RunService.Heartbeat:Connect(function()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for _, item in pairs(SEARCH_FOLDER:GetChildren()) do
        if item.Name == TARGET_NAME then
            local dist = (root.Position - item:GetPivot().Position).Magnitude
            
            if dist <= MAX_DISTANCE then
                connection:Disconnect() -- Stop the loop immediately
                showPopup() -- Trigger the popup and self-destruct
                break
            end
        end
    end
end)
