-- [[ ULTIMATE VOID DROP - ANCHOR METHOD ]] --

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function ultimateVoidDrop()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum then
        print("Initiating Secure Void Drop...")

        -- ၁။ Server က ပြန်မဆွဲနိုင်အောင် Character ကို အသေ (Anchor) အရင်လုပ်မယ်
        hrp.Anchored = true
        
        -- ၂။ ခဏစောင့်ပြီး Position ကို -100 studs ချမယ်
        task.wait(0.2)
        hrp.CFrame = hrp.CFrame * CFrame.new(0, -100, 0)
        
        -- ၃။ ထပ်ခါထပ်ခါ မူလနေရာပြန်ရောက်တာမျိုးမဖြစ်အောင် Loop သေးသေးလေးနဲ့ အောက်ကို ထပ်တွန်းမယ်
        for i = 1, 10 do
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -5, 0)
            task.wait(0.05)
        end
        
        -- ၄။ အောက်ရောက်သွားပြီဆိုမှ Anchor ပြန်ဖြုတ်မယ် (အောက်ကို တန်းပြုတ်ကျသွားစေရန်)
        task.wait(0.2)
        hrp.Anchored = false
        
        -- ၅။ အောက်ကို ကျဆင်းနှုန်းမြန်အောင် Velocity (အရှိန်) ပါ ထပ်ပေါင်းထည့်ပေးမယ်
        hrp.AssemblyLinearVelocity = Vector3.new(0, -200, 0)
        
        print("Void Drop Successful! Character is falling.")
    else
        warn("Character or HumanoidRootPart not found!")
    end
end

-- Script ကို Run သည်နှင့် အလုပ်လုပ်မည်
ultimateVoidDrop()
