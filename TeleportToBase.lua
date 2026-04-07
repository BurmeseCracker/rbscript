-- [[ SMOOTH SLOW VOID DROP ]] --

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function slowVoidDrop()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        print("Starting Smooth Drop to Void...")

        -- ၁။ Physics အရမ်းမြန်မနေအောင် ခဏ Anchor လုပ်ထားမယ် (Optional)
        -- hrp.Anchored = true 

        -- ၂။ ဖြည်းဖြည်းချင်း အောက်ကို လျှောချမယ် (အကြိမ် ၁၀၀ ခွဲပြီး ချပါမယ်)
        -- စုစုပေါင်း -100 studs ကို တစ်ခါချရင် -1 stud နှုန်းနဲ့ ချမှာပါ
        for i = 1, 100 do
            if hrp.Parent then
                -- လက်ရှိနေရာကနေ -1 stud စီ ဖြည်းဖြည်းချင်း ရွှေ့မယ်
                hrp.CFrame = hrp.CFrame * CFrame.new(0, -1, 0)
                
                -- ဒီနေရာမှာ အချိန် (Wait) ကို ညှိလို့ရပါတယ်။ 
                -- 0.05 က ပိုနှေးပြီး 0.01 က နည်းနည်းမြန်ပါမယ်။
                task.wait(0.03) 
            else
                break
            end
        end

        -- ၃။ အောက်ရောက်သွားပြီဆိုရင် ပုံမှန်အတိုင်း ပြုတ်ကျသွားအောင် လွှတ်ပေးလိုက်မယ်
        -- hrp.Anchored = false
        
        print("Smooth Drop Completed!")
    else
        warn("Character not found!")
    end
end

-- Script ကို Run သည်နှင့် အလုပ်လုပ်မည်
slowVoidDrop()
