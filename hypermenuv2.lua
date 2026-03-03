local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HyperMenu_ESP_Edition"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local function addCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or UDim.new(0, 12)
    corner.Parent = parent
end

local function addStroke(parent, color, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(0, 255, 150)
    stroke.Thickness = thickness or 1.5
    stroke.Transparency = 0.4
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = parent
end

local function createTween(obj, props, time, easing)
    local tweenInfo = TweenInfo.new(time or 0.4, easing or Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    TweenService:Create(obj, tweenInfo, props):Play()
end

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 340, 0, 460)
mainFrame.Position = UDim2.new(0.5, -170, 0.5, -230)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BackgroundTransparency = 0.05
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui
addCorner(mainFrame, UDim.new(0, 16))
addStroke(mainFrame, Color3.fromRGB(0, 255, 180), 2)

-- Cool gradient background
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 18))
}
gradient.Rotation = 45
gradient.Parent = mainFrame

-- Funky Side Decoration (thicker & glowing)
local sideBar = Instance.new("Frame")
sideBar.Size = UDim2.new(0, 48, 1, 0)
sideBar.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
sideBar.Parent = mainFrame
addCorner(sideBar, UDim.new(0, 16))
local sideGradient = Instance.new("UIGradient")
sideGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 180)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 180, 100))
}
sideGradient.Parent = sideBar

local sideTxt = Instance.new("TextLabel")
sideTxt.Size = UDim2.new(1, 0, 1, 0)
sideTxt.BackgroundTransparency = 1
sideTxt.Text = "H Y P E R"
sideTxt.TextColor3 = Color3.new(0,0,0)
sideTxt.Font = Enum.Font.FredokaOne
sideTxt.TextSize = 32
sideTxt.Rotation = -90
sideTxt.TextXAlignment = Enum.TextXAlignment.Center
sideTxt.TextYAlignment = Enum.TextYAlignment.Bottom
sideTxt.Parent = sideBar

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 0, 50)
title.Position = UDim2.new(0, 55, 0, 8)
title.Text = "HYPER MODS"
title.TextColor3 = Color3.fromRGB(0, 255, 150)
title.Font = Enum.Font.LuckiestGuy
title.TextSize = 34
title.BackgroundTransparency = 1
title.TextStrokeTransparency = 0.7
title.TextStrokeColor3 = Color3.new(0,0,0)
title.Parent = mainFrame

-- Scrolling Frame for all controls
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 150)
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 420) -- will auto-adjust later
scrollFrame.Parent = mainFrame
addCorner(scrollFrame)

-- Container inside scroll for easier organization
local container = Instance.new("Frame")
container.Size = UDim2.new(1, 0, 1, 0)
container.BackgroundTransparency = 1
container.Parent = scrollFrame

--- CHEAT TOGGLES ---
local flying = false
local noclip = false
local espActive = false
local flySpeed = 50
local bv, bg

-- (Your original FLY logic - unchanged)
RunService.RenderStepped:Connect(function()
    if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = player.Character.HumanoidRootPart
        if not bv or bv.Parent ~= hrp then
            bv = Instance.new("BodyVelocity", hrp)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bg = Instance.new("BodyGyro", hrp)
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.P = 9000
        end
        
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir -= Vector3.new(0,1,0) end
        
        bv.Velocity = moveDir * flySpeed
        bg.CFrame = camera.CFrame
        player.Character.Humanoid.PlatformStand = true
    else
        if bv then bv:Destroy() bv = nil end
        if bg then bg:Destroy() bg = nil end
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.PlatformStand = false
        end
    end
end)

-- (Your original NOCLIP logic - unchanged)
RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, v in pairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

