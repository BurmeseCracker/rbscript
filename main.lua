local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

local scripts = {
    "collectBill.lua",
    "rushHour.lua",
    "collectDish.lua",
  
    -- add more files here
}

for _, file in ipairs(scripts) do
    local url = base .. file
    local code = game:HttpGet(url)
    loadstring(code)()
end

print("All scripts loaded!")
