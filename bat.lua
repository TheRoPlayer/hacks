local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- // UI SETUP //
local screenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
screenGui.Name = "HyperScript_Main"
screenGui.ResetOnSpawn = false

-- OPEN BUTTON (Top of screen)
local openBtn = Instance.new("TextButton", screenGui)
openBtn.Size = UDim2.new(0, 150, 0, 40)
openBtn.Position = UDim2.new(0.5, -75, 0, 10)
openBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
openBtn.Text = "⚡ HYPERSCRIPT ⚡"
openBtn.Font = Enum.Font.LuckiestGuy
openBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
openBtn.TextSize = 18
local openStroke = Instance.new("UIStroke", openBtn)
openStroke.Color = Color3.fromRGB(0, 255, 255)
Instance.new("UICorner", openBtn)

-- MAIN FRAME
local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 300, 0, 450)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -225)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame)
local mainStroke = Instance.new("UIStroke", mainFrame)
mainStroke.Color = Color3.fromRGB(0, 255, 255)

local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "HYPERSCRIPT"
title.Font = Enum.Font.LuckiestGuy
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.TextSize = 24
title.BackgroundTransparency = 1

local closeMain = Instance.new("TextButton", mainFrame)
closeMain.Size = UDim2.new(0, 30, 0, 30)
closeMain.Position = UDim2.new(1, -35, 0, 10)
closeMain.Text = "X"
closeMain.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeMain.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", closeMain)

-- SCROLLING CONTAINER
local scroll = Instance.new("ScrollingFrame", mainFrame)
scroll.Size = UDim2.new(1, -20, 1, -70)
scroll.Position = UDim2.new(0, 10, 0, 60)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 3
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 8)

-- // HELPER: UI ELEMENTS //
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", scroll)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.Text = name .. ": OFF"
    btn.Font = Enum.Font.FredokaOne
    btn.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", btn)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

local function createInput(placeholder, callback)
    local box = Instance.new("TextBox", scroll)
    box.Size = UDim2.new(1, 0, 0, 35)
    box.PlaceholderText = placeholder
    box.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    box.TextColor3 = Color3.new(1, 1, 1)
    box.Font = Enum.Font.FredokaOne
    Instance.new("UICorner", box)
    box.FocusLost:Connect(function()
        local val = tonumber(box.Text)
        if val then callback(val) end
    end)
end

-- // FEATURES //

-- 1. Player Outline (ESP)
local outlinesActive = false
createToggle("PLAYER OUTLINES", function(state)
    outlinesActive = state
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            if state then
                local highlight = Instance.new("Highlight", p.Character)
                highlight.Name = "HyperHighlight"
                highlight.FillTransparency = 1
                highlight.OutlineColor = Color3.fromRGB(0, 255, 255)
            else
                if p.Character:FindFirstChild("HyperHighlight") then
                    p.Character.HyperHighlight:Destroy()
                end
            end
        end
    end
end)

-- 2. Speed & Jump
createInput("Set WalkSpeed", function(v) LocalPlayer.Character.Humanoid.WalkSpeed = v end)
createInput("Set JumpPower", function(v) 
    LocalPlayer.Character.Humanoid.UseJumpPower = true
    LocalPlayer.Character.Humanoid.JumpPower = v 
end)

-- 3. WASD Fly
local flying = false
local flySpeed = 50
local bv, bg

local function startFly()
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    bv = Instance.new("BodyVelocity", hrp)
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bg = Instance.new("BodyGyro", hrp)
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    
    task.spawn(function()
        while flying do
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
            bv.Velocity = dir.Unit * flySpeed
            if dir == Vector3.zero then bv.Velocity = Vector3.zero end
            bg.CFrame = cam
            RunService.RenderStepped:Wait()
        end
        bv:Destroy() bg:Destroy()
    end)
end
createToggle("FLY (WASD)", function(s) flying = s if s then startFly() end end)

-- 4. Player List (Health/Joined)
local function getJoinDate(p)
    local date = os.date("!*t", os.time() - (p.AccountAge * 86400))
    return date.month.."/"..date.year
end

local playerListBtn = Instance.new("TextButton", scroll)
playerListBtn.Size = UDim2.new(1, 0, 0, 40)
playerListBtn.Text = "VIEW PLAYERS"
playerListBtn.Font = Enum.Font.FredokaOne
playerListBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
playerListBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", playerListBtn)

playerListBtn.MouseButton1Click:Connect(function()
    local pFrame = Instance.new("Frame", screenGui)
    pFrame.Size = UDim2.new(0, 250, 0, 350)
    pFrame.Position = UDim2.new(0.5, 160, 0.5, -175)
    pFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    pFrame.Draggable = true
    pFrame.Active = true
    Instance.new("UICorner", pFrame)
    Instance.new("UIStroke", pFrame).Color = Color3.fromRGB(150, 0, 255)
    
    local pScroll = Instance.new("ScrollingFrame", pFrame)
    pScroll.Size = UDim2.new(1, -10, 1, -50)
    pScroll.Position = UDim2.new(0, 5, 0, 40)
    pScroll.BackgroundTransparency = 1
    pScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Instance.new("UIListLayout", pScroll)

    for _, p in pairs(Players:GetPlayers()) do
        local l = Instance.new("TextLabel", pScroll)
        l.Size = UDim2.new(1, 0, 0, 50)
        l.BackgroundTransparency = 1
        l.TextColor3 = Color3.new(1, 1, 1)
        l.Font = Enum.Font.FredokaOne
        l.TextSize = 12
        local hp = (p.Character and p.Character:FindFirstChild("Humanoid")) and p.Character.Humanoid.Health or 0
        l.Text = string.format("%s\nHP: %d | Joined: %s", p.Name, hp, getJoinDate(p))
    end
    
    local c = Instance.new("TextButton", pFrame)
    c.Size = UDim2.new(0, 25, 0, 25)
    c.Position = UDim2.new(1, -30, 0, 5)
    c.Text = "X"
    c.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    c.MouseButton1Click:Connect(function() pFrame:Destroy() end)
end)

-- 5. Model/Part Explorer (Page System)
local explorerBtn = Instance.new("TextButton", scroll)
explorerBtn.Size = UDim2.new(1, 0, 0, 40)
explorerBtn.Text = "EXPLORE MODELS/PARTS (BETA)"
explorerBtn.Font = Enum.Font.FredokaOne
explorerBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
explorerBtn.TextColor3 = Color3.new(1, 1, 1)
Instance.new("UICorner", explorerBtn)

explorerBtn.MouseButton1Click:Connect(function()
    print("⚠️ LAG WARNING: Loading Workspace...")
    -- (The page system logic from previous script can be pasted here)
end)

-- // TOGGLE MAIN MENU //
openBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = not mainFrame.Visible
end)
closeMain.MouseButton1Click:Connect(function() mainFrame.Visible = false end)
