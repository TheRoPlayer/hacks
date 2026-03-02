local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- // THEME CONFIG
local COLORS = {
    Bg = Color3.fromRGB(25, 5, 12),
    Sidebar = Color3.fromRGB(15, 3, 8),
    Accent = Color3.fromRGB(220, 40, 70),
    Text = Color3.fromRGB(255, 255, 255),
    Secondary = Color3.fromRGB(45, 12, 22)
}

-- // STATE TRACKER (For Toggles)
local Toggles = {
    Fly = false,
    Noclip = false,
    Fullbright = false,
    InfJump = false,
    NoSit = false,
    TPClick = false,
    LowRes = false,
    ZeroGrav = false
}

-- // GUI ROOT
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "HyperVoid_Toggles"
sg.ResetOnSpawn = false

-- // NOTIFICATION SYSTEM
local function notify(msg)
    local n = Instance.new("Frame", sg)
    n.Size = UDim2.new(0, 250, 0, 60)
    n.Position = UDim2.new(1, 10, 0.8, 0)
    n.BackgroundColor3 = COLORS.Sidebar
    Instance.new("UICorner", n)
    
    local t = Instance.new("TextLabel", n)
    t.Size = UDim2.new(1, -20, 1, 0); t.Position = UDim2.new(0, 15, 0, 0)
    t.Text = "HV >> " .. tostring(msg); t.TextColor3 = COLORS.Accent; t.Font = "GothamBold"; t.TextSize = 13; t.BackgroundTransparency = 1; t.TextXAlignment = "Left"
    
    TweenService:Create(n, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Position = UDim2.new(1, -260, 0.8, 0)}):Play()
    task.delay(2.5, function()
        TweenService:Create(n, TweenInfo.new(0.5), {Position = UDim2.new(1, 10, 0.8, 0)}):Play()
        task.wait(0.5); n:Destroy()
    end)
end

-- // INTRO ANIMATION
local function playIntro()
    local blur = Instance.new("BlurEffect", Lighting)
    local intro = Instance.new("TextLabel", sg)
    intro.Size = UDim2.new(0, 200, 0, 200)
    intro.Position = UDim2.new(0.5, -100, 0.5, -100)
    intro.Text = "HV"; intro.TextColor3 = COLORS.Accent; intro.Font = "GothamBlack"; intro.TextSize = 0; intro.BackgroundTransparency = 1; intro.Rotation = -180
    
    TweenService:Create(blur, TweenInfo.new(0.5), {Size = 25}):Play()
    TweenService:Create(intro, TweenInfo.new(1, Enum.EasingStyle.Back), {TextSize = 120, Rotation = 0}):Play()
    task.wait(1.5)
    TweenService:Create(intro, TweenInfo.new(0.8), {Rotation = 360, TextSize = 0}):Play()
    TweenService:Create(blur, TweenInfo.new(1), {Size = 0}):Play()
    task.wait(0.8); intro:Destroy(); blur:Destroy()
end

-- // MAIN WINDOW
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 550, 0, 500)
main.Position = UDim2.new(0.5, -275, 0.5, -250)
main.BackgroundColor3 = COLORS.Bg
main.Visible = false; main.Active = true; Instance.new("UICorner", main)

local top = Instance.new("TextLabel", main)
top.Size = UDim2.new(1, 0, 0, 45); top.Text = "HYPERVOID"; top.TextColor3 = COLORS.Accent; top.Font = "GothamBlack"; top.TextSize = 22; top.BackgroundTransparency = 1

local rb = Instance.new("Frame", main)
rb.Size = UDim2.new(0, 5, 1, 0); Instance.new("UICorner", rb)
RunService.RenderStepped:Connect(function() rb.BackgroundColor3 = Color3.fromHSV(tick() % 5 / 5, 0.8, 1) end)

local side = Instance.new("Frame", main)
side.Size = UDim2.new(0, 140, 1, -55); side.Position = UDim2.new(0, 10, 0, 50); side.BackgroundColor3 = COLORS.Sidebar; Instance.new("UICorner", side)

