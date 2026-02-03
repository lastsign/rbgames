--!strict
-- ShopScreen.luau
-- Shop UI for purchasing upgrades

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIManager = require(script.Parent.Parent.UIManager)
local ClientNetworker = require(script.Parent.Parent.Parent.Network.ClientNetworker)
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)

local ShopScreen = {}

local shopFrame: Frame = nil
local upgradeButtons: { [string]: Frame } = {}

-- Create shop UI
function ShopScreen.Create()
	local screen = UIManager.GetScreen("Menus")
	if not screen then
		return
	end

	-- Main shop frame
	shopFrame = Instance.new("Frame")
	shopFrame.Name = "ShopFrame"
	shopFrame.Size = UDim2.new(0, 500, 0, 400)
	shopFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
	shopFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	shopFrame.BackgroundTransparency = 0.1
	shopFrame.BorderSizePixel = 3
	shopFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
	shopFrame.Visible = false
	shopFrame.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = shopFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "⚔️ UPGRADE SHOP ⚔️"
	title.TextColor3 = Color3.fromRGB(255, 200, 0)
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.Parent = shopFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 5)
	closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	closeButton.Text = "X"
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.TextSize = 24
	closeButton.Font = Enum.Font.GothamBold
	closeButton.Parent = shopFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ShopScreen.Hide()
	end)

	-- Scrolling frame for upgrades
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "UpgradeList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -70)
	scrollFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.Parent = shopFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	-- Create upgrade buttons
	local layoutOrder = 0
	for upgradeName, upgradeData in UpgradeConfig do
		layoutOrder += 1
		local upgradeButton = ShopScreen.CreateUpgradeButton(upgradeName, upgradeData, layoutOrder)
		upgradeButton.Parent = scrollFrame
		upgradeButtons[upgradeName] = upgradeButton
	end

	-- Update canvas size
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

	print("[ShopScreen] Created")
end

-- Create individual upgrade button
function ShopScreen.CreateUpgradeButton(upgradeName: string, upgradeData: any, layoutOrder: number): Frame
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = upgradeName
	buttonFrame.Size = UDim2.new(1, -10, 0, 80)
	buttonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	buttonFrame.BorderSizePixel = 0
	buttonFrame.LayoutOrder = layoutOrder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = buttonFrame

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "UpgradeName"
	nameLabel.Size = UDim2.new(0.6, 0, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = upgradeData.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = buttonFrame

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Name = "Description"
	descLabel.Size = UDim2.new(0.6, 0, 0, 20)
	descLabel.Position = UDim2.new(0, 10, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = upgradeData.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextSize = 14
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = buttonFrame

	-- Level info
	local levelLabel = Instance.new("TextLabel")
	levelLabel.Name = "LevelInfo"
	levelLabel.Size = UDim2.new(0.6, 0, 0, 20)
	levelLabel.Position = UDim2.new(0, 10, 0, 55)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = "Level: 0"
	levelLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	levelLabel.TextSize = 14
	levelLabel.Font = Enum.Font.Gotham
	levelLabel.TextXAlignment = Enum.TextXAlignment.Left
	levelLabel.Parent = buttonFrame

	-- Purchase button
	local buyButton = Instance.new("TextButton")
	buyButton.Name = "BuyButton"
	buyButton.Size = UDim2.new(0.35, -10, 0, 60)
	buyButton.Position = UDim2.new(0.65, 0, 0, 10)
	buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	buyButton.Text = "BUY\n💰 100"
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextSize = 16
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = buttonFrame

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyButton

	-- Buy button click
	buyButton.MouseButton1Click:Connect(function()
		ShopScreen.PurchaseUpgrade(upgradeName)
	end)

	return buttonFrame
end

-- Purchase upgrade
function ShopScreen.PurchaseUpgrade(upgradeName: string)
	print(`[ShopScreen] Attempting to purchase {upgradeName}`)

	local result = ClientNetworker.Functions.PurchaseUpgrade:InvokeServer(upgradeName)

	if result and result.Success then
		print(`[ShopScreen] Successfully purchased {upgradeName}`)
		-- UI will update automatically via data replication
	else
		warn(`[ShopScreen] Failed to purchase {upgradeName}: {result.Message or "Unknown error"}`)
		-- TODO: Show error notification
	end
end

-- Update shop with current player data
function ShopScreen.Update(data: any)
	if not data or not shopFrame or not data.Upgrades or not data.Currencies then
		return
	end

	for upgradeName, buttonFrame in upgradeButtons do
		local upgradeData = UpgradeConfig[upgradeName]
		if not upgradeData then
			continue
		end

		local currentLevel = data.Upgrades[upgradeName] or 0
		local cost = FormulaCalculator.CalculateUpgradeCost(upgradeData.BaseCost, currentLevel)
		local canAfford = data.Currencies.Coins >= cost

		-- Update level label
		local levelLabel = buttonFrame:FindFirstChild("LevelInfo") :: TextLabel
		if levelLabel then
			levelLabel.Text = `Level: {currentLevel}`
		end

		-- Update buy button
		local buyButton = buttonFrame:FindFirstChild("BuyButton") :: TextButton
		if buyButton then
			buyButton.Text = `BUY\n💰 {cost}`

			if canAfford then
				buyButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
				buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			else
				buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				buyButton.TextColor3 = Color3.fromRGB(150, 150, 150)
			end
		end
	end
end

-- Show shop
function ShopScreen.Show()
	if shopFrame then
		shopFrame.Visible = true
	end
end

-- Hide shop
function ShopScreen.Hide()
	if shopFrame then
		shopFrame.Visible = false
	end
end

-- Toggle shop
function ShopScreen.Toggle()
	if shopFrame then
		shopFrame.Visible = not shopFrame.Visible
	end
end

return ShopScreen