-- (Your ESP system - unchanged, just keeping it as is)
local function applyESP(p) -- ... (your original applyESP function)
    -- [your full applyESP code here - I didn't paste it again to save space]
end

local function toggleESP(state)
    espActive = state
    if not state then
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("HyperESP") then
                p.Character.Head.HyperESP:Destroy()
            end
        end
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                -- [your ESP creation logic]
            end
        end
    end
end

--- Modern Toggle / Input Creator ---
local yOffset = 10
local spacing = 55

local function createToggle(txt, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 48)
    frame.Position = UDim2.new(0, 10, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = container
    addCorner(frame, UDim.new(0, 10))
    addStroke(frame, Color3.fromRGB(60,60,70), 1)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = txt
    label.TextColor3 = Color3.new(0.95,0.95,0.95)
    label.Font = Enum.Font.GothamSemibold
    label.TextSize = 18
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 38, 0, 22)
    indicator.Position = UDim2.new(1, -50, 0.5, -11)
    indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    indicator.Parent = frame
    addCorner(indicator, UDim.new(1,0))

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 18, 0, 18)
    dot.Position = UDim2.new(0, 2, 0.5, -9)
    dot.BackgroundColor3 = Color3.new(1,1,1)
    dot.Parent = indicator
    addCorner(dot, UDim.new(1,0))

    local active = false

    local function updateVisual()
        if active then
            createTween(indicator, {BackgroundColor3 = Color3.fromRGB(0, 255, 150)}, 0.25)
            createTween(dot, {Position = UDim2.new(0, 18, 0.5, -9)}, 0.25)
        else
            createTween(indicator, {BackgroundColor3 = Color3.fromRGB(80, 80, 90)}, 0.25)
            createTween(dot, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.25)
        end
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            active = not active
            updateVisual()
            callback(active)
            -- hover scale effect
            createTween(frame, {BackgroundColor3 = Color3.fromRGB(50,50,65)}, 0.15)
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            createTween(frame, {BackgroundColor3 = Color3.fromRGB(35,35,45)}, 0.25)
        end
    end)

    yOffset = yOffset + spacing
    scrollFrame.CanvasSize = UDim2.new(0,0,0, yOffset + 20)
end

local function createInput(ph, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -20, 0, 48)
    frame.Position = UDim2.new(0, 10, 0, yOffset)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    frame.Parent = container
    addCorner(frame, UDim.new(0, 10))
    addStroke(frame, Color3.fromRGB(60,60,70), 1)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -20, 1, -10)
    box.Position = UDim2.new(0, 10, 0, 5)
    box.BackgroundTransparency = 1
    box.PlaceholderText = ph
    box.PlaceholderColor3 = Color3.fromRGB(140,140,160)
    box.Text = ""
    box.TextColor3 = Color3.new(0.9,0.9,0.9)
    box.Font = Enum.Font.Gotham
    box.TextSize = 18
    box.ClearTextOnFocus = false
    box.Parent = frame

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(box.Text)
        end
    end)

    yOffset = yOffset + spacing
    scrollFrame.CanvasSize = UDim2.new(0,0,0, yOffset + 20)
end

-- Create all controls inside scroll
createToggle("FLY (WASD)", function(v) flying = v end)
createToggle("NOCLIP", function(v) noclip = v end)
createToggle("ESP / HEALTH / NAME", toggleESP)
createInput("WalkSpeed", function(t) 
    if player.Character and player.Character:FindFirstChild("Humanoid") then 
        player.Character.Humanoid.WalkSpeed = tonumber(t) or 16 
    end 
end)
createInput("JumpPower", function(t) 
    if player.Character and player.Character:FindFirstChild("Humanoid") then 
        player.Character.Humanoid.JumpPower = tonumber(t) or 50 
    end 
end)
createInput("Fly Speed", function(t) flySpeed = tonumber(t) or 50 end)

-- Top buttons (Close + Resize)
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 36, 0, 36)
close.Position = UDim2.new(1, -42, 0, 8)
close.Text = "×"
close.Font = Enum.Font.GothamBold
close.TextSize = 24
close.TextColor3 = Color3.new(1,0.3,0.3)
close.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
close.Parent = mainFrame
addCorner(close, UDim.new(0,10))

