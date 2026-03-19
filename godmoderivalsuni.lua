local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- 1. SETTINGS
-- This is a clean "Red Dot" Crosshair ID
local CUSTOM_CURSOR = "rbxassetid://606573322" 
local ORIGINAL_CURSOR = "" -- Reverts to default

-- 2. UI CREATION
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "GodModeControl"
sg.ResetOnSpawn = false -- Keeps the button on screen after you die

local godBtn = Instance.new("TextButton", sg)
godBtn.Size = UDim2.new(0, 160, 0, 50)
godBtn.Position = UDim2.new(0.5, -80, 0.8, 0) -- Bottom center
godBtn.Text = "GOD MODE: OFF"
godBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
godBtn.TextColor3 = Color3.new(1, 1, 1)
godBtn.Font = Enum.Font.GothamBold
godBtn.BorderSizePixel = 0
godBtn.AutoButtonColor = true
godBtn.Active = true

-- Round the corners
local corner = Instance.new("UICorner", godBtn)
corner.CornerRadius = UDim.new(0, 8)

-- 3. GOD MODE LOGIC
local godActive = false

-- This loop runs every single frame to keep you alive
RunService.Heartbeat:Connect(function()
	if godActive and player.Character then
		local hum = player.Character:FindFirstChild("Humanoid")
		if hum then
			-- Using 999999 instead of math.huge to prevent some UI bugs
			hum.MaxHealth = 999999
			hum.Health = 999999
		end
	end
end)

-- Toggle Button
godBtn.MouseButton1Click:Connect(function()
	godActive = not godActive
	if godActive then
		godBtn.Text = "GOD MODE: ON"
		godBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
	else
		godBtn.Text = "GOD MODE: OFF"
		godBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		-- Reset health to normal when turning off
		if player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.MaxHealth = 100
			player.Character.Humanoid.Health = 100
		end
	end
end)

-- 4. CUSTOM CURSOR ON CLICK
-- When you click (LMB), the cursor changes
UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouse.Icon = CUSTOM_CURSOR
	end
end)

-- When you let go, it resets
UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		mouse.Icon = ORIGINAL_CURSOR
	end
end)

-- 5. DRAGGING LOGIC (Smooth)
local dragging, dragStart, startPos

godBtn.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = godBtn.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		godBtn.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

print("God Mode Script Loaded - No Errors!")
