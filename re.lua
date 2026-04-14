-- [[ restart.lua - Force Stop All Background Processes ]] --

local function ForceStop()
    print("Restarting all scripts...")

    -- 1. Reset all Toggle Flags
    local scripts = {
        "speed", "noclip", "jump", "kill", "hitbox", "anti-lag",
        "trackerv1", "trackerv2", "trackerv3", "trackerv4", "trackerv5"
    }

    for _, name in pairs(scripts) do
        _G[name] = false
    end

   
    -- 2. Disconnect Heartbeat Loops
    if _G.ScrapMasterLoop then
        _G.ScrapMasterLoop:Disconnect()
        _G.ScrapMasterLoop = nil
    end
    
    if _G.BatteryMasterLoop then
        _G.BatteryMasterLoop:Disconnect()
        _G.BatteryMasterLoop = nil
    end

    -- 3. Clear Visuals (Beams/ESP)
    if _G.ScrapBeams then
        for model, data in pairs(_G.ScrapBeams) do
            pcall(function()
                if data.beam then data.beam:Destroy() end
                if data.aP then data.aP:Destroy() end
                if data.aB then data.aB:Destroy() end
            end)
        end
        _G.ScrapBeams = {}
    end

    -- 4. Reset specific states
    _G.ScrapLoopRunning = false
    _G.ScrapMasterRunning = false
    
    print("All scripts forced to stop successfully.")
end

ForceStop()
