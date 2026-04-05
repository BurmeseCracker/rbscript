-- GitHub Script: RemoteDD.lua
local scriptID = "RemoteDD"
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- အရင်ရှိခဲ့တဲ့ Hook ကို ရှင်းမယ် (Duplicate မဖြစ်အောင်)
if _G.OldRemoteHook then 
    -- Hook ပြန်ဖြုတ်တဲ့ logic (လိုအပ်ရင်)
end

print("RemoteDD: Monitoring AutoTargetClient...")

-- [ FUNCTION: REMOTE OPTIMIZER ]
local function HookRemote()
    local char = localPlayer.Character
    if not char then return end
    
    local autoTarget = char:FindFirstChild("AutoTargetClient")
    if not autoTarget then return end
    
    local remote = autoTarget:FindFirstChild("UpdateNearbyTargets")
    if not remote or not remote:IsA("RemoteEvent") then return end

    -- Remote ရဲ့ FireServer ကို ကြားကနေ ဖြတ်ဖမ်းမယ် (Hooking)
    local oldFireServer
    oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- အကယ်၍ ဒီ Remote ကို ခေါ်တာဆိုရင်
        if self == remote and method == "FireServer" then
            -- ၁။ Menu မှာ OFF ထားရင် လုံးဝ မပို့ခိုင်းတော့ဘူး (Lag ကို ချက်ချင်းရပ်ပစ်မယ်)
            if _G[scriptID] == false then
                return -- အလုပ်မလုပ်ဘဲ ပြန်လှည့်သွားမယ်
            end
            
            -- ၂။ Target အရေအတွက် အရမ်းများနေရင် (ဥပမာ ၁၀ ခုထက်ကျော်ရင်) ဖြတ်ချမယ်
            if type(args[1]) == "table" and #args[1] > 10 then
                local optimizedArgs = {}
                for i = 1, 10 do
                    table.insert(optimizedArgs, args[1][i])
                end
                -- အကောင်ရေ လျှော့ပြီးမှ ပို့မယ် (Server ဝန်သက်သာအောင်)
                return oldFireServer(self, optimizedArgs)
            end
        end

        return oldFireServer(self, ...)
    end)
    
    print("RemoteDD: Hook Applied to UpdateNearbyTargets")
end

-- ဂိမ်းစတာနဲ့ သို့မဟုတ် Character ပြောင်းတိုင်း Hook လုပ်မယ်
localPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    HookRemote()
end)

-- ပထမဆုံးအကြိမ်အတွက် Run မယ်
HookRemote()
