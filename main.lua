-- [[ BURMESE MOD MENU - MASTER LOADER ]] --
local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

_G.UpdateClosed = false -- Initialize the signal

-- 1. Run the Template UI
local function startUpdateSplash()
    local success, code = pcall(function() return game:HttpGet(base .. "update.lua") end)
    if success then
        local func = loadstring(code)
        if func then 
            task.spawn(func) 
            print("Update Splash Displayed.")
        end
    else
        warn("Update UI failed to load, bypassing...")
        _G.UpdateClosed = true
    end
end

startUpdateSplash()

-- 2. THE WAIT SYSTEM
-- It will check every 0.2 seconds if the button was clicked
local timer = 0
while not _G.UpdateClosed do
    task.wait(0.2)
    timer = timer + 0.2
    if timer > 20 then -- Failsafe: if user sits there for 20s, just load anyway
        break 
    end
end

-- 3. LOAD REMAINING SCRIPTS
print("Loading Menu Scripts...")
local scriptsToLoad = {"modM.lua", "disabledAutoJump.lua"}

for _, scriptName in ipairs(scriptsToLoad) do
    local s, code = pcall(function() return game:HttpGet(base .. scriptName) end)
    if s then
        task.spawn(function()
            local run = loadstring(code)
            if run then run() end
        end)
        print("Successfully Loaded: " .. scriptName)
    else
        warn("Failed to fetch: " .. scriptName)
    end
end
