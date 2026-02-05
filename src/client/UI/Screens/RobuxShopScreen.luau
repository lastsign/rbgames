--!strict
-- RobuxShopScreen.luau
-- UI for purchasing Gems and GamePasses with Robux

local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local UIManager = require(script.Parent.Parent.UIManager)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)

local RobuxShopScreen = {}

local shopFrame: Frame = nil
local localPlayer = Players.LocalPlayer

-- Create the shop UI
function RobuxShopScreen.Create()
	local screen = UIManager.GetScreen("Menus")
	if not screen then
		return
	end

	-- Main frame
	shopFrame = Instance.new("Frame")
	shopFrame.Name = "RobuxShopFrame"
	shopFrame.Size = UDim2.new(0, 600, 0, 500)
	shopFrame.Position = UDim2.new(0.5, -300, 0.5, -250)
	shopFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	shopFrame.BackgroundTransparency = 0.05
	shopFrame.BorderSizePixel = 3
	shopFrame.BorderColor3 = Color3.fromRGB(100, 200, 255)
	shopFrame.Visible = false
	shopFrame.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = shopFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 60)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "💎 GEM SHOP 💎"
	title.TextColor3 = Color3.fromRGB(100, 200, 255)
	title.TextSize = 32
	title.Font = Enum.Font.GothamBold
	title.Parent = shopFrame

	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(1, 0, 0, 25)
	subtitle.Position = UDim2.new(0, 0, 0, 50)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Power up your adventure!"
	subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
	subtitle.TextSize = 16
	subtitle.Font = Enum.Font.Gotham
	subtitle.Parent = shopFrame

	-- Close button
	local closeButton = Instance.new("TextButton")
	closeButton.Name = "CloseButton"
	closeButton.Size = UDim2.new(0, 40, 0, 40)
	closeButton.Position = UDim2.new(1, -50, 0, 10)
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
		RobuxShopScreen.Hide()
	end)

	-- Tab buttons
	local tabFrame = Instance.new("Frame")
	tabFrame.Name = "Tabs"
	tabFrame.Size = UDim2.new(1, -20, 0, 40)
	tabFrame.Position = UDim2.new(0, 10, 0, 80)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Parent = shopFrame

	local gemsTab = RobuxShopScreen.CreateTabButton("💎 Gems", true)
	gemsTab.Position = UDim2.new(0, 0, 0, 0)
	gemsTab.Parent = tabFrame

	local passesTab = RobuxShopScreen.CreateTabButton("🎫 GamePasses", false)
	passesTab.Position = UDim2.new(0.5, 5, 0, 0)
	passesTab.Parent = tabFrame

	-- Content frames
	local gemsContent = RobuxShopScreen.CreateGemsContent()
	gemsContent.Parent = shopFrame

	local passesContent = RobuxShopScreen.CreatePassesContent()
	passesContent.Visible = false
	passesContent.Parent = shopFrame

	-- Tab switching
	gemsTab.MouseButton1Click:Connect(function()
		gemsContent.Visible = true
		passesContent.Visible = false
		gemsTab.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		passesTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	end)

	passesTab.MouseButton1Click:Connect(function()
		gemsContent.Visible = false
		passesContent.Visible = true
		passesTab.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		gemsTab.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
	end)

	print("[RobuxShopScreen] Created")
end

-- Create tab button
function RobuxShopScreen.CreateTabButton(text: string, active: boolean): TextButton
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.5, -10, 1, 0)
	button.BackgroundColor3 = if active then Color3.fromRGB(100, 200, 255) else Color3.fromRGB(60, 60, 70)
	button.Text = text
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	return button
end

-- Create gems content
function RobuxShopScreen.CreateGemsContent(): ScrollingFrame
	local content = Instance.new("ScrollingFrame")
	content.Name = "GemsContent"
	content.Size = UDim2.new(1, -20, 1, -140)
	content.Position = UDim2.new(0, 10, 0, 130)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 8

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0, 170, 0, 140)
	layout.CellPadding = UDim2.new(0, 15, 0, 15)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	-- Create product cards
	local order = 0
	for productName, product in ProductConfig.DeveloperProducts do
		if product.GemAmount and product.GemAmount > 0 then
			order += 1
			local card = RobuxShopScreen.CreateProductCard(productName, product, order)
			card.Parent = content
		end
	end

	return content
end

-- Create passes content
function RobuxShopScreen.CreatePassesContent(): ScrollingFrame
	local content = Instance.new("ScrollingFrame")
	content.Name = "PassesContent"
	content.Size = UDim2.new(1, -20, 1, -140)
	content.Position = UDim2.new(0, 10, 0, 130)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 8

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = content

	-- Create GamePass cards
	local order = 0
	for passName, passData in ProductConfig.GamePasses do
		order += 1
		local card = RobuxShopScreen.CreateGamePassCard(passName, passData, order)
		card.Parent = content
	end

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
	end)

	return content
end

