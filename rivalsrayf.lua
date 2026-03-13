-- ============================================================
--   HYPERCHEAT | RIVALS v2.0 — CLEAN REWRITE
--   F2 = toggle menu
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local DISCORD_LINK = "E"
local WEBSITE_LINK = "m"

-- ============================================================
--   WINDOW
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "HyperCheat | Rivals",
    LoadingTitle = "HyperCheat | Rivals",
    LoadingSubtitle = "by HyperCheat",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HyperCheat",
        FileName = "RivalsConfig"
    },
    KeySystem = false,
})

-- ============================================================
--   NOTIFY HELPER
-- ============================================================
local NotifEnabled = true
local function Notify(title, content, dur)
    if not NotifEnabled then return end
    Rayfield:Notify({ Title = title, Content = content, Duration = dur or 3 })
end

-- ============================================================
--   F2 TOGGLE (direct ScreenGui toggle — no missing method)
-- ============================================================
local MenuOpen = true

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        MenuOpen = not MenuOpen
        -- Find Rayfield ScreenGui and toggle it
        for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if v.Name == "Rayfield" then
                v.Enabled = MenuOpen
            end
        end
        UserInputService.MouseBehavior    = MenuOpen and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = MenuOpen
    end
end)

-- ============================================================
--   HOME TAB
-- ============================================================
local HomeTab = Window:CreateTab("Home", "home")
HomeTab:CreateSection("HyperCheat | Rivals")
HomeTab:CreateParagraph({
    Title = "Welcome!",
    Content = "F2 — Toggle Menu\nWASD — Fly\nSpace — Up  |  LCtrl — Down"
})
HomeTab:CreateSection("Community")
HomeTab:CreateButton({ Name = "Copy Website Link", Callback = function()
    setclipboard(WEBSITE_LINK)
    Notify("Website", "Copied: " .. WEBSITE_LINK, 3)
end })
HomeTab:CreateButton({ Name = "Copy Discord Link", Callback = function()
    setclipboard(DISCORD_LINK)
    Notify("Discord", "Copied: " .. DISCORD_LINK, 3)
end })

-- ============================================================
--   ESP TAB
-- ============================================================
local ESPTab = Window:CreateTab("ESP", "eye")

local ESPEnabled   = false
local ESPBoxes     = true
local ESPNames     = true
local ESPTracers   = true
local ESPHealth    = true
local ESPDistance  = true
local ESPMaxDist   = 1500
local ESPObjects   = {}

local function NewLine()
    local d = Drawing.new("Line")
    d.Visible = false
    d.Thickness = 1
    d.Color = Color3.fromRGB(255,50,50)
    return d
end

local function NewSquare()
    local d = Drawing.new("Square")
    d.Visible = false
    d.Thickness = 1.5
    d.Filled = false
    d.Color = Color3.fromRGB(255,50,50)
    return d
end

local function NewText()
    local d = Drawing.new("Text")
    d.Visible = false
    d.Size = 13
    d.Center = true
    d.Outline = true
    d.Color = Color3.fromRGB(255,255,255)
    return d
end

local function MakeESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end
    ESPObjects[player] = {
        Box       = NewSquare(),
        BoxOut    = NewSquare(),
        Name      = NewText(),
        Tracer    = NewLine(),
        HpBG      = NewSquare(),
        HpBar     = NewSquare(),
        DistLabel = NewText(),
    }
    ESPObjects[player].BoxOut.Color = Color3.fromRGB(0,0,0)
    ESPObjects[player].BoxOut.Thickness = 3
    ESPObjects[player].HpBG.Filled = true
    ESPObjects[player].HpBG.Color = Color3.fromRGB(0,0,0)
    ESPObjects[player].HpBar.Filled = true
    ESPObjects[player].DistLabel.Color = Color3.fromRGB(255,220,50)
    ESPObjects[player].DistLabel.Size = 11
end

local function RemoveESP(player)
    if not ESPObjects[player] then return end
    for _, d in pairs(ESPObjects[player]) do
        pcall(function() d:Remove() end)
    end
    ESPObjects[player] = nil
end

local function HideAll(obj)
    for _, d in pairs(obj) do
        d.Visible = false
    end
end

