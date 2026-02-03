--!strict
-- RebirthScreen.luau
-- Rebirth/Prestige UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIManager = require(script.Parent.Parent.UIManager)
local ClientNetworker = require(script.Parent.Parent.Parent.Network.ClientNetworker)
local RebirthConfig = require(ReplicatedStorage.Shared.Config.RebirthConfig)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)

local RebirthScreen = {}

local rebirthFrame: Frame = nil

-- Create rebirth UI
function RebirthScreen.Create()
	local screen = UIManager.GetScreen("Menus")
	if not screen then
		return
	end

	-- Main frame
	rebirthFrame = Instance.new("Frame")
	rebirthFrame.Name = "RebirthFrame"
	rebirthFrame.Size = UDim2.new(0, 500, 0, 400)
	rebirthFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
	rebirthFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	rebirthFrame.BackgroundTransparency = 0.1
	rebirthFrame.BorderSizePixel = 3
	rebirthFrame.BorderColor3 = Color3.fromRGB(200, 100, 255)
	rebirthFrame.Visible = false
	rebirthFrame.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = rebirthFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 60)
	title.BackgroundTransparency = 1
	title.Text = "♻️ REBIRTH ♻️"
	title.TextColor3 = Color3.fromRGB(200, 100, 255)
	title.TextSize = 32
	title.Font = Enum.Font.GothamBold
	title.Parent = rebirthFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 24
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = rebirthFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		RebirthScreen.Hide()
	end)

	-- Info container
	local infoFrame = Instance.new("Frame")
	infoFrame.Name = "InfoFrame"
	infoFrame.Size = UDim2.new(1, -40, 0, 200)
	infoFrame.Position = UDim2.new(0, 20, 0, 70)
	infoFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	infoFrame.BorderSizePixel = 0
	infoFrame.Parent = rebirthFrame

	local infoCorner = Instance.new("UICorner")
	infoCorner.CornerRadius = UDim.new(0, 8)
	infoCorner.Parent = infoFrame

	-- Current status
	local currentLabel = Instance.new("TextLabel")
	currentLabel.Name = "CurrentStatus"
	currentLabel.Size = UDim2.new(1, -20, 0, 30)
	currentLabel.Position = UDim2.new(0, 10, 0, 10)
	currentLabel.BackgroundTransparency = 1
	currentLabel.Text = "Current Rebirth Level: 0"
	currentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	currentLabel.TextSize = 20
	currentLabel.Font = Enum.Font.GothamBold
	currentLabel.TextXAlignment = Enum.TextXAlignment.Left
	currentLabel.Parent = infoFrame

	-- Requirement
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Name = "Requirement"
	reqLabel.Size = UDim2.new(1, -20, 0, 25)
	reqLabel.Position = UDim2.new(0, 10, 0, 50)
	reqLabel.BackgroundTransparency = 1
	reqLabel.Text = `Requirement: Level {RebirthConfig.RequiredLevel}`
	reqLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	reqLabel.TextSize = 18
	reqLabel.Font = Enum.Font.Gotham
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Parent = infoFrame

	-- Bonuses info
	local bonusesLabel = Instance.new("TextLabel")
	bonusesLabel.Name = "Bonuses"
	bonusesLabel.Size = UDim2.new(1, -20, 0, 80)
	bonusesLabel.Position = UDim2.new(0, 10, 0, 85)
	bonusesLabel.BackgroundTransparency = 1
	bonusesLabel.Text = [[After Rebirth You Will Gain:
+10% Damage
+15% XP Gain
+10% Coin Gain]]
	bonusesLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	bonusesLabel.TextSize = 16
	bonusesLabel.Font = Enum.Font.Gotham
	bonusesLabel.TextXAlignment = Enum.TextXAlignment.Left
	bonusesLabel.TextYAlignment = Enum.TextYAlignment.Top
	bonusesLabel.Parent = infoFrame

	-- Warning
	local warningLabel = Instance.new("TextLabel")
	warningLabel.Name = "Warning"
	warningLabel.Size = UDim2.new(1, -20, 0, 40)
	warningLabel.Position = UDim2.new(0, 10, 0, 165)
	warningLabel.BackgroundTransparency = 1
	warningLabel.Text = "⚠️ WARNING: You will lose all progress except pets!"
	warningLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	warningLabel.TextSize = 14
	warningLabel.Font = Enum.Font.GothamBold
	warningLabel.TextWrapped = true
	warningLabel.Parent = infoFrame

	-- Rebirth button
	local rebirthButton = Instance.new("TextButton")
	rebirthButton.Name = "RebirthButton"
	rebirthButton.Size = UDim2.new(0.8, 0, 0, 60)
	rebirthButton.Position = UDim2.new(0.1, 0, 1, -80)
	rebirthButton.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
	rebirthButton.Text = "PERFORM REBIRTH"
	rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	rebirthButton.TextSize = 24
	rebirthButton.Font = Enum.Font.GothamBold
	rebirthButton.Parent = rebirthFrame

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = rebirthButton

	-- Rebirth click
	rebirthButton.MouseButton1Click:Connect(function()
		RebirthScreen.PerformRebirth()
	end)

	print("[RebirthScreen] Created")
end

-- Perform rebirth
function RebirthScreen.PerformRebirth()
	print("[RebirthScreen] Attempting rebirth...")

	local result = ClientNetworker.Functions.PerformRebirth:InvokeServer()

	if result and result.Success then
		print("[RebirthScreen] Rebirth successful!")
		RebirthScreen.Hide()
	else
		warn(`[RebirthScreen] Rebirth failed: {result.Message or "Unknown error"}`)
	end
end

-- Update with player data
function RebirthScreen.Update(data: any)
	if not data or not rebirthFrame then
		return
	end

	local currentLabel = rebirthFrame:FindFirstChild("InfoFrame"):FindFirstChild("CurrentStatus") :: TextLabel
	if currentLabel then
		currentLabel.Text = `Current Rebirth Level: {data.Progression.RebirthLevel}`
	end

	local reqLabel = rebirthFrame:FindFirstChild("InfoFrame"):FindFirstChild("Requirement") :: TextLabel
	if reqLabel then
		local canRebirth = data.Progression.Level >= RebirthConfig.RequiredLevel
		reqLabel.Text = `Requirement: Level {RebirthConfig.RequiredLevel} (Current: {data.Progression.Level})`
		reqLabel.TextColor3 = if canRebirth then Color3.fromRGB(150, 255, 150) else Color3.fromRGB(255, 150, 150)
	end

	local rebirthButton = rebirthFrame:FindFirstChild("RebirthButton") :: TextButton
	if rebirthButton then
		local canRebirth = data.Progression.Level >= RebirthConfig.RequiredLevel
		if canRebirth then
			rebirthButton.BackgroundColor3 = Color3.fromRGB(200, 100, 255)
			rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
		else
			rebirthButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			rebirthButton.TextColor3 = Color3.fromRGB(150, 150, 150)
		end
	end
end

-- Show/hide
function RebirthScreen.Show()
	if rebirthFrame then
		rebirthFrame.Visible = true
	end
end

function RebirthScreen.Hide()
	if rebirthFrame then
		rebirthFrame.Visible = false
	end
end

function RebirthScreen.Toggle()
	if rebirthFrame then
		rebirthFrame.Visible = not rebirthFrame.Visible
	end
end

return RebirthScreen
