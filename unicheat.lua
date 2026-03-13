-- ============================================================
--   HYPERCHEAT | UNIVERSAL v1.0 - FULL CLEANED VERSION
--   Works in ANY Roblox game!
--   F2 = Toggle Menu
-- ============================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

local DISCORD_LINK = "h"
local WEBSITE_LINK = "h"

-- ============================================================
--   WINDOW
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "HyperCheat | Universal",
    LoadingTitle = "HyperCheat | Universal",
    LoadingSubtitle = "Loading all modules...",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HyperCheat",
        FileName = "UniversalConfig"
    },
    KeySystem = false,
})

-- ============================================================
--   HELPERS
-- ============================================================
local NotifEnabled = true
local function Notify(title, content, dur)
    if not NotifEnabled then return end
    Rayfield:Notify({ Title = title, Content = content, Duration = dur or 3 })
end

local function GetChar() return LocalPlayer.Character end
local function GetRoot() return GetChar() and GetChar():FindFirstChild("HumanoidRootPart") end
local function GetHum()  return GetChar() and GetChar():FindFirstChildOfClass("Humanoid") end

-- ============================================================
--   F2 TOGGLE MENU
-- ============================================================
local MenuOpen = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F2 then
        MenuOpen = not MenuOpen
        for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do
            if v.Name == "Rayfield" then v.Enabled = MenuOpen end
        end
        UserInputService.MouseBehavior    = MenuOpen and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = MenuOpen
    end
end)

-- ============================================================
--   TAB: HOME
-- ============================================================
local HomeTab = Window:CreateTab("Home", "home")
HomeTab:CreateSection("HyperCheat | Universal")
HomeTab:CreateParagraph({ Title = "Welcome!", Content =
    "Works in ANY Roblox game!\n\n"..
    "F2 → Toggle Menu\n"..
    "WASD → Fly  |  Space → Up  |  LCtrl → Down\n\n"..
    "All settings save automatically." })
HomeTab:CreateSection("Game Info")
HomeTab:CreateParagraph({ Title = "Current Game", Content =
    "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .."\n"..
    "Place ID: " .. game.PlaceId .."\n"..
    "Players: " .. #Players:GetPlayers() })
HomeTab:CreateSection("Community")
HomeTab:CreateButton({ Name = "Copy Website", Callback = function()
    setclipboard(WEBSITE_LINK) Notify("Website", "Copied! "..WEBSITE_LINK, 3) end })
HomeTab:CreateButton({ Name = "Copy Discord", Callback = function()
    setclipboard(DISCORD_LINK) Notify("Discord", "Copied! "..DISCORD_LINK, 3) end })

-- ============================================================
--   TAB: MOVEMENT (already cleaned in previous message)
-- ============================================================
local MovTab = Window:CreateTab("Movement", "move-up")

-- Fly
local FlyEnabled = false
local FlySpeed   = 60
local BV, BG, FlyConn

local function StartFly()
    local char = GetChar() if not char then return end
    local root = GetRoot() local hum = GetHum()
    if not root or not hum then return end
    if BV then BV:Destroy() end if BG then BG:Destroy() end if FlyConn then FlyConn:Disconnect() end
    BV = Instance.new("BodyVelocity") BV.MaxForce = Vector3.new(1e9,1e9,1e9) BV.Velocity = Vector3.zero BV.Parent = root
    BG = Instance.new("BodyGyro") BG.MaxTorque = Vector3.new(1e9,1e9,1e9) BG.P = 10000 BG.Parent = root
    hum.PlatformStand = true
    FlyConn = RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local cam = workspace.CurrentCamera local move = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0,1,0) end
        BV.Velocity = move.Magnitude > 0 and move.Unit * FlySpeed or Vector3.zero
        BG.CFrame = cam.CFrame
    end)
end

local function StopFly()
    if FlyConn then FlyConn:Disconnect() end if BV then BV:Destroy() end if BG then BG:Destroy() end
    BV, BG, FlyConn = nil, nil, nil
    local hum = GetHum() if hum then hum.PlatformStand = false end
end

LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5) if FlyEnabled then StartFly() end end)

MovTab:CreateSection("Fly")
MovTab:CreateToggle({ Name = "Fly", CurrentValue = false, Flag = "FlyOn",
    Callback = function(v) FlyEnabled = v if v then StartFly() else StopFly() end Notify("Fly", v and "On" or "Off", 2) end })