for _, p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    for player, obj in pairs(ESPObjects) do
        if not player or not player.Parent then
            RemoveESP(player)
            continue
        end

        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChildOfClass("Humanoid")

        if not ESPEnabled or not char or not root or not hum or hum.Health <= 0 then
            HideAll(obj)
            continue
        end

        local dist = (root.Position - Camera.CFrame.Position).Magnitude
        if dist > ESPMaxDist then HideAll(obj) continue end

        local rootSP, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then HideAll(obj) continue end

        local topSP = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3.2, 0))
        local botSP = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))

        local h = math.abs(topSP.Y - botSP.Y)
        local w = h * 0.55
        local x = rootSP.X - w / 2
        local y = topSP.Y

        -- Box
        if ESPBoxes then
            obj.BoxOut.Size = Vector2.new(w+2, h+2)
            obj.BoxOut.Position = Vector2.new(x-1, y-1)
            obj.BoxOut.Visible = true
            obj.Box.Size = Vector2.new(w, h)
            obj.Box.Position = Vector2.new(x, y)
            obj.Box.Visible = true
        else
            obj.Box.Visible = false
            obj.BoxOut.Visible = false
        end

        -- Name
        if ESPNames then
            obj.Name.Text = player.Name
            obj.Name.Position = Vector2.new(rootSP.X, y - 16)
            obj.Name.Visible = true
        else
            obj.Name.Visible = false
        end

        -- Tracer
        if ESPTracers then
            obj.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
            obj.Tracer.To   = Vector2.new(rootSP.X, rootSP.Y)
            obj.Tracer.Visible = true
        else
            obj.Tracer.Visible = false
        end

        -- Health bar
        if ESPHealth then
            local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barH = h * pct
            obj.HpBG.Size = Vector2.new(4, h)
            obj.HpBG.Position = Vector2.new(x - 7, y)
            obj.HpBG.Visible = true
            obj.HpBar.Size = Vector2.new(4, barH)
            obj.HpBar.Position = Vector2.new(x - 7, y + h - barH)
            obj.HpBar.Color = Color3.fromRGB(math.floor(255*(1-pct)), math.floor(255*pct), 0)
            obj.HpBar.Visible = true
        else
            obj.HpBG.Visible = false
            obj.HpBar.Visible = false
        end

        -- Distance
        if ESPDistance then
            obj.DistLabel.Text = math.floor(dist) .. "m"
            obj.DistLabel.Position = Vector2.new(rootSP.X, y + h + 2)
            obj.DistLabel.Visible = true
        else
            obj.DistLabel.Visible = false
        end
    end
end)

ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({ Name = "Enable ESP", CurrentValue = false, Flag = "ESPMain",
    Callback = function(v)
        ESPEnabled = v
        if not v then for _, obj in pairs(ESPObjects) do HideAll(obj) end end
        Notify("ESP", v and "Enabled" or "Disabled", 2)
    end })
ESPTab:CreateToggle({ Name = "Boxes",        CurrentValue = true,  Flag = "ESPBoxes",   Callback = function(v) ESPBoxes    = v end })
ESPTab:CreateToggle({ Name = "Names",        CurrentValue = true,  Flag = "ESPNames",   Callback = function(v) ESPNames    = v end })
ESPTab:CreateToggle({ Name = "Tracers",      CurrentValue = true,  Flag = "ESPTracers", Callback = function(v) ESPTracers  = v end })
ESPTab:CreateToggle({ Name = "Health Bars",  CurrentValue = true,  Flag = "ESPHealth",  Callback = function(v) ESPHealth   = v end })
ESPTab:CreateToggle({ Name = "Distance",     CurrentValue = true,  Flag = "ESPDist",    Callback = function(v) ESPDistance = v end })
ESPTab:CreateSection("Range")
ESPTab:CreateSlider({ Name = "Max Distance", Range = {100,5000}, Increment = 100, Suffix = "m", CurrentValue = 1500, Flag = "ESPMaxDist",
    Callback = function(v) ESPMaxDist = v end })

-- ============================================================
--   AIMBOT TAB
-- ============================================================
local AimbotTab = Window:CreateTab("Aimbot", "target")

local AimbotEnabled = false
local AimbotSilent  = false
local AimbotFOV     = 120
local AimbotSmooth  = 5
local AimbotPart    = "Head"
local AimbotShowFOV = false

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible   = false
FOVCircle.Color     = Color3.fromRGB(255,255,255)
FOVCircle.Thickness = 1
FOVCircle.Filled    = false
FOVCircle.Radius    = 120

