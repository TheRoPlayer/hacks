-- ============================================================
--   RIVALS MOD MENU — by Premium Scripts
--   Game: Rivals (Roblox FPS)
--   ✅ ESP — Boxes, Names, Health Bars, Tracers, Distance
--   ✅ Aimbot — Silent Aim, FOV, Smoothness, Part selector
--   ✅ Movement — Fly, WalkSpeed, JumpPower, NoClip
--   ✅ Misc — Fullbright, Gravity, Teleport
--   Press RightShift to toggle menu
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== WINDOW ====================
local Window = Rayfield:CreateWindow({
    Name = "HyperCheat | Rivals",
    LoadingTitle = "HyperCheat | Rivals",
    LoadingSubtitle = "Loading modules...",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HyperCheat",
        FileName = "RivalsConfig"
    },
    KeySystem = false,
})

-- ==================== NOTIFY HELPER ====================
local NotifEnabled = true
local function Notify(title, content, duration)
    if not NotifEnabled then return end
    Rayfield:Notify({ Title = title, Content = content, Duration = duration or 3 })
end

-- ============================================================
--   HOME TAB
-- ============================================================
local HomeTab = Window:CreateTab("Home", "home")
HomeTab:CreateSection("Rivals Hub")
HomeTab:CreateParagraph({
    Title = "👋 Welcome to HyperCheat!",
    Content =
        "Game: Rivals (Roblox FPS)\n\n" ..
        "• ESP — see enemies through walls\n" ..
        "• Aimbot — silent aim with FOV\n" ..
        "• Movement — fly, speed, jump\n" ..
        "• Misc — fullbright, gravity & more\n\n" ..
        "RightShift = toggle menu"
})
HomeTab:CreateParagraph({
    Title = "⌨️ Keybinds",
    Content =
        "RightShift — Toggle Menu\n" ..
        "WASD — Fly movement\n" ..
        "Space — Fly up\n" ..
        "LeftCtrl — Fly down"
})

-- ============================================================
--   ESP TAB
-- ============================================================
local ESPTab = Window:CreateTab("ESP", "eye")

-- All sub-features ON by default so ESP works immediately
local ESP = {
    Enabled = false,
    Boxes = true,
    Names = true,
    Tracers = true,
    HealthBars = true,
    Distance = true,
    MaxDist = 1500,
}

local ESPObjects = {}