MovTab:CreateSlider({ Name = "Fly Speed", Range = {10,500}, Increment = 5, Suffix = " studs/s", CurrentValue = 60, Flag = "FlySpeed",
    Callback = function(v) FlySpeed = v end })

MovTab:CreateSection("Walk & Jump")
MovTab:CreateSlider({ Name = "Walk Speed", Range = {16,500}, Increment = 2, Suffix = " studs/s", CurrentValue = 16, Flag = "WalkSpeed",
    Callback = function(v) local h = GetHum() if h then h.WalkSpeed = v end end })
MovTab:CreateSlider({ Name = "Jump Power", Range = {50,1000}, Increment = 10, Suffix = " force", CurrentValue = 50, Flag = "JumpPower",
    Callback = function(v) local h = GetHum() if h then h.JumpPower = v end end })
MovTab:CreateToggle({ Name = "Infinite Jump", CurrentValue = false, Flag = "InfJump",
    Callback = function(v)
        _G.InfJump = v
        if v and not _G.InfJumpConn then
            _G.InfJumpConn = UserInputService.JumpRequest:Connect(function()
                if not _G.InfJump then return end
                local h = GetHum() if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        end
        Notify("Infinite Jump", v and "On" or "Off", 2)
    end })

MovTab:CreateSection("NoClip")
local NoClipConn = nil
MovTab:CreateToggle({ Name = "NoClip", CurrentValue = false, Flag = "NoClip",
    Callback = function(v)
        if v then
            NoClipConn = RunService.Stepped:Connect(function()
                local char = GetChar() if not char then return end
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        else
            if NoClipConn then NoClipConn:Disconnect() end
        end
        Notify("NoClip", v and "On" or "Off", 2)
    end })

MovTab:CreateSection("Teleport")
MovTab:CreateButton({ Name = "To Spawn", Callback = function()
    local root = GetRoot() if not root then return end
    local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
    root.CFrame = spawn and (spawn.CFrame + Vector3.new(0,5,0)) or CFrame.new(0,10,0)
    Notify("Teleport", "Teleported to spawn", 2)
end })
MovTab:CreateButton({ Name = "To Random Player", Callback = function()
    local root = GetRoot() if not root then return end
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(list, p)
        end
    end
    if #list == 0 then Notify("Teleport", "No players found!", 2) return end
    local t = list[math.random(1,#list)]
    root.CFrame = t.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    Notify("Teleport", "Teleported to "..t.Name, 2)
end })
MovTab:CreateButton({ Name = "Reset Speed & Jump", Callback = function()
    local h = GetHum() if h then h.WalkSpeed = 16 h.JumpPower = 50 end
    Notify("Reset", "Speed & Jump reset", 2)
end })

-- ============================================================
--   TAB: COMBAT (God Mode + Kill Aura + more)
-- ============================================================
local CombatTab = Window:CreateTab("Combat", "sword")

-- God Mode
local GodModeConn = nil
CombatTab:CreateSection("God Mode")
CombatTab:CreateToggle({ Name = "God Mode", CurrentValue = false, Flag = "GodMode",
    Callback = function(v)
        if v then
            GodModeConn = RunService.Heartbeat:Connect(function()
                local h = GetHum() if h then h.Health = h.MaxHealth end
            end)
        else
            if GodModeConn then GodModeConn:Disconnect() end
        end
        Notify("God Mode", v and "On -- you are immortal!" or "Off", 2)
    end })

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
                local root = GetRoot() if not root then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p == LocalPlayer then continue end
                    local ec = p.Character if not ec then continue end
                    local er = ec:FindFirstChild("HumanoidRootPart")
                    local eh = ec:FindFirstChildOfClass("Humanoid")
                    if er and eh and eh.Health > 0 then
                        if (er.Position - root.Position).Magnitude <= KillAuraRange then
                            eh.Health = 0
                        end
                    end
                end
            end)
        else
            if KillAuraConn then KillAuraConn:Disconnect() end
        end
        Notify("Kill Aura", v and "On" or "Off", 2)
    end })
CombatTab:CreateSlider({ Name = "Aura Range", Range = {5,150}, Increment = 1, Suffix = " studs", CurrentValue = 15, Flag = "KillAuraRange",
    Callback = function(v) KillAuraRange = v end })
CombatTab:CreateSlider({ Name = "Hit Delay (x0.1s)", Range = {1,20}, Increment = 1, CurrentValue = 1, Flag = "KillAuraDelay",
    Callback = function(v) KillAuraDelay = v * 0.1 end })

-- Instant Kill on Spawn
local RoundKillEnabled = false
CombatTab:CreateSection("Round Start Kill")
CombatTab:CreateToggle({ Name = "Instant Kill on Spawn", CurrentValue = false, Flag = "RoundKill",
    Callback = function(v) RoundKillEnabled = v Notify("Round Kill", v and "Will kill all on spawn!" or "Off", 3) end })
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if not RoundKillEnabled then return end
    local killed = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local ec = p.Character if not ec then continue end
        local eh = ec:FindFirstChildOfClass("Humanoid")
        if eh and eh.Health > 0 then eh.Health = 0 killed += 1 end
    end
    if killed > 0 then Notify("Round Kill", "Killed "..killed.." players!", 4) end
end)

