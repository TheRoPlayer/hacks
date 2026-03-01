local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- // UI SETUP //
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "FunkyTeleportMenu"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Container Frame
local mainContainer = Instance.new("Frame")
mainContainer.Size = UDim2.new(0, 320, 0, 450)
mainContainer.Position = UDim2.new(1, -340, 0.5, -225)
mainContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainContainer.BorderSizePixel = 0
mainContainer.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 15)
mainCorner.Parent = mainContainer

-- Title Header
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 50)
title.Text = "⚡ HUNTER RADAR ⚡"
title.Font = Enum.Font.LuckiestGuy
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.TextSize = 24
title.BackgroundTransparency = 1
title.Parent = mainContainer

-- THE SCROLLING FRAME
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 1, -70)
scrollFrame.Position = UDim2.new(0, 10, 0, 60)
scrollFrame.BackgroundTransparency = 1
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 0, 255)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = mainContainer

local uiList = Instance.new("UIListLayout")
uiList.Padding = UDim.new(0, 10)
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Parent = scrollFrame

-- // TELEPORT FUNCTION //
local function teleportTo(targetPlayer)
    local targetChar = targetPlayer.Character
    local myChar = LocalPlayer.Character
    
    if targetChar and targetChar:FindFirstChild("HumanoidRootPart") and myChar and myChar:FindFirstChild("HumanoidRootPart") then
        -- Move your HRP to their HRP position + 3 studs up (so you don't get stuck in the floor)
        myChar.HumanoidRootPart.CFrame = targetChar.HumanoidRootPart.CFrame * CFrame.new(0, 3, 0)
    end
end

-- // CREATE PLAYER CARD //
local function createPlayerCard(player)
    if player == LocalPlayer then return end

    local card = Instance.new("Frame")
    card.Name = player.Name
    card.Size = UDim2.new(1, -10, 0, 100) -- Made slightly taller for the button
    card.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    card.Parent = scrollFrame
    
    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 10)
    cardCorner.Parent = card

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.7, 0, 1, 0)
    statsLabel.Position = UDim2.new(0, 10, 0, 0)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Enum.Font.FredokaOne
    statsLabel.TextColor3 = Color3.new(1, 1, 1)
    statsLabel.TextSize = 13
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.Parent = card

    -- THE TELEPORT BUTTON
    local tpBtn = Instance.new("TextButton")
    tpBtn.Size = UDim2.new(0.25, 0, 0, 40)
    tpBtn.Position = UDim2.new(0.7, 0, 0.5, -20)
    tpBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    tpBtn.Text = "GO!"
    tpBtn.Font = Enum.Font.LuckiestGuy
    tpBtn.TextSize = 18
    tpBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    tpBtn.Parent = card
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = tpBtn

    tpBtn.MouseButton1Click:Connect(function()
        teleportTo(player)
    end)

    -- Update Loop
    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not player.Parent then
            card:Destroy()
            connection:Disconnect()
            return
        end

        local char = player.Character
        local hum = char and char:FindFirstChild("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        
        local hp = hum and math.floor(hum.Health) or 0
        local dist = (hrp and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) 
                     and math.floor((LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) 
                     or "???"

        statsLabel.Text = string.format(
            "👤 %s\n❤️ HP: %d\n📏 DIST: %s\n📅 AGE: %d d",
            player.DisplayName:upper(),
            hp,
            tostring(dist),
            player.AccountAge
        )
    end)
end

-- Init
for _, p in pairs(Players:GetPlayers()) do createPlayerCard(p) end
Players.PlayerAdded:Connect(createPlayerCard)
