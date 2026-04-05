local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

local scripts = {
   
    "modM.lua",

   
    
}




-- Now load scripts
for _, file in ipairs(scripts) do
    local url = base .. file
    local code = game:HttpGet(url)
    loadstring(code)()
end