local function GetTarget()
    local best, bestDist = nil, AimbotFOV
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local part = char:FindFirstChild(AimbotPart)
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health <= 0 then continue end
        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if onScreen then
            local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
            if d < bestDist then bestDist = d best = part end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius   = AimbotFOV
    FOVCircle.Visible  = AimbotShowFOV

    if not AimbotEnabled then return end
    local target = GetTarget()
    if not target then return end
    local sp, onScreen = Camera:WorldToViewportPoint(target.Position)
    if not onScreen then return end
    local center  = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local screenP = Vector2.new(sp.X, sp.Y)
    local delta   = screenP - center
    pcall(function()
        if AimbotSilent then
            mousemoverel(delta.X / AimbotSmooth, delta.Y / AimbotSmooth)
        else
            local smoothed = center:Lerp(screenP, 1 / AimbotSmooth)
            mousemoveabs(math.floor(smoothed.X), math.floor(smoothed.Y))
        end
    end)
end)

AimbotTab:CreateSection("Aim Settings")
AimbotTab:CreateToggle({ Name = "Enable Aimbot", CurrentValue = false, Flag = "AimbotOn",
    Callback = function(v) AimbotEnabled = v Notify("Aimbot", v and "Enabled" or "Disabled", 2) end })
AimbotTab:CreateToggle({ Name = "Silent Aim", CurrentValue = false, Flag = "SilentAim",
    Callback = function(v) AimbotSilent = v Notify("Silent Aim", v and "Enabled" or "Disabled", 2) end })
AimbotTab:CreateToggle({ Name = "Show FOV Circle", CurrentValue = false, Flag = "ShowFOV",
    Callback = function(v) AimbotShowFOV = v if not v then FOVCircle.Visible = false end end })
AimbotTab:CreateSection("FOV & Smoothness")
AimbotTab:CreateSlider({ Name = "FOV Radius", Range = {20,600}, Increment = 10, Suffix = "px", CurrentValue = 120, Flag = "AimbotFOV",
    Callback = function(v) AimbotFOV = v end })
AimbotTab:CreateSlider({ Name = "Smoothness", Range = {1,30}, Increment = 1, CurrentValue = 5, Flag = "AimbotSmooth",
    Callback = function(v) AimbotSmooth = v end })
AimbotTab:CreateSection("Target")
AimbotTab:CreateDropdown({ Name = "Aim Part", Options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso"},
    CurrentOption = {"Head"}, Flag = "AimbotPart", MultipleOptions = false,
    Callback = function(opt) AimbotPart = opt[1] or "Head" end })

-- ============================================================
--   MOVEMENT TAB
-- ============================================================
local MovementTab = Window:CreateTab("Movement", "move-up")

local FlyEnabled = false
local FlySpeed   = 60
local BV, BG, FlyConn = nil, nil, nil

local function StartFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    if BV then BV:Destroy() end
    if BG then BG:Destroy() end
    if FlyConn then FlyConn:Disconnect() end
    BV = Instance.new("BodyVelocity")
    BV.MaxForce = Vector3.new(1e9,1e9,1e9)
    BV.Velocity = Vector3.zero
    BV.Parent = root
    BG = Instance.new("BodyGyro")
    BG.MaxTorque = Vector3.new(1e9,1e9,1e9)
    BG.P = 10000
    BG.Parent = root
    hum.PlatformStand = true
    FlyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local cam  = workspace.CurrentCamera
        local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W)           then move += cam.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S)           then move -= cam.CFrame.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A)           then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D)           then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space)       then move += Vector3.new(0,1,0)     end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0)     end
        BV.Velocity = move.Magnitude > 0 and move.Unit * FlySpeed or Vector3.zero
        BG.CFrame   = cam.CFrame
    end)
end

local function StopFly()
    if FlyConn then FlyConn:Disconnect() end
    if BV then BV:Destroy() end
    if BG then BG:Destroy() end
    BV, BG, FlyConn = nil, nil, nil
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if FlyEnabled then StartFly() end
end)

MovementTab:CreateSection("Fly")
MovementTab:CreateToggle({ Name = "Fly", CurrentValue = false, Flag = "FlyOn",
    Callback = function(v)
        FlyEnabled = v
        if v then StartFly() else StopFly() end
        Notify("Fly", v and "Enabled" or "Disabled", 2)
    end })