close.MouseEnter:Connect(function() createTween(close, {BackgroundColor3 = Color3.fromRGB(60,30,30)}, 0.2) end)
close.MouseLeave:Connect(function() createTween(close, {BackgroundColor3 = Color3.fromRGB(35,20,20)}, 0.2) end)

close.MouseButton1Click:Connect(function()
    createTween(mainFrame, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back)
    task.delay(0.45, function() mainFrame.Visible = false end)
    
    -- Notification (your original + slight animation)
    local n = Instance.new("Frame", screenGui)
    n.Size = UDim2.new(0, 260, 0, 70)
    n.Position = UDim2.new(0, -300, 0.88, 0)
    n.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    n.BackgroundTransparency = 0.1
    addCorner(n)
    local nt = Instance.new("TextLabel", n)
    nt.Size = UDim2.new(1,0,1,0)
    nt.BackgroundTransparency = 1
    nt.Text = "HyperMenu Closed!\nRight-Shift to Reopen"
    nt.Font = Enum.Font.GothamBold
    nt.TextColor3 = Color3.new(0,0,0)
    nt.TextSize = 18
    createTween(n, {Position = UDim2.new(0, 20, 0.88, 0)}, 0.6, Enum.EasingStyle.Back)
    task.delay(4, function() createTween(n, {BackgroundTransparency=1}, 0.5); task.delay(0.6, n.Destroy, n) end)
end)

-- Resize Button (crop-like icon)
local resizeBtn = Instance.new("TextButton")
resizeBtn.Size = UDim2.new(0, 36, 0, 36)
resizeBtn.Position = UDim2.new(1, -84, 0, 8)
resizeBtn.Text = "↔"
resizeBtn.Font = Enum.Font.GothamBold
resizeBtn.TextSize = 22
resizeBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
resizeBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 35)
resizeBtn.Parent = mainFrame
addCorner(resizeBtn, UDim.new(0,10))

resizeBtn.MouseEnter:Connect(function() createTween(resizeBtn, {BackgroundColor3 = Color3.fromRGB(40,60,60)}, 0.2) end)
resizeBtn.MouseLeave:Connect(function() createTween(resizeBtn, {BackgroundColor3 = Color3.fromRGB(25,35,35)}, 0.2) end)

-- Simple resize logic (you can drag the button to resize)
local resizing = false
local startMousePos, startFrameSize

resizeBtn.MouseButton1Down:Connect(function()
    resizing = true
    startMousePos = UserInputService:GetMouseLocation()
    startFrameSize = mainFrame.Size
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = false
    end
end)

RunService.RenderStepped:Connect(function()
    if resizing then
        local delta = UserInputService:GetMouseLocation() - startMousePos
        local newWidth = math.clamp(startFrameSize.X.Offset + delta.X, 280, 600)
        local newHeight = math.clamp(startFrameSize.Y.Offset + delta.Y, 380, 800)
        mainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
        -- The frame moves slightly toward cursor during resize (slide feel)
        local moveOffset = UDim2.new(0, delta.X * 0.15, 0, delta.Y * 0.15)
        mainFrame.Position = mainFrame.Position + moveOffset
    end
end)

-- Open animation on start
mainFrame.BackgroundTransparency = 1
mainFrame.Size = UDim2.new(0,0,0,0)
mainFrame.Visible = true
createTween(mainFrame, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 340, 0, 460)}, 0.6, Enum.EasingStyle.Back)

-- Toggle with Right Shift
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.RightShift then
        if mainFrame.Visible then
            createTween(mainFrame, {BackgroundTransparency = 1, Size = UDim2.new(0,0,0,0)}, 0.4, Enum.EasingStyle.Back)
            task.delay(0.45, function() mainFrame.Visible = false end)
        else
            mainFrame.Visible = true
            mainFrame.Size = UDim2.new(0,0,0,0)
            mainFrame.BackgroundTransparency = 1
            createTween(mainFrame, {BackgroundTransparency = 0.05, Size = UDim2.new(0, 340, 0, 460)}, 0.6, Enum.EasingStyle.Back)
        end
    end
end)
