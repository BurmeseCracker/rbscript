local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local base = "https://raw.githubusercontent.com/BurmeseCracker/rbscript/refs/heads/main/"

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "BurmeseModMenu_V8_Final"

-- [ 1. DRAG LOGIC ]
local function MakeDraggable(UIElement)
    local dragging, dragInput, dragStart, startPos
    UIElement.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = UIElement.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            UIElement.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- [ 2. MAIN FRAME ]
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 215, 0, 520) 
MainFrame.Position = UDim2.new(0.5, -107, 0.5, -260)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BackgroundTransparency = 0.4
MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
MakeDraggable(MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Text = "MOD MENU V8"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 12)

local Scroll = Instance.new("ScrollingFrame", MainFrame)
Scroll.Size = UDim2.new(1, -16, 1, -65)
Scroll.Position = UDim2.new(0, 8, 0, 55)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 0
local UIList = Instance.new("UIListLayout", Scroll)
UIList.Padding = UDim.new(0, 6); UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- [ 3. CORE FUNCTIONS ]
local orderCount = 0

local function AddSection(text)
    orderCount = orderCount + 1
    local Header = Instance.new("TextLabel", Scroll)
    Header.Size = UDim2.new(1, 0, 0, 28)
    Header.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    Header.BackgroundTransparency = 0.5
    Header.Text = text
    Header.TextColor3 = Color3.new(1, 1, 1)
    Header.Font = Enum.Font.GothamBold
    Header.TextSize = 13
    Header.LayoutOrder = orderCount
    Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 6)
end

local function AddToggle(name, fileName)
    orderCount = orderCount + 1
    local Button = Instance.new("TextButton", Scroll)
    local scriptID = fileName:gsub(".lua", "")
    _G[scriptID] = false
    
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.Text = name .. " : OFF"
    Button.TextColor3 = Color3.new(0.9, 0.9, 0.9)
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 14
    Button.LayoutOrder = orderCount
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    
    Button.MouseButton1Click:Connect(function()
        _G[scriptID] = not _G[scriptID]
        if _G[scriptID] then
            Button.Text = name .. " : ON"
            Button.BackgroundColor3 = Color3.fromRGB(0, 180, 90)
            task.spawn(function()
                local success, code = pcall(function() return game:HttpGet(base .. fileName) end)
                if success then loadstring(code)() end
            end)
        else
            Button.Text = name .. " : OFF"
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
        end
    end)
end

local function AddSettingsButton(name, color, callback)
    orderCount = orderCount + 1
    local Button = Instance.new("TextButton", Scroll)
    Button.Size = UDim2.new(1, 0, 0, 40)
    Button.BackgroundColor3 = color
    Button.Text = name; Button.TextColor3 = Color3.new(1, 1, 1)
    Button.Font = Enum.Font.GothamBold; Button.TextSize = 14; Button.LayoutOrder = orderCount
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)
    Button.MouseButton1Click:Connect(callback)
end

-- [ 4. ICON BUTTON ]
local TopIconButton = Instance.new("TextButton", ScreenGui)
TopIconButton.Size = UDim2.new(0, 55, 0, 55)
TopIconButton.Position = UDim2.new(0, 15, 0, 15)
TopIconButton.BackgroundColor3 = Color3.new(0, 0, 0)
TopIconButton.BackgroundTransparency = 0.3
TopIconButton.Text = "MENU"; TopIconButton.TextSize = 12; TopIconButton.TextColor3 = Color3.new(1, 1, 1); TopIconButton.Font = Enum.Font.GothamBold
Instance.new("UICorner", TopIconButton).CornerRadius = UDim.new(1, 0)
MakeDraggable(TopIconButton)
TopIconButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

---------------------------------------------------
-- [ CONFIG ]
---------------------------------------------------
AddSection("PLAYER MENU")
AddToggle("Speed Hack", "speed.lua") 
AddToggle("Wall Hack", "noclip.lua")
AddToggle("AutoCollect Battery", "AutoCollectBattery.lua")
AddToggle("AutoCollect Fuel", "AutoCollectFuel.lua")

AddSection("TRACKERS MENU")
AddToggle("Locate Battery", "trackerv1.lua")
AddToggle("Locate Scraps", "trackerv2.lua")
AddToggle("Locate Foods", "trackerv3.lua")
AddToggle("Locate Fuel", "trackerv4.lua")
AddToggle("Locate Crate", "trackerv5.lua")

AddSection("SETTINGS MENU")
AddSettingsButton("CLOSE & DESTROY", Color3.fromRGB(180, 0, 0), function()
    -- ၁။ အကုန်ပိတ်မယ်
    _G["speed"] = false
    _G["noclip"] = false
    _G["trackerv1"] = false
    _G["trackerv2"] = false
    _G["trackerv3"] = false
    _G["trackerv4"] = false
    _G["trackerv5"] = false
    _G["AutoCollectBattery"] = false
    _G["AutoCollectFuel"] = false
    
    task.wait(0.3)
    
    -- ၂။ UI ကို ဖြတ်မယ်
    ScreenGui:Destroy()
    
    -- ၃။ Global Tables ရှင်းမယ်
    _G.activeBeams = nil
    _G.v3Beams = nil
    _G.v4Beams = nil
    _G.v5Beams = nil
    _G.AutoBatteryLoop = nil
    _G.AutoFuelLoop = nil
    
    print("Mod Menu V8 Destroyed!")
end)
---------------------------------------------------
