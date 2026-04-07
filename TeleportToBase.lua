-- [[ ULTIMATE VOID DROP - 4 TIMES LOOP ]] --

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function ultimateVoidDrop()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        -- ၄ ကြိမ် လုပ်ဆောင်ရန် Loop ပတ်မည်
        for i = 1, 4 do
            print("Void Drop Round: " .. i)

            -- ၁။ Server ပြန်မဆွဲနိုင်အောင် ခေတ္တ Anchor လုပ်မယ်
            hrp.Anchored = true
            task.wait(0.1)

            -- ၂။ အောက်ကို -100 studs ချမယ် (စုစုပေါင်း ၄ ကြိမ်ဆိုတော့ -400 ကျော်သွားပါမယ်)
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -100, 0)
            
            -- ၃။ ဖြည်းဖြည်းချင်း ထပ်တွန်းချမည့် Loop (အသေးစား)
            for j = 1, 5 do
                hrp.CFrame = hrp.CFrame * CFrame.new(0, -10, 0)
                task.wait(0.03)
            end

            -- ၄။ Anchor ပြန်ဖြုတ်ပြီး အရှိန်နဲ့ ကျခိုင်းမယ်
            hrp.Anchored = false
            hrp.AssemblyLinearVelocity = Vector3.new(0, -250, 0)

            -- ၅။ နောက်တစ်ကြိမ် မစခင် ခဏစောင့်မယ်
            task.wait(0.5)
        end
        
        print("Completed 4 Rounds of Void Drop!")
    else
        warn("Character not found!")
    end
end

-- Script ကို Run သည်နှင့် အလုပ်လုပ်မည်
ultimateVoidDrop()
