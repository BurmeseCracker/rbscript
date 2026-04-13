local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- CONFIG: This pulls your text dynamically
local TXT_URL = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/update.txt"

-- Fetch the text from your .txt file
local success, updateNote = pcall(function() return game:HttpGet(TXT_URL) end)
updateNote = success and updateNote or "No update notes found."

local screenGui = Instance.new("ScreenGui", CoreGui)
screenGui.IgnoreGuiInset = true

local main = Instance.new("Frame", screenGui)
main.Size = UDim2.new(0, 320, 0, 260)
main.Position = UDim2.new(0.5, -160, 0.5, -130)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 15)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "LOG UPDATES"
title.TextColor3 = Color3.fromRGB(255, 215, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 15)

local body = Instance.new("TextLabel", main)
body.Size = UDim2.new(1, -30, 0, 120)
body.Position = UDim2.new(0, 15, 0, 65)
body.Text = updateNote -- This is the text from your update.txt!
body.TextColor3 = Color3.new(1, 1, 1)
body.TextSize = 15
body.Font = Enum.Font.Gotham
body.TextXAlignment = Enum.TextXAlignment.Left
body.TextYAlignment = Enum.TextYAlignment.Top
body.TextWrapped = true
body.BackgroundTransparency = 1

local btn = Instance.new("TextButton", main)
btn.Size = UDim2.new(0, 240, 0, 50)
btn.Position = UDim2.new(0.5, -120, 1, -65)
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
btn.Text = "GOT IT!"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 18
btn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

btn.MouseButton1Click:Connect(function()
    _G.UpdateClosed = true
    screenGui:Destroy()
end)