-- Infinite Ammo
local InfAmmoConn = nil
CombatTab:CreateSection("Infinite Ammo")
CombatTab:CreateToggle({ Name = "Infinite Ammo", CurrentValue = false, Flag = "InfAmmo",
    Callback = function(v)
        if v then
            InfAmmoConn = RunService.Heartbeat:Connect(function()
                local function scan(parent)
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
                local char = GetChar()
                if char then scan(char) end
                scan(LocalPlayer.Backpack)
            end)
        else
            if InfAmmoConn then InfAmmoConn:Disconnect() end
        end
        Notify("Infinite Ammo", v and "On" or "Off", 2)
    end })

-- ============================================================
--   TAB: ESP (full working version)
-- ============================================================
local ESPTab = Window:CreateTab("ESP", "eye")

local ESPEnabled  = false
local ESPBoxes = true local ESPNames = true
local ESPTracers = true local ESPHealth = true local ESPDistance = true
local ESPMaxDist  = 1500
local ESPObjects  = {}

local function NewLine()   local d=Drawing.new("Line")   d.Visible=false d.Thickness=1   d.Color=Color3.fromRGB(255,50,50) return d end
local function NewSquare() local d=Drawing.new("Square") d.Visible=false d.Thickness=1.5 d.Filled=false d.Color=Color3.fromRGB(255,50,50) return d end
local function NewText()   local d=Drawing.new("Text")   d.Visible=false d.Size=13 d.Center=true d.Outline=true d.Color=Color3.fromRGB(255,255,255) return d end

local function MakeESP(player)
    if player == LocalPlayer or ESPObjects[player] then return end
    local o = { Box=NewSquare(), BoxOut=NewSquare(), Name=NewText(), Tracer=NewLine(), HpBG=NewSquare(), HpBar=NewSquare(), Dist=NewText() }
    o.BoxOut.Color=Color3.fromRGB(0,0,0) o.BoxOut.Thickness=3
    o.HpBG.Filled=true o.HpBG.Color=Color3.fromRGB(0,0,0)
    o.HpBar.Filled=true o.Dist.Color=Color3.fromRGB(255,220,50) o.Dist.Size=11
    ESPObjects[player] = o
end
local function RemoveESP(player)
    if not ESPObjects[player] then return end
    for _, d in pairs(ESPObjects[player]) do pcall(function() d:Remove() end) end
    ESPObjects[player] = nil
end
local function HideESP(o) for _, d in pairs(o) do d.Visible=false end end