local function MakeESPForPlayer(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local obj = {}

    obj.Box = Drawing.new("Square")
    obj.Box.Color = Color3.fromRGB(255, 50, 50)
    obj.Box.Thickness = 1.5
    obj.Box.Filled = false
    obj.Box.Visible = false

    obj.BoxOutline = Drawing.new("Square")
    obj.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    obj.BoxOutline.Thickness = 3
    obj.BoxOutline.Filled = false
    obj.BoxOutline.Visible = false

    obj.Name = Drawing.new("Text")
    obj.Name.Color = Color3.fromRGB(255, 255, 255)
    obj.Name.Size = 13
    obj.Name.Center = true
    obj.Name.Outline = true
    obj.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    obj.Name.Visible = false

    obj.Tracer = Drawing.new("Line")
    obj.Tracer.Color = Color3.fromRGB(255, 50, 50)
    obj.Tracer.Thickness = 1
    obj.Tracer.Visible = false

    obj.HealthBG = Drawing.new("Square")
    obj.HealthBG.Color = Color3.fromRGB(0, 0, 0)
    obj.HealthBG.Filled = true
    obj.HealthBG.Visible = false

    obj.HealthBar = Drawing.new("Square")
    obj.HealthBar.Filled = true
    obj.HealthBar.Visible = false

    obj.DistLabel = Drawing.new("Text")
    obj.DistLabel.Color = Color3.fromRGB(255, 220, 50)
    obj.DistLabel.Size = 11
    obj.DistLabel.Center = true
    obj.DistLabel.Outline = true
    obj.DistLabel.OutlineColor = Color3.fromRGB(0, 0, 0)
    obj.DistLabel.Visible = false

    ESPObjects[player] = obj
end

local function RemoveESPForPlayer(player)
    if not ESPObjects[player] then return end
    for _, d in pairs(ESPObjects[player]) do
        pcall(function() d:Remove() end)
    end
    ESPObjects[player] = nil
end

local function HideESPObj(obj)
    obj.Box.Visible = false
    obj.BoxOutline.Visible = false
    obj.Name.Visible = false
    obj.Tracer.Visible = false
    obj.HealthBG.Visible = false
    obj.HealthBar.Visible = false
    obj.DistLabel.Visible = false
end

-- Init ESP for existing players
for _, p in ipairs(Players:GetPlayers()) do
    MakeESPForPlayer(p)
end
Players.PlayerAdded:Connect(MakeESPForPlayer)
Players.PlayerRemoving:Connect(RemoveESPForPlayer)

-- Main ESP loop
RunService.RenderStepped:Connect(function()
    for player, obj in pairs(ESPObjects) do
        if not player or not player.Parent then
            RemoveESPForPlayer(player)
        else
            local char = player.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if not ESP.Enabled or not char or not root or not humanoid or humanoid.Health <= 0 then
                HideESPObj(obj)
            else
                local dist = (root.Position - Camera.CFrame.Position).Magnitude
                if dist > ESP.MaxDist then
                    HideESPObj(obj)
                else
                    -- Get screen positions
                    local rootPos, rootOnScreen = Camera:WorldToViewportPoint(root.Position)
                    local topPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
                    local botPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))

                    if not rootOnScreen then
                        HideESPObj(obj)
                    else
                        local screenH = math.abs(topPos.Y - botPos.Y)
                        local screenW = screenH * 0.55
                        local boxX = rootPos.X - screenW / 2
                        local boxY = topPos.Y

                        -- Box outline (black border)
                        if ESP.Boxes then
                            obj.BoxOutline.Size = Vector2.new(screenW + 2, screenH + 2)
                            obj.BoxOutline.Position = Vector2.new(boxX - 1, boxY - 1)
                            obj.BoxOutline.Visible = true

                            obj.Box.Size = Vector2.new(screenW, screenH)
                            obj.Box.Position = Vector2.new(boxX, boxY)
                            obj.Box.Visible = true
                        else
                            obj.Box.Visible = false
                            obj.BoxOutline.Visible = false
                        end

                        -- Name
                        if ESP.Names then
                            obj.Name.Text = player.Name
                            obj.Name.Position = Vector2.new(rootPos.X, boxY - 16)
                            obj.Name.Visible = true
                        else
                            obj.Name.Visible = false
                        end

                        -- Tracer (from bottom of screen)
                        if ESP.Tracers then
                            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            obj.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                            obj.Tracer.Visible = true
                        else
                            obj.Tracer.Visible = false
                        end

                        -- Health bar (left side of box)
                        if ESP.HealthBars then
                            local hpPct = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
                            local barH = screenH * hpPct
                            local r = math.floor(255 * (1 - hpPct))
                            local g = math.floor(255 * hpPct)

                            obj.HealthBG.Size = Vector2.new(4, screenH)
                            obj.HealthBG.Position = Vector2.new(boxX - 7, boxY)
                            obj.HealthBG.Visible = true

                            obj.HealthBar.Size = Vector2.new(4, barH)
                            obj.HealthBar.Position = Vector2.new(boxX - 7, boxY + screenH - barH)
                            obj.HealthBar.Color = Color3.fromRGB(r, g, 0)
                            obj.HealthBar.Visible = true
                        else
                            obj.HealthBG.Visible = false
                            obj.HealthBar.Visible = false
                        end

                        -- Distance
                        if ESP.Distance then
                            obj.DistLabel.Text = math.floor(dist) .. "m"
                            obj.DistLabel.Position = Vector2.new(rootPos.X, boxY + screenH + 2)
                            obj.DistLabel.Visible = true
                        else
                            obj.DistLabel.Visible = false
                        end
                    end
                end
            end
        end
    end
