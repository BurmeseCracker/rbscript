local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"
local RS = game:GetService("ReplicatedStorage")

-- [[ TARGETED DELETION ]] --
local function remove(path)
    if path then path:Destroy() end
end

-- Delete Cutscenes
remove(RS:FindFirstChild("Assets") and RS.Assets:FindFirstChild("Cutscenes"))

-- Delete Shake & ScreenEffects inside Modules > VFX
local vfx = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("VFX")
if vfx then
    remove(vfx:FindFirstChild("Shake"))
    remove(vfx:FindFirstChild("ScreenEffects"))
end

-- [[ LOADER ]] --
local scripts = {"modM.lua"}

for _, file in ipairs(scripts) do
    local success, code = pcall(game.HttpGet, game, base .. file)
    if success then
        loadstring(code)()
    end
end