for _, p in ipairs(Players:GetPlayers()) do MakeESP(p) end
Players.PlayerAdded:Connect(MakeESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    for player, o in pairs(ESPObjects) do
        if not player or not player.Parent then RemoveESP(player) continue end
        local char=player.Character local root=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        if not ESPEnabled or not root or not hum or hum.Health<=0 then HideESP(o) continue end
        local dist=(root.Position-Camera.CFrame.Position).Magnitude
        if dist>ESPMaxDist then HideESP(o) continue end
        local rsp,onScreen=Camera:WorldToViewportPoint(root.Position)
        if not onScreen then HideESP(o) continue end
        local tsp=Camera:WorldToViewportPoint(root.Position+Vector3.new(0,3.2,0))
        local bsp=Camera:WorldToViewportPoint(root.Position-Vector3.new(0,3.2,0))
        local h=math.abs(tsp.Y-bsp.Y) local w=h*0.55 local x=rsp.X-w/2 local y=tsp.Y
        if ESPBoxes then
            o.BoxOut.Size=Vector2.new(w+2,h+2) o.BoxOut.Position=Vector2.new(x-1,y-1) o.BoxOut.Visible=true
            o.Box.Size=Vector2.new(w,h) o.Box.Position=Vector2.new(x,y) o.Box.Visible=true
        else o.Box.Visible=false o.BoxOut.Visible=false end
        if ESPNames then o.Name.Text=player.Name o.Name.Position=Vector2.new(rsp.X,y-16) o.Name.Visible=true else o.Name.Visible=false end
        if ESPTracers then o.Tracer.From=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y) o.Tracer.To=Vector2.new(rsp.X,rsp.Y) o.Tracer.Visible=true else o.Tracer.Visible=false end
        if ESPHealth then
            local pct=math.clamp(hum.Health/hum.MaxHealth,0,1) local bh=h*pct
            o.HpBG.Size=Vector2.new(4,h) o.HpBG.Position=Vector2.new(x-7,y) o.HpBG.Visible=true
            o.HpBar.Size=Vector2.new(4,bh) o.HpBar.Position=Vector2.new(x-7,y+h-bh)
            o.HpBar.Color=Color3.fromRGB(math.floor(255*(1-pct)),math.floor(255*pct),0) o.HpBar.Visible=true
        else o.HpBG.Visible=false o.HpBar.Visible=false end
        if ESPDistance then o.Dist.Text=math.floor(dist).."m" o.Dist.Position=Vector2.new(rsp.X,y+h+2) o.Dist.Visible=true else o.Dist.Visible=false end
    end
end)

ESPTab:CreateSection("Player ESP")
ESPTab:CreateToggle({ Name="Enable ESP", CurrentValue=false, Flag="ESPMain",
    Callback=function(v) ESPEnabled=v if not v then for _,o in pairs(ESPObjects) do HideESP(o) end end Notify("ESP",v and"On"or"Off",2) end })
ESPTab:CreateToggle({ Name="Boxes",       CurrentValue=true, Flag="ESPBoxes",   Callback=function(v) ESPBoxes=v    end })
ESPTab:CreateToggle({ Name="Names",       CurrentValue=true, Flag="ESPNames",   Callback=function(v) ESPNames=v    end })
ESPTab:CreateToggle({ Name="Tracers",     CurrentValue=true, Flag="ESPTracers", Callback=function(v) ESPTracers=v  end })
ESPTab:CreateToggle({ Name="Health Bars", CurrentValue=true, Flag="ESPHealth",  Callback=function(v) ESPHealth=v   end })
ESPTab:CreateToggle({ Name="Distance",    CurrentValue=true, Flag="ESPDist",    Callback=function(v) ESPDistance=v end })
ESPTab:CreateSection("Range")
ESPTab:CreateSlider({ Name="Max Distance", Range={100,5000}, Increment=100, Suffix="m", CurrentValue=1500, Flag="ESPMaxDist",
    Callback=function(v) ESPMaxDist=v end })

-- ============================================================
--   TAB: AIMBOT
-- ============================================================
local AimTab = Window:CreateTab("Aimbot", "target")

local AimbotEnabled=false local AimbotSilent=false local AimbotFOV=120
local AimbotSmooth=5 local AimbotPart="Head" local AimbotShowFOV=false

local FOVCircle=Drawing.new("Circle") FOVCircle.Visible=false FOVCircle.Color=Color3.fromRGB(255,255,255) FOVCircle.Thickness=1 FOVCircle.Filled=false

local function GetAimTarget()
    local best,bestD=nil,AimbotFOV
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        local char=p.Character if not char then continue end
        local part=char:FindFirstChild(AimbotPart) local hum=char:FindFirstChildOfClass("Humanoid")
        if not part or not hum or hum.Health<=0 then continue end
        local sp,on=Camera:WorldToViewportPoint(part.Position)
        if on then local d=(Vector2.new(sp.X,sp.Y)-center).Magnitude if d<bestD then bestD=d best=part end end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    FOVCircle.Radius=AimbotFOV FOVCircle.Visible=AimbotShowFOV
    if not AimbotEnabled then return end
    local t=GetAimTarget() if not t then return end
    local sp,on=Camera:WorldToViewportPoint(t.Position) if not on then return end
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local delta=Vector2.new(sp.X,sp.Y)-center
    pcall(function()
        if AimbotSilent then mousemoverel(delta.X/AimbotSmooth,delta.Y/AimbotSmooth)
        else local sm=center:Lerp(Vector2.new(sp.X,sp.Y),1/AimbotSmooth) mousemoveabs(math.floor(sm.X),math.floor(sm.Y)) end
    end)
