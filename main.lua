local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

-- [[ LOADER ]] --

-- ၁။ Update Splash ကို အရင် Run မယ်
local success, updateCode = pcall(game.HttpGet, game, base .. "update.lua")
if success then
    _G.UpdateClosed = false -- အစမှာ false ထားမယ်
    loadstring(updateCode)()
end

-- ၂။ Close ခလုတ် နှိပ်မယ့်အချိန်ကို စောင့်မယ်
repeat task.wait(0.2) until _G.UpdateClosed == true

-- ၃။ ခလုတ်နှိပ်ပြီးမှ ကျန်တဲ့ Script တွေကို Run မယ်
local remainingScripts = {"modM.lua", "disabledAutoJump.lua"}

for _, file in ipairs(remainingScripts) do
    local success, code = pcall(game.HttpGet, game, base .. file)
    if success then
        print("Loading: " .. file)
        loadstring(code)()
    else
        warn("Failed to load: " .. file)
    end
end

print("All scripts loaded after announcement closed.")