end)

-- ESP UI
ESPTab:CreateSection("Player ESP")

ESPTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPMain",
    Callback = function(v)
        ESP.Enabled = v
        if not v then
            for _, obj in pairs(ESPObjects) do HideESPObj(obj) end
        end
        Notify("👁 ESP", v and "Enabled" or "Disabled", 2)
    end,
})

ESPTab:CreateToggle({ Name = "Boxes", CurrentValue = true, Flag = "ESPBoxes",
    Callback = function(v) ESP.Boxes = v end })

ESPTab:CreateToggle({ Name = "Names", CurrentValue = true, Flag = "ESPNames",
    Callback = function(v) ESP.Names = v end })

ESPTab:CreateToggle({ Name = "Tracers", CurrentValue = true, Flag = "ESPTracers",
    Callback = function(v) ESP.Tracers = v end })

ESPTab:CreateToggle({ Name = "Health Bars", CurrentValue = true, Flag = "ESPHealth",
    Callback = function(v) ESP.HealthBars = v end })

ESPTab:CreateToggle({ Name = "Distance", CurrentValue = true, Flag = "ESPDist",
    Callback = function(v) ESP.Distance = v end })

ESPTab:CreateSection("Range")

ESPTab:CreateSlider({
    Name = "Max Distance",
    Range = {100, 5000},
    Increment = 100,
    Suffix = "m",
    CurrentValue = 1500,
    Flag = "ESPMaxDist",
    Callback = function(v) ESP.MaxDist = v end,
})

-- ============================================================
--   AIMBOT TAB
-- ============================================================
local AimbotTab = Window:CreateTab("Aimbot", "target")

local Aimbot = {
    Enabled = false,
    Silent = false,
    FOV = 120,
    Smoothing = 5,
    Part = "Head",
    ShowFOV = false,
}

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Radius = Aimbot.FOV

-- Get closest player in FOV
local function GetAimbotTarget()
    local closestPlayer = nil
    local closestDist = Aimbot.FOV
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if not char then continue end
        local part = char:FindFirstChild(Aimbot.Part)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if not part or not humanoid or humanoid.Health <= 0 then continue end

        local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local screenPos = Vector2.new(pos.X, pos.Y)
            local dist = (screenPos - center).Magnitude
            if dist < closestDist then
                closestDist = dist
                closestPlayer = part
            end
        end
    end
    return closestPlayer
end

-- Aimbot RenderStepped
RunService.RenderStepped:Connect(function()
    -- Update FOV circle
    if Aimbot.ShowFOV then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        FOVCircle.Radius = Aimbot.FOV
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end

    if not Aimbot.Enabled then return end
    local target = GetAimbotTarget()
    if not target then return end

    local targetPos, onScreen = Camera:WorldToViewportPoint(target.Position)
    if not onScreen then return end

    local screenPos = Vector2.new(targetPos.X, targetPos.Y)
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local smoothed = center:Lerp(screenPos, 1 / math.max(Aimbot.Smoothing, 1))

    -- Silent aim: deflect bullet direction toward target
    if Aimbot.Silent then
        -- Override mouse delta for silent aim via mousemoverel
        pcall(function()
            local delta = smoothed - center
            mousemoverel(delta.X / Aimbot.Smoothing, delta.Y / Aimbot.Smoothing)
        end)
    else
        -- Standard mouse snap
        pcall(function()
            mousemoveabs(math.floor(smoothed.X), math.floor(smoothed.Y))
        end)
    end
end)

-- Aimbot UI
AimbotTab:CreateSection("Aim Settings")

AimbotTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotOn",
    Callback = function(v)
        Aimbot.Enabled = v
        Notify("🎯 Aimbot", v and "Enabled" or "Disabled", 2)
    end,
})