MovementTab:CreateSlider({ Name = "Fly Speed", Range = {10,500}, Increment = 5, Suffix = " studs/s", CurrentValue = 60, Flag = "FlySpeed",
    Callback = function(v) FlySpeed = v end })

MovementTab:CreateSection("Walk & Jump")
MovementTab:CreateSlider({ Name = "Walk Speed", Range = {16,500}, Increment = 2, Suffix = " studs/s", CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(v)
        local char = LocalPlayer.Character
        if char then local h = char:FindFirstChildOfClass("Humanoid") if h then h.WalkSpeed = v end end
    end })
MovementTab:CreateSlider({ Name = "Jump Power", Range = {50,1000}, Increment = 10, Suffix = " force", CurrentValue = 50, Flag = "JumpPower",
    Callback = function(v)
        local char = LocalPlayer.Character
        if char then local h = char:FindFirstChildOfClass("Humanoid") if h then h.JumpPower = v end end
    end })

MovementTab:CreateSection("NoClip")
local NoClipEnabled = false
local NoClipConn    = nil
MovementTab:CreateToggle({ Name = "NoClip", CurrentValue = false, Flag = "NoClip",
    Callback = function(v)
        NoClipEnabled = v
        if v then
            NoClipConn = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if NoClipConn then NoClipConn:Disconnect() end
        end
        Notify("NoClip", v and "Enabled" or "Disabled", 2)
    end })

MovementTab:CreateButton({ Name = "Reset Speed & Jump", Callback = function()
    local char = LocalPlayer.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 h.JumpPower = 50 end
    end
    Notify("Reset", "Speed & Jump reset", 2)
end })

-- ============================================================
--   COMBAT TAB
-- ============================================================
local CombatTab = Window:CreateTab("Combat", "sword")

-- Kill Aura
local KillAuraEnabled = false
local KillAuraRange   = 15
local KillAuraDelay   = 0.1
local KillAuraLast    = 0
local KillAuraConn    = nil

CombatTab:CreateSection("Kill Aura")
CombatTab:CreateToggle({ Name = "Kill Aura", CurrentValue = false, Flag = "KillAura",
    Callback = function(v)
        KillAuraEnabled = v
        if v then
            KillAuraConn = RunService.Heartbeat:Connect(function()
                if not KillAuraEnabled then return end
                local now = tick()
                if now - KillAuraLast < KillAuraDelay then return end
                KillAuraLast = now
                local char = LocalPlayer.Character
                if not char then return end
                local root = char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    local ec = p.Character
                    if not ec then continue end
                    local er = ec:FindFirstChild("HumanoidRootPart")
                    local eh = ec:FindFirstChildOfClass("Humanoid")
                    if not er or not eh or eh.Health <= 0 then continue end
                    if (er.Position - root.Position).Magnitude <= KillAuraRange then
                        eh.Health = 0
                    end
                end
            end)
        else
            if KillAuraConn then KillAuraConn:Disconnect() end
        end
        Notify("Kill Aura", v and "Enabled" or "Disabled", 2)
    end })
CombatTab:CreateSlider({ Name = "Aura Range", Range = {5,100}, Increment = 1, Suffix = " studs", CurrentValue = 15, Flag = "KillAuraRange",
    Callback = function(v) KillAuraRange = v end })
CombatTab:CreateSlider({ Name = "Hit Delay (x0.1s)", Range = {1,20}, Increment = 1, CurrentValue = 1, Flag = "KillAuraDelay",
    Callback = function(v) KillAuraDelay = v * 0.1 end })

-- Infinite Ammo
local InfiniteAmmoConn = nil
CombatTab:CreateSection("Infinite Ammo")
CombatTab:CreateToggle({ Name = "Infinite Ammo", CurrentValue = false, Flag = "InfAmmo",
    Callback = function(v)
        if v then
            InfiniteAmmoConn = RunService.Heartbeat:Connect(function()
                local function scanTools(parent)
                    for _, tool in ipairs(parent:GetChildren()) do
                        if tool:IsA("Tool") then
                            for _, val in ipairs(tool:GetDescendants()) do
                                if (val:IsA("IntValue") or val:IsA("NumberValue")) then
                                    local n = val.Name:lower()
                                    if n:find("ammo") or n:find("bullet") or n:find("mag") or n:find("clip") then
                                        if val.Value < 999 then val.Value = 999 end
                                    end
                                end
                            end
                        end
                    end
                end
                scanTools(LocalPlayer.Character or game:GetService("Players").LocalPlayer.Character)
                scanTools(LocalPlayer.Backpack)
            end)
        else
            if InfiniteAmmoConn then InfiniteAmmoConn:Disconnect() end
        end
        Notify("Infinite Ammo", v and "Enabled" or "Disabled", 2)
    end })