local pages = Instance.new("Frame", main)
pages.Size = UDim2.new(1, -170, 1, -60); pages.Position = UDim2.new(0, 165, 0, 50); pages.BackgroundTransparency = 1

local function createPage(name)
    local p = Instance.new("ScrollingFrame", pages)
    p.Name = name; p.Size = UDim2.new(1, 0, 1, 0); p.BackgroundTransparency = 1; p.Visible = false; p.ScrollBarThickness = 0; p.CanvasSize = UDim2.new(0, 0, 2.5, 0)
    Instance.new("UIListLayout", p).Padding = UDim.new(0, 8)
    return p
end

local mainTab = createPage("Main")
local execTab = createPage("Executor")

-- // UI BUILDERS
local function addToggle(p, n, c)
    local b = Instance.new("TextButton", p)
    b.Size = UDim2.new(1, -10, 0, 35); b.BackgroundColor3 = COLORS.Secondary; b.Text = n; b.TextColor3 = COLORS.Text; b.Font = "GothamBold"; b.TextSize = 12; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(c)
end

local function addInput(p, n, ph, c)
    local f = Instance.new("Frame", p); f.Size = UDim2.new(1, -10, 0, 40); f.BackgroundColor3 = COLORS.Secondary; Instance.new("UICorner", f)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.4, 0, 1, 0); l.Text = n; l.TextColor3 = COLORS.Text; l.BackgroundTransparency = 1; l.TextSize = 11
    local i = Instance.new("TextBox", f); i.Size = UDim2.new(0.5, 0, 0.7, 0); i.Position = UDim2.new(0.45, 0, 0.15, 0); i.PlaceholderText = ph; i.BackgroundColor3 = Color3.new(0,0,0); i.TextColor3 = COLORS.Text; Instance.new("UICorner", i)
    i.FocusLost:Connect(function() c(i.Text) end)
end

-- // COMMANDS (WITH TOGGLE OFF LOGIC)
local flySpeed = 50

addToggle(mainTab, "1. Toggle Fly", function() 
    Toggles.Fly = not Toggles.Fly
    notify("Fly: " .. (Toggles.Fly and "ENABLED" or "DISABLED"))
end)

addInput(mainTab, "2. Fly Speed", "50", function(v) 
    flySpeed = tonumber(v) or 50 
    notify("Fly Speed: " .. flySpeed) 
end)

addToggle(mainTab, "3. Toggle Noclip", function() 
    Toggles.Noclip = not Toggles.Noclip
    notify("Noclip: " .. (Toggles.Noclip and "ENABLED" or "DISABLED"))
end)

addInput(mainTab, "4. WalkSpeed", "16", function(v) 
    if player.Character then player.Character.Humanoid.WalkSpeed = tonumber(v) or 16 end 
end)

addInput(mainTab, "5. JumpPower", "50", function(v) 
    if player.Character then player.Character.Humanoid.JumpPower = tonumber(v) or 50 end 
end)

addToggle(mainTab, "6. Fullbright", function() 
    Toggles.Fullbright = not Toggles.Fullbright
    Lighting.Brightness = Toggles.Fullbright and 2 or 1
    Lighting.ClockTime = Toggles.Fullbright and 14 or 12
    notify("Fullbright: " .. (Toggles.Fullbright and "ON" or "OFF"))
end)

addToggle(mainTab, "7. Infinite Jump", function() 
    Toggles.InfJump = not Toggles.InfJump
    notify("Inf Jump: " .. (Toggles.InfJump and "ON" or "OFF"))
end)

addToggle(mainTab, "8. Ctrl+Click TP", function() 
    Toggles.TPClick = not Toggles.TPClick
    notify("Click TP: " .. (Toggles.TPClick and "ON" or "OFF"))
end)

addToggle(mainTab, "9. FOV 120", function() 
    camera.FieldOfView = (camera.FieldOfView == 70) and 120 or 70
    notify("FOV Switched")
end)

addToggle(mainTab, "10. No Sit", function() 
    Toggles.NoSit = not Toggles.NoSit
    notify("No Sit: " .. (Toggles.NoSit and "ON" or "OFF"))
end)

