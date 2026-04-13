local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

_G.UpdateClosed = false 

-- Load the Template Dialog
local success, updateCode = pcall(function() return game:HttpGet(base .. "update.lua") end)
if success then
    task.spawn(function() loadstring(updateCode)() end)
else
    _G.UpdateClosed = true -- Skip if failed
end

-- Wait for "Got it!" click
local timeout = 0
repeat task.wait(0.5) timeout = timeout + 0.5 until _G.UpdateClosed == true or timeout > 20

-- Load Menu
local scripts = {"modM.lua", "disabledAutoJump.lua"}
for _, file in ipairs(scripts) do
    pcall(function() task.spawn(loadstring(game:HttpGet(base .. file))) end)
end