-- Anti-Ragdoll
local AntiRagdollConn = nil
CombatTab:CreateSection("Anti-Ragdoll")
CombatTab:CreateToggle({ Name = "Anti-Ragdoll", CurrentValue = false, Flag = "AntiRag",
    Callback = function(v)
        if v then
            AntiRagdollConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if hum:GetState() == Enum.HumanoidStateType.Ragdoll
                    or hum:GetState() == Enum.HumanoidStateType.FallingDown then
                        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    end
                end
                for _, obj in ipairs(char:GetDescendants()) do
                    if (obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint"))
                    and obj.Name:lower():find("ragdoll") then
                        obj.Enabled = false
                    end
                end
            end)
        else
            if AntiRagdollConn then AntiRagdollConn:Disconnect() end
        end
        Notify("Anti-Ragdoll", v and "Enabled" or "Disabled", 2)
    end })

-- Custom Crosshair
local CrosshairEnabled = false
local CrosshairSize    = 10
local CrosshairColor   = Color3.fromRGB(255,50,50)
local CrosshairLines   = {}

local function RebuildCrosshair()
    for _, d in ipairs(CrosshairLines) do pcall(function() d:Remove() end) end
    CrosshairLines = {}
    if not CrosshairEnabled then return end
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    local s  = CrosshairSize
    local c  = CrosshairColor
    local function makeLine(x1,y1,x2,y2)
        local l = Drawing.new("Line")
        l.From = Vector2.new(x1,y1)
        l.To   = Vector2.new(x2,y2)
        l.Color = c l.Thickness = 1.5 l.Visible = true
        return l
    end
    CrosshairLines = {
        makeLine(cx-s-3, cy, cx-3,   cy),
        makeLine(cx+3,   cy, cx+s+3, cy),
        makeLine(cx, cy-s-3, cx, cy-3),
        makeLine(cx, cy+3,   cx, cy+s+3),
    }
end

RunService.RenderStepped:Connect(function()
    if not CrosshairEnabled or #CrosshairLines == 0 then return end
    local cx = Camera.ViewportSize.X / 2
    local cy = Camera.ViewportSize.Y / 2
    local s  = CrosshairSize
    CrosshairLines[1].From = Vector2.new(cx-s-3,cy) CrosshairLines[1].To = Vector2.new(cx-3,cy)
    CrosshairLines[2].From = Vector2.new(cx+3,cy)   CrosshairLines[2].To = Vector2.new(cx+s+3,cy)
    CrosshairLines[3].From = Vector2.new(cx,cy-s-3) CrosshairLines[3].To = Vector2.new(cx,cy-3)
    CrosshairLines[4].From = Vector2.new(cx,cy+3)   CrosshairLines[4].To = Vector2.new(cx,cy+s+3)
end)

CombatTab:CreateSection("Custom Crosshair")
CombatTab:CreateToggle({ Name = "Custom Crosshair", CurrentValue = false, Flag = "Crosshair",
    Callback = function(v)
        CrosshairEnabled = v
        RebuildCrosshair()
        Notify("Crosshair", v and "Enabled" or "Disabled", 2)
    end })
CombatTab:CreateSlider({ Name = "Size", Range = {3,30}, Increment = 1, Suffix = "px", CurrentValue = 10, Flag = "CrosshairSize",
    Callback = function(v) CrosshairSize = v end })
CombatTab:CreateDropdown({ Name = "Color", Options = {"Red","White","Green","Cyan","Yellow"}, CurrentOption = {"Red"},
    Flag = "CrosshairColor", MultipleOptions = false,
    Callback = function(opt)
        local map = { Red=Color3.fromRGB(255,50,50), White=Color3.fromRGB(255,255,255),
                      Green=Color3.fromRGB(50,255,50), Cyan=Color3.fromRGB(0,255,255), Yellow=Color3.fromRGB(255,255,0) }
        CrosshairColor = map[opt[1]] or Color3.fromRGB(255,50,50)
        for _, l in ipairs(CrosshairLines) do l.Color = CrosshairColor end
    end })