addToggle(mainTab, "11. Low Graphics", function() 
    Toggles.LowRes = not Toggles.LowRes
    for _,v in pairs(workspace:GetDescendants()) do 
        if v:IsA("BasePart") then v.Material = Toggles.LowRes and Enum.Material.SmoothPlastic or Enum.Material.Plastic end 
    end
    notify("Textures: " .. (Toggles.LowRes and "CLEARED" or "RESTORED"))
end)

addToggle(mainTab, "12. Zero Gravity", function() 
    Toggles.ZeroGrav = not Toggles.ZeroGrav
    workspace.Gravity = Toggles.ZeroGrav and 0 or 196.2
    notify("Gravity: " .. (Toggles.ZeroGrav and "ZERO" or "NORMAL"))
end)

addToggle(mainTab, "13. Remove Fog", function() Lighting.FogEnd = 9e9 notify("Fog Gone") end)
addToggle(mainTab, "14. Night Mode", function() Lighting.ClockTime = 0 notify("Midnight") end)
addToggle(mainTab, "15. Reset Player", function() player.Character:BreakJoints() end)

-- // EXECUTOR
local exBox = Instance.new("TextBox", execTab)
exBox.Size = UDim2.new(1, -10, 0, 250); exBox.MultiLine = true; exBox.BackgroundColor3 = Color3.new(0,0,0); exBox.TextColor3 = COLORS.Accent; exBox.Text = ""; Instance.new("UICorner", exBox)
addToggle(execTab, "EXECUTE", function() pcall(function() loadstring(exBox.Text)() end) notify("Executed") end)

-- // LOOPS
UserInputService.JumpRequest:Connect(function()
    if Toggles.InfJump and player.Character then player.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
end)

local m = player:GetMouse()
m.Button1Down:Connect(function()
    if Toggles.TPClick and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then player.Character:MoveTo(m.Hit.p) end
end)

RunService.Stepped:Connect(function()
    if Toggles.Noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
    if Toggles.NoSit and player.Character then player.Character.Humanoid.Sit = false end
end)

RunService.RenderStepped:Connect(function()
    if Toggles.Fly and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        local move = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown("W") then move = move + camera.CFrame.LookVector end
        if UserInputService:IsKeyDown("S") then move = move - camera.CFrame.LookVector end
        if UserInputService:IsKeyDown("A") then move = move - camera.CFrame.RightVector end
        if UserInputService:IsKeyDown("D") then move = move + camera.CFrame.RightVector end
        hrp.Velocity = move * flySpeed
        player.Character.Humanoid.PlatformStand = true
    elseif player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = false
    end
end)

-- Nav & Close
local close = Instance.new("TextButton", main)
close.Size = UDim2.new(0, 30, 0, 30); close.Position = UDim2.new(1, -35, 0, 5); close.Text = "X"; close.BackgroundColor3 = Color3.new(0.6, 0, 0); Instance.new("UICorner", close)
close.MouseButton1Click:Connect(function() main.Visible = false end)

local function nav(t, p, y)
    local b = Instance.new("TextButton", side)
    b.Size = UDim2.new(1, -10, 0, 35); b.Position = UDim2.new(0, 5, 0, y); b.Text = t; b.BackgroundColor3 = COLORS.Secondary; b.TextColor3 = COLORS.Text; Instance.new("UICorner", b)
    b.MouseButton1Click:Connect(function() for _, v in pairs(pages:GetChildren()) do v.Visible = false end p.Visible = true end)
end
nav("COMMANDS", mainTab, 10); nav("EXECUTOR", execTab, 55)

-- Draggable
local d, ds, sp
main.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = true ds = i.Position sp = main.Position end end)
UserInputService.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
    main.Position = UDim2.new(sp.X.Scale, sp.X.Offset + (i.Position - ds).X, sp.Y.Scale, sp.Y.Offset + (i.Position - ds).Y)
end end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end end)

playIntro()
main.Visible = true; mainTab.Visible = true; notify("HyperVoid V5 Loaded")