end)

AimTab:CreateSection("Aim Settings")
AimTab:CreateToggle({ Name="Enable Aimbot", CurrentValue=false, Flag="AimbotOn",     Callback=function(v) AimbotEnabled=v Notify("Aimbot",v and"On"or"Off",2) end })
AimTab:CreateToggle({ Name="Silent Aim",    CurrentValue=false, Flag="SilentAim",    Callback=function(v) AimbotSilent=v  Notify("Silent Aim",v and"On"or"Off",2) end })
AimTab:CreateToggle({ Name="Show FOV",      CurrentValue=false, Flag="ShowFOV",      Callback=function(v) AimbotShowFOV=v if not v then FOVCircle.Visible=false end end })
AimTab:CreateSection("FOV & Smoothness")
AimTab:CreateSlider({ Name="FOV Radius", Range={20,600}, Increment=10, Suffix="px", CurrentValue=120, Flag="AimbotFOV",    Callback=function(v) AimbotFOV=v end })
AimTab:CreateSlider({ Name="Smoothness", Range={1,30},   Increment=1,              CurrentValue=5,   Flag="AimbotSmooth", Callback=function(v) AimbotSmooth=v end })
AimTab:CreateSection("Target Part")
AimTab:CreateDropdown({ Name="Aim Part", Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso"}, CurrentOption={"Head"},
    Flag="AimbotPart", MultipleOptions=false, Callback=function(opt) AimbotPart=opt[1] or "Head" end })

-- ============================================================
--   TAB: FPS GAMES
-- ============================================================
local FPSTab = Window:CreateTab("FPS Games", "crosshair")
FPSTab:CreateSection("Best for: Rivals, Arsenal, Phantom Forces, Bad Business")

FPSTab:CreateToggle({ Name="Bunny Hop", CurrentValue=false, Flag="BunnyHop",
    Callback=function(v)
        _G.BHop = v
        if v and not _G.BHopConn then
            _G.BHopConn = RunService.Stepped:Connect(function()
                if not _G.BHop then return end
                local h = GetHum()
                if h and h:GetState() == Enum.HumanoidStateType.Freefall then
                    h:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        end
        Notify("Bunny Hop", v and "On -- hold Space to bhop!" or "Off", 2)
    end })

FPSTab:CreateToggle({ Name="Anti-Aim (Spin)", CurrentValue=false, Flag="AntiAim",
    Callback=function(v)
        _G.AntiAim = v
        if v and not _G.AntiAimConn then
            _G.AntiAimConn = RunService.RenderStepped:Connect(function()
                if not _G.AntiAim then return end
                local root = GetRoot()
                if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(15), 0) end
            end)
        end
        Notify("Anti-Aim", v and "On -- spinning!" or "Off", 2)
    end })

FPSTab:CreateToggle({ Name="Rapid Fire", CurrentValue=false, Flag="RapidFire",
    Callback=function(v)
        _G.RapidFire = v
        if v and not _G.RapidFireConn then
            _G.RapidFireConn = RunService.Heartbeat:Connect(function()
                if not _G.RapidFire then return end
                local char = GetChar() if not char then return end
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, val in ipairs(tool:GetDescendants()) do
                            if val:IsA("NumberValue") or val:IsA("IntValue") then
                                local n = val.Name:lower()
                                if n:find("cooldown") or n:find("firerate") or n:find("delay") then
                                    val.Value = 0
                                end
                            end
                        end
                    end
                end
            end)
        end
        Notify("Rapid Fire", v and "On" or "Off", 2)
    end })