-- ==================== INSTANT KILL ON ROUND START ====================
CombatTab:CreateSection("Round Start Kill")

local RoundKillEnabled = false

CombatTab:CreateToggle({ Name = "Instant Kill on Round Start", CurrentValue = false, Flag = "RoundKill",
    Callback = function(v)
        RoundKillEnabled = v
        Notify("⚡ Round Kill", v and "Will kill all when round starts!" or "Disabled", 3)
    end })

CombatTab:CreateParagraph({
    Title = "ℹ️ How it works",
    Content = "When a new round starts and your character spawns, it will automatically kill all enemies within 0.5 seconds. Works by detecting CharacterAdded."
})

-- Hook CharacterAdded to instant kill everyone on spawn
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5) -- wait for round to properly load
    if not RoundKillEnabled then return end
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local killed = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local ec = p.Character
        if not ec then continue end
        local eh = ec:FindFirstChildOfClass("Humanoid")
        if eh and eh.Health > 0 then
            eh.Health = 0
            killed += 1
        end
    end
    if killed > 0 then
        Notify("⚡ Round Kill", "Killed " .. killed .. " players on spawn!", 4)
    end
end)

-- ==================== COMING SOON ====================
CombatTab:CreateSection("⏳ Coming Soon")
CombatTab:CreateParagraph({ Title = "🔒 Aimbot Triggerbot", Content = "Automatically shoots when crosshair is on an enemy. Coming in v3.0!" })
CombatTab:CreateParagraph({ Title = "🔒 Bullet Teleport", Content = "Teleports bullets directly to the enemy hitbox. Coming in v3.0!" })
CombatTab:CreateParagraph({ Title = "🔒 Auto Reload", Content = "Instantly reloads your weapon when empty. Coming in v3.0!" })
CombatTab:CreateParagraph({ Title = "🔒 Hit Prediction", Content = "Predicts enemy movement for better aimbot accuracy. Coming in v3.0!" })

-- ============================================================
--   MISC TAB
-- ============================================================
local MiscTab = Window:CreateTab("Misc", "star")

MiscTab:CreateSection("Visual")
MiscTab:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "Fullbright",
    Callback = function(v)
        local L = game:GetService("Lighting")
        L.Brightness = v and 10 or 2
        L.GlobalShadows = not v
        L.FogEnd = v and 999999 or 100000
        Notify("Fullbright", v and "Enabled" or "Disabled", 2)
    end })

MiscTab:CreateToggle({ Name = "Hide Other Players", CurrentValue = false, Flag = "HidePlayers",
    Callback = function(v)
        for _, p in ipairs(Players:GetPlayers()) do
            if p == LocalPlayer then continue end
            if p.Character then
                for _, part in ipairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.LocalTransparencyModifier = v and 1 or 0
                    end
                end
            end
        end
        Notify("👻 Hide Players", v and "Players hidden" or "Players visible", 2)
    end })

MiscTab:CreateToggle({ Name = "Third Person Camera", CurrentValue = false, Flag = "ThirdPerson",
    Callback = function(v)
        LocalPlayer.CameraMaxZoomDistance = v and 50 or 0.5
        LocalPlayer.CameraMinZoomDistance = v and 10 or 0.5
        Notify("📷 Camera", v and "Third person" or "First person", 2)
    end })

MiscTab:CreateSection("Physics")
MiscTab:CreateSlider({ Name = "Gravity", Range = {0,300}, Increment = 5, CurrentValue = 196, Flag = "Gravity",
    Callback = function(v) workspace.Gravity = v end })
MiscTab:CreateButton({ Name = "Reset Gravity", Callback = function()
    workspace.Gravity = 196.2
    Notify("Gravity", "Reset to default", 2)
end })

MiscTab:CreateSection("Utility")

MiscTab:CreateButton({ Name = "Teleport to Spawn", Callback = function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
    root.CFrame = spawn and (spawn.CFrame + Vector3.new(0,5,0)) or CFrame.new(0,10,0)
    Notify("Teleport", "Teleported to spawn", 2)
end })