AimbotTab:CreateToggle({
    Name = "Silent Aim",
    CurrentValue = false,
    Flag = "SilentAim",
    Callback = function(v)
        Aimbot.Silent = v
        Notify("🔇 Silent Aim", v and "Enabled" or "Disabled", 2)
    end,
})

AimbotTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = false,
    Flag = "ShowFOV",
    Callback = function(v)
        Aimbot.ShowFOV = v
        if not v then FOVCircle.Visible = false end
    end,
})

AimbotTab:CreateSection("FOV & Smoothness")

AimbotTab:CreateSlider({
    Name = "FOV Radius",
    Range = {20, 600},
    Increment = 10,
    Suffix = "px",
    CurrentValue = 120,
    Flag = "AimbotFOV",
    Callback = function(v) Aimbot.FOV = v end,
})

AimbotTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 30},
    Increment = 1,
    Suffix = "",
    CurrentValue = 5,
    Flag = "AimbotSmooth",
    Callback = function(v) Aimbot.Smoothing = v end,
})

AimbotTab:CreateSection("Target")

AimbotTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"},
    CurrentOption = {"Head"},
    Flag = "AimbotPart",
    MultipleOptions = false,
    Callback = function(opt)
        Aimbot.Part = opt[1] or "Head"
        Notify("🎯 Aim Part", "Targeting: " .. Aimbot.Part, 2)
    end,
})

-- ============================================================
--   MOVEMENT TAB
-- ============================================================
local MovementTab = Window:CreateTab("Movement", "move-up")

local Fly = {
    Enabled = false,
    Speed = 60,
    BV = nil,
    BG = nil,
    Conn = nil,
}

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    if Fly.BV then Fly.BV:Destroy() end
    if Fly.BG then Fly.BG:Destroy() end
    if Fly.Conn then Fly.Conn:Disconnect() end

    Fly.BV = Instance.new("BodyVelocity")
    Fly.BV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    Fly.BV.Velocity = Vector3.zero
    Fly.BV.Parent = root

    Fly.BG = Instance.new("BodyGyro")
    Fly.BG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    Fly.BG.P = 10000
    Fly.BG.Parent = root

    hum.PlatformStand = true

    Fly.Conn = RunService.RenderStepped:Connect(function()
        if not Fly.Enabled then return end
        local cam = workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        Fly.BV.Velocity = if move.Magnitude > 0 then move.Unit * Fly.Speed else Vector3.zero
        Fly.BG.CFrame = cam.CFrame
    end)
end

local function StopFly()
    if Fly.Conn then Fly.Conn:Disconnect() end
    if Fly.BV then Fly.BV:Destroy() end
    if Fly.BG then Fly.BG:Destroy() end
    Fly.BV, Fly.BG, Fly.Conn = nil, nil, nil
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if Fly.Enabled then StartFly() end
end)

MovementTab:CreateSection("Fly")

MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyOn",
    Callback = function(v)
        Fly.Enabled = v
        if v then StartFly() else StopFly() end
        Notify("✈️ Fly", v and "Enabled" or "Disabled", 2)
    end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 500},
    Increment = 5,
    Suffix = "studs/s",
    CurrentValue = 60,
    Flag = "FlySpeed",
    Callback = function(v) Fly.Speed = v end,
})

MovementTab:CreateSection("Walk & Jump")

MovementTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 500},
    Increment = 2,
    Suffix = "studs/s",
    CurrentValue = 16,
    Flag = "WalkSpeed",
    Callback = function(v)
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = v end
        end
    end,
})

MovementTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 1000},
    Increment = 10,
    Suffix = "force",
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v)
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChildOfClass("Humanoid")
            if h then h.JumpPower = v end
        end
    end,
})

MovementTab:CreateSection("NoClip")

local NoClip = { Enabled = false, Conn = nil }

MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(v)
        NoClip.Enabled = v
        if v then
            NoClip.Conn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if NoClip.Conn then NoClip.Conn:Disconnect() end
        end
        Notify("🚫 NoClip", v and "Enabled" or "Disabled", 2)
    end,
})

MovementTab:CreateButton({
    Name = "Reset Speed & Jump",
    Callback = function()
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 h.JumpPower = 50 end
        end
        Notify("🔄 Reset", "Speed & Jump back to default", 2)
    end,
})

-- ============================================================
--   MISC TAB
-- ============================================================
local MiscTab = Window:CreateTab("Misc", "star")

MiscTab:CreateSection("Visual")

MiscTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function(v)
        local L = game:GetService("Lighting")
        if v then
            L.Brightness = 10
            L.GlobalShadows = false
            L.FogEnd = 999999
        else
            L.Brightness = 2
            L.GlobalShadows = true
            L.FogEnd = 100000
        end
        Notify("💡 Fullbright", v and "Enabled" or "Disabled", 2)
    end,
})

MiscTab:CreateSection("Physics")

MiscTab:CreateSlider({
    Name = "Gravity",
    Range = {0, 300},
    Increment = 5,
    Suffix = "",
    CurrentValue = 196,
    Flag = "Gravity",
    Callback = function(v)
        workspace.Gravity = v
    end,
})

MiscTab:CreateButton({
    Name = "Reset Gravity",
    Callback = function()
        workspace.Gravity = 196.2
        Notify("🌍 Gravity", "Reset to default", 2)
    end,
})

MiscTab:CreateSection("Utility")

MiscTab:CreateButton({
    Name = "Teleport to Spawn",
    Callback = function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
        root.CFrame = spawn and (spawn.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 10, 0)
        Notify("🚀 Teleport", "Teleported to spawn", 2)
    end,
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        local TeleportService = game:GetService("TeleportService")
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end,
})

-- ============================================================
--   SETTINGS TAB
-- ============================================================
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("Notifications")

SettingsTab:CreateToggle({
    Name = "Enable Notifications",
    CurrentValue = true,
    Flag = "NotifsOn",
    Callback = function(v)
        NotifEnabled = v
        Rayfield:Notify({ Title = "Notifications", Content = v and "Turned ON" or "Turned OFF", Duration = 2 })
    end,
})

SettingsTab:CreateSection("Quick Reset")

SettingsTab:CreateButton({
    Name = "Disable All ESP",
    Callback = function()
        ESP.Enabled = false
        for _, obj in pairs(ESPObjects) do HideESPObj(obj) end
        Notify("👁 ESP", "All ESP off", 2)
    end,
})

SettingsTab:CreateButton({
    Name = "Disable Aimbot",
    Callback = function()
        Aimbot.Enabled = false
        Aimbot.Silent = false
        FOVCircle.Visible = false
        Notify("🎯 Aimbot", "Disabled", 2)
    end,
})

SettingsTab:CreateButton({
    Name = "Reset All Movement",
    Callback = function()
        StopFly()
        Fly.Enabled = false
        NoClip.Enabled = false
        if NoClip.Conn then NoClip.Conn:Disconnect() end
        local char = LocalPlayer.Character
        if char then
            local h = char:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = 16 h.JumpPower = 50 h.PlatformStand = false end
        end
        workspace.Gravity = 196.2
        Notify("🔄 Reset", "All movement reset", 2)
    end,
})

SettingsTab:CreateSection("Credits")
SettingsTab:CreateParagraph({
    Title = "HyperCheat | Rivals v1.0",
    Content = "ESP ✅  Aimbot ✅  Movement ✅  Misc ✅\n\nEnjoy and stay safe! 🎮"
})

-- ============================================================
--   LOADED
-- ============================================================
task.wait(0.8)
Rayfield:Notify({
    Title = "✅ HyperCheat | Rivals",
    Content = "ESP · Aimbot · Movement · Misc\nAll systems ready!",
    Duration = 5,
})
print("HyperCheat | Rivals loaded!")
