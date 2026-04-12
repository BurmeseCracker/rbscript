-- [[ ULTIMATE VOID DROP - NOCLIP & 4 TIMES LOOP ]] --

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local function ultimateVoidDrop()
    local char = player.Character
    if not char then return warn("Character not found!") end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    -- Noclip အလုပ်လုပ်ရန် logic (မြေပြင်ကို ဖောက်ထွက်ရန်)
    local noclipConnection
    noclipConnection = RunService.Stepped:Connect(function()
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        else
            noclipConnection:Disconnect()
        end
    end)

    if hrp and hum then
        -- ၄ ကြိမ် လုပ်ဆောင်ရန် Loop
        for i = 1, 3 do
       

            -- ၁။ Position ကို အောက်သို့ ရွှေ့ခြင်း
            hrp.Anchored = true
            task.wait(0.1)
            
            -- လက်ရှိနေရာထက် -150 studs အောက်ကို ရွှေ့မည်
            hrp.CFrame = hrp.CFrame * CFrame.new(0, -150, 0)
            hrp.Anchored = false

            -- ၂။ ကျဆင်းနေစဉ် အရှိန်မြှင့်ရန် Velocity ထည့်ခြင်း
            hrp.AssemblyLinearVelocity = Vector3.new(0, -500, 0)

            -- ၃။ ခေတ္တစောင့်ပြီး အရှိန်သတ်မည် (နောက်တစ်ကျော့ မစခင်)
            task.wait(0.6)
        end
        
        -- Noclip ကို ပြန်ပိတ်ရန် (Optional: အကယ်၍ အောက်ခြေရောက်လျှင် ပြန်ဖွင့်ချင်ပါက)
        task.wait(1)
        noclipConnection:Disconnect()
        print("Completed 4 Rounds of Noclip Void Drop!")
    end
end

-- Script Run မည်
ultimateVoidDrop()