MiscTab:CreateButton({ Name = "Teleport to Random Player", Callback = function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local others = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(others, p)
        end
    end
    if #others == 0 then Notify("Teleport", "No other players found!", 2) return end
    local target = others[math.random(1, #others)]
    root.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
    Notify("Teleport", "Teleported to " .. target.Name, 2)
end })

MiscTab:CreateDropdown({ Name = "Teleport to Player", Flag = "TeleportTarget", MultipleOptions = false,
    Options = (function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(names, p.Name) end
        end
        return names
    end)(),
    CurrentOption = {},
    Callback = function(opt)
        local name = opt[1]
        if not name then return end
        local target = Players:FindFirstChild(name)
        if not target or not target.Character then Notify("Teleport", "Player not found!", 2) return end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local eRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if root and eRoot then
            root.CFrame = eRoot.CFrame + Vector3.new(0, 3, 0)
            Notify("Teleport", "Teleported to " .. name, 2)
        end
    end })

MiscTab:CreateButton({ Name = "Kill All NPCs", Callback = function()
    local count = 0
    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("Humanoid") and v.Parent ~= LocalPlayer.Character then
            v.Health = 0
            count += 1
        end
    end
    Notify("NPCs", "Killed " .. count .. " NPCs", 3)
end })

MiscTab:CreateButton({ Name = "Rejoin Server", Callback = function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end })

MiscTab:CreateSection("Time & Weather")
MiscTab:CreateSlider({ Name = "Time of Day", Range = {0,24}, Increment = 1, Suffix = ":00", CurrentValue = 14, Flag = "TimeOfDay",
    Callback = function(v)
        game:GetService("Lighting").ClockTime = v
    end })
MiscTab:CreateToggle({ Name = "Freeze Time", CurrentValue = false, Flag = "FreezeTime",
    Callback = function(v)
        game:GetService("Lighting").ClockTime = v and 14 or 14
        -- Lock time by overriding each frame
        if v then
            _G.FreezeTimeConn = RunService.Heartbeat:Connect(function()
                game:GetService("Lighting").ClockTime = 14
            end)
        else
            if _G.FreezeTimeConn then _G.FreezeTimeConn:Disconnect() end
        end
        Notify("⏰ Time", v and "Frozen at midday" or "Unfrozen", 2)
    end })

-- ============================================================
--   SETTINGS TAB
-- ============================================================
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("Notifications")
SettingsTab:CreateToggle({ Name = "Enable Notifications", CurrentValue = true, Flag = "NotifsOn",
    Callback = function(v)
        NotifEnabled = v
        Rayfield:Notify({ Title = "Notifications", Content = v and "ON" or "OFF", Duration = 2 })
    end })

SettingsTab:CreateSection("Quick Disable")
SettingsTab:CreateButton({ Name = "Disable All ESP", Callback = function()
    ESPEnabled = false
    for _, obj in pairs(ESPObjects) do HideAll(obj) end
    Notify("ESP", "All off", 2)
end })
SettingsTab:CreateButton({ Name = "Disable Aimbot", Callback = function()
    AimbotEnabled = false
    AimbotSilent  = false
    FOVCircle.Visible = false
    Notify("Aimbot", "Disabled", 2)
end })
SettingsTab:CreateButton({ Name = "Reset Movement", Callback = function()
    StopFly() FlyEnabled = false
    NoClipEnabled = false
    if NoClipConn then NoClipConn:Disconnect() end
    local char = LocalPlayer.Character
    if char then
        local h = char:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed = 16 h.JumpPower = 50 h.PlatformStand = false end
    end
    workspace.Gravity = 196.2
    Notify("Reset", "Movement reset", 2)
end })

SettingsTab:CreateSection("Credits")
SettingsTab:CreateParagraph({ Title = "HyperCheat | Rivals v3.0",
    Content = "ESP ✅  Aimbot ✅  Movement ✅\nCombat ✅  Misc ✅  Round Kill ✅\n\n🌐 " .. WEBSITE_LINK .. "\n💬 " .. DISCORD_LINK })

-- ============================================================
--   LOADED
-- ============================================================
task.wait(0.8)
Rayfield:Notify({ Title = "HyperCheat | Rivals v3.0", Content = "All systems ready! F2 to toggle.\nConfig auto-saves!", Duration = 5 })
print("HyperCheat | Rivals v3.0 loaded!")