-- Create product card for gems
function RobuxShopScreen.CreateProductCard(productName: string, product: any, order: number): Frame
	local card = Instance.new("Frame")
	card.Name = productName
	card.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	card.LayoutOrder = order

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card

	-- Best value indicator
	if string.find(product.Description, "BEST VALUE") then
		local badge = Instance.new("TextLabel")
		badge.Size = UDim2.new(1, 0, 0, 20)
		badge.Position = UDim2.new(0, 0, 0, 0)
		badge.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
		badge.Text = "⭐ BEST VALUE"
		badge.TextColor3 = Color3.fromRGB(0, 0, 0)
		badge.TextSize = 12
		badge.Font = Enum.Font.GothamBold
		badge.Parent = card

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 12)
		badgeCorner.Parent = badge
	end

	-- Gem amount
	local gemLabel = Instance.new("TextLabel")
	gemLabel.Size = UDim2.new(1, 0, 0, 35)
	gemLabel.Position = UDim2.new(0, 0, 0, 25)
	gemLabel.BackgroundTransparency = 1
	gemLabel.Text = `💎 {product.GemAmount}`
	gemLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	gemLabel.TextSize = 24
	gemLabel.Font = Enum.Font.GothamBold
	gemLabel.Parent = card

	-- Bonus coins
	if product.CoinAmount and product.CoinAmount > 0 then
		local bonusLabel = Instance.new("TextLabel")
		bonusLabel.Size = UDim2.new(1, 0, 0, 20)
		bonusLabel.Position = UDim2.new(0, 0, 0, 55)
		bonusLabel.BackgroundTransparency = 1
		bonusLabel.Text = `+💰{product.CoinAmount} bonus`
		bonusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		bonusLabel.TextSize = 14
		bonusLabel.Font = Enum.Font.Gotham
		bonusLabel.Parent = card
	end

	-- Buy button
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.9, 0, 0, 35)
	buyButton.Position = UDim2.new(0.05, 0, 1, -45)
	buyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	buyButton.Text = product.DisplayPrice
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextSize = 18
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = card

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyButton

	buyButton.MouseButton1Click:Connect(function()
		if product.ProductId and product.ProductId ~= 0 then
			MarketplaceService:PromptProductPurchase(localPlayer, product.ProductId)
		else
			warn(`[RobuxShop] Product {productName} has no valid ID`)
		end
	end)

	return card
end

-- Create GamePass card
function RobuxShopScreen.CreateGamePassCard(passName: string, passData: any, order: number): Frame
	local card = Instance.new("Frame")
	card.Name = passName
	card.Size = UDim2.new(1, 0, 0, 120)
	card.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	card.LayoutOrder = order

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, 0, 0, 30)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = passData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
	nameLabel.TextSize = 20
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	-- Perks
	local perksText = table.concat(passData.Perks, "\n• ")
	local perksLabel = Instance.new("TextLabel")
	perksLabel.Size = UDim2.new(0.6, -10, 0, 80)
	perksLabel.Position = UDim2.new(0, 10, 0, 35)
	perksLabel.BackgroundTransparency = 1
	perksLabel.Text = "• " .. perksText
	perksLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	perksLabel.TextSize = 12
	perksLabel.Font = Enum.Font.Gotham
	perksLabel.TextXAlignment = Enum.TextXAlignment.Left
	perksLabel.TextYAlignment = Enum.TextYAlignment.Top
	perksLabel.TextWrapped = true
	perksLabel.Parent = card

	-- Buy button
	local buyButton = Instance.new("TextButton")
	buyButton.Size = UDim2.new(0.35, -10, 0, 50)
	buyButton.Position = UDim2.new(0.65, 0, 0.5, -25)
	buyButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	buyButton.Text = "BUY"
	buyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	buyButton.TextSize = 20
	buyButton.Font = Enum.Font.GothamBold
	buyButton.Parent = card

	local buyCorner = Instance.new("UICorner")
	buyCorner.CornerRadius = UDim.new(0, 8)
	buyCorner.Parent = buyButton

	-- Check if owned
	task.spawn(function()
		if passData.GamePassId and passData.GamePassId ~= 0 then
			local success, owns = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(localPlayer.UserId, passData.GamePassId)
			end)
			if success and owns then
				buyButton.Text = "✓ OWNED"
				buyButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			end
		end
	end)

	buyButton.MouseButton1Click:Connect(function()
		if passData.GamePassId and passData.GamePassId ~= 0 then
			MarketplaceService:PromptGamePassPurchase(localPlayer, passData.GamePassId)
		else
			warn(`[RobuxShop] GamePass {passName} has no valid ID`)
		end
	end)

	return card
end

-- Show shop
function RobuxShopScreen.Show()
	if shopFrame then
		shopFrame.Visible = true
	end
end

-- Hide shop
function RobuxShopScreen.Hide()
	if shopFrame then
		shopFrame.Visible = false
	end
end

-- Toggle shop
function RobuxShopScreen.Toggle()
	if shopFrame then
		shopFrame.Visible = not shopFrame.Visible
	end
end

return RobuxShopScreen
