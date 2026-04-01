while task.wait(2)
do

local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

local scripts = {
   
    "trackerv1.lua",
    "trackerv2.lua",
    
}




-- Now load scripts
for _, file in ipairs(scripts) do
    local url = base .. file
    local code = game:HttpGet(url)
    loadstring(code)()
end

print("✅ All scripts loaded!")
end
