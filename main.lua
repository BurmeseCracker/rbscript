local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

-- [[ LOADER ]] --
_G.UpdateClosed = false -- Force reset to false at start

-- 1. Load Update Splash
local success, updateCode = pcall(function() return game:HttpGet(base .. "update.lua") end)
if success then
    print("Update GUI Executing...")
    task.spawn(function()
        loadstring(updateCode)()
    end)
else
    warn("Could not load update.lua, skipping to menu.")
    _G.UpdateClosed = true
end

-- 2. Wait for the "Got it" button
-- Added a safety counter so it doesn't freeze forever if update.lua fails
local timeout = 0
repeat 
    task.wait(0.5) 
    timeout = timeout + 1
until _G.UpdateClosed == true or timeout > 60 -- Wait max 30 seconds

-- 3. Run remaining scripts
local remainingScripts = {"modM.lua", "disabledAutoJump.lua"}

for _, file in ipairs(remainingScripts) do
    local s, code = pcall(function() return game:HttpGet(base .. file) end)
    if s then
        print("Successfully Loaded: " .. file)
        task.spawn(function() loadstring(code)() end)
    else
        warn("Failed to load: " .. file)
    end
end
