local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"


-- [[ LOADER ]] --
local scripts = {"modM.lua", "disabledAutoJump.lua"}

for _, file in ipairs(scripts) do
    local success, code = pcall(game.HttpGet, game, base .. file)
    if success then
        loadstring(code)()
    end
end