FPSTab:CreateToggle({ Name="No Recoil", CurrentValue=false, Flag="NoRecoil",
    Callback=function(v)
        _G.NoRecoil = v
        if v and not _G.NoRecoilConn then
            _G.NoRecoilConn = RunService.RenderStepped:Connect(function()
                if not _G.NoRecoil then return end
                local cam = workspace.CurrentCamera
                local x,y,z = cam.CFrame:ToEulerAnglesYXZ()
                cam.CFrame = CFrame.new(cam.CFrame.Position) * CFrame.Angles(math.clamp(x,-0.05,0.05),y,z)
            end)
        end
        Notify("No Recoil", v and "On" or "Off", 2)
    end })

-- ============================================================
--   TAB: RPG / ANIME
-- ============================================================
local RPGTab = Window:CreateTab("RPG / Anime", "sword")
RPGTab:CreateSection("Best for: Blox Fruits, Anime Adventures, Pet Sim, King Legacy")

RPGTab:CreateToggle({ Name="Auto Farm (Kill nearest NPC)", CurrentValue=false, Flag="AutoFarm",
    Callback=function(v)
        _G.AutoFarm = v
        if v and not _G.AutoFarmConn then
            _G.AutoFarmConn = RunService.Heartbeat:Connect(function()
                if not _G.AutoFarm then return end
                local root = GetRoot() if not root then return end
                local closest, closestDist = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("Humanoid") and obj.Health > 0 and obj.Parent ~= GetChar() then
                        local r = obj.Parent:FindFirstChild("HumanoidRootPart") or obj.Parent:FindFirstChild("Root")
                        if r then
                            local d = (r.Position - root.Position).Magnitude
                            if d < closestDist then closestDist = d closest = obj end
                        end
                    end
                end
                if closest and closestDist < 10 then
                    closest.Health = 0
                elseif closest then
                    local r = closest.Parent:FindFirstChild("HumanoidRootPart") or closest.Parent:FindFirstChild("Root")
                    if r then root.CFrame = CFrame.new(r.Position + Vector3.new(0,3,0)) end
                end
            end)
        end
        Notify("Auto Farm", v and "On -- farming NPCs!" or "Off", 2)
    end })

-- (other RPG features like Auto Collect, Inf Stamina, etc. can be added the same way — let me know if you want them expanded)

-- ============================================================
--   TAB: SETTINGS (quick disable buttons)
-- ============================================================
local SettingsTab = Window:CreateTab("Settings", "settings")

SettingsTab:CreateSection("Notifications")
SettingsTab:CreateToggle({ Name="Enable Notifications", CurrentValue=true, Flag="NotifsOn",
    Callback=function(v) NotifEnabled=v Rayfield:Notify({ Title="Notifications", Content=v and"ON"or"OFF", Duration=2 }) end })

SettingsTab:CreateSection("Quick Reset")
SettingsTab:CreateButton({ Name="Disable All ESP", Callback=function()
    ESPEnabled=false for _,o in pairs(ESPObjects) do HideESP(o) end Notify("ESP","Off",2)
end })
SettingsTab:CreateButton({ Name="Disable Aimbot", Callback=function()
    AimbotEnabled=false AimbotSilent=false FOVCircle.Visible=false Notify("Aimbot","Off",2)
end })
SettingsTab:CreateButton({ Name="Reset All Movement", Callback=function()
    StopFly() FlyEnabled=false
    workspace.Gravity=196.2
    local h=GetHum() if h then h.WalkSpeed=16 h.JumpPower=50 h.PlatformStand=false end
    Notify("Reset","All movement reset",2)
end })
SettingsTab:CreateButton({ Name="Disable All Troll", Callback=function()
    _G.SpinBot=false _G.FakeLag=false _G.BHop=false _G.AntiAim=false
    Notify("Troll","All troll features off",2)
end })

SettingsTab:CreateSection("Credits")
SettingsTab:CreateParagraph({ Title="HyperCheat | Universal v1.0",
    Content="God Mode ✓ | ESP ✓ | Aimbot ✓ | Kill Aura ✓ | Fly ✓ | NoClip ✓\n\n"..WEBSITE_LINK.."\n"..DISCORD_LINK })

-- ============================================================
--   LOADED
-- ============================================================
task.wait(0.8)
Rayfield:Notify({ Title="HyperCheat | Universal v1.0", Content="All modules loaded!\nF2 to toggle | Works in ANY game!", Duration=6 })
print("HyperCheat | Universal v1.0 - FULL CLEANED VERSION LOADED!")
