local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

local scripts = {
    "collectDish.lua",
    "collectBill.lua",
    "rushHour.lua",
}

-- Wait until your Tycoon exists
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TycoonsFolder = workspace:WaitForChild("Tycoons")

local Tycoon
repeat
    task.wait(1)
    Tycoon = TycoonsFolder:FindFirstChild(LocalPlayer.Name)
until Tycoon

print("✅ My Tycoon detected:", Tycoon.Name)

-- Now load scripts
for _, file in ipairs(scripts) do
    local url = base .. file
    local code = game:HttpGet(url)
    loadstring(code)()
end

print("✅ All scripts loaded!")
