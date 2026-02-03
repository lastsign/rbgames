--!strict
-- WeaponShopScreen.luau
-- Weapon shop UI for purchasing and equipping weapons

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIManager = require(script.Parent.Parent.UIManager)
local ClientNetworker = require(script.Parent.Parent.Parent.Network.ClientNetworker)
local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)

local WeaponShopScreen = {}

local shopFrame: Frame = nil
local weaponButtons: { [string]: Frame } = {}
local cachedPlayerData: any = nil

-- Create shop UI
function WeaponShopScreen.Create()
	local screen = UIManager.GetScreen("Menus")
	if not screen then
		return
	end

	-- Main shop frame
	shopFrame = Instance.new("Frame")
	shopFrame.Name = "WeaponShopFrame"
	shopFrame.Size = UDim2.new(0, 550, 0, 450)
	shopFrame.Position = UDim2.new(0.5, -275, 0.5, -225)
	shopFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	shopFrame.BackgroundTransparency = 0.05
	shopFrame.BorderSizePixel = 3
	shopFrame.BorderColor3 = Color3.fromRGB(150, 100, 200)
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
	title.Text = "WEAPON SHOP"
	title.TextColor3 = Color3.fromRGB(200, 150, 255)
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
		WeaponShopScreen.Hide()
	end)

	-- Scrolling frame for weapons
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Name = "WeaponList"
	scrollFrame.Size = UDim2.new(1, -20, 1, -70)
	scrollFrame.Position = UDim2.new(0, 10, 0, 60)
	scrollFrame.BackgroundTransparency = 1
	scrollFrame.BorderSizePixel = 0
	scrollFrame.ScrollBarThickness = 8
	scrollFrame.ScrollBarImageColor3 = Color3.fromRGB(150, 100, 200)
	scrollFrame.Parent = shopFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = scrollFrame

	-- Create weapon buttons
	local weapons = WeaponConfig.GetWeaponsSorted()
	for i, weaponData in weapons do
		local weaponButton = WeaponShopScreen.CreateWeaponButton(weaponData, i)
		weaponButton.Parent = scrollFrame
		weaponButtons[weaponData.ID] = weaponButton
	end

	-- Update canvas size
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
	end)
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)

	print("[WeaponShopScreen] Created")
end

-- Create individual weapon button
function WeaponShopScreen.CreateWeaponButton(weaponData: WeaponConfig.WeaponData, layoutOrder: number): Frame
	local rarityColor = WeaponConfig.GetRarityColor(weaponData.Rarity)

	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = weaponData.ID
	buttonFrame.Size = UDim2.new(1, -10, 0, 100)
	buttonFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	buttonFrame.BorderSizePixel = 2
	buttonFrame.BorderColor3 = rarityColor
	buttonFrame.LayoutOrder = layoutOrder

	local frameCorner = Instance.new("UICorner")
	frameCorner.CornerRadius = UDim.new(0, 8)
	frameCorner.Parent = buttonFrame

	-- Weapon name (colored by rarity)
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "WeaponName"
	nameLabel.Size = UDim2.new(0.55, 0, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = weaponData.DisplayName
	nameLabel.TextColor3 = rarityColor
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = buttonFrame

	-- Rarity badge
	local rarityLabel = Instance.new("TextLabel")
	rarityLabel.Name = "Rarity"
	rarityLabel.Size = UDim2.new(0, 80, 0, 20)
	rarityLabel.Position = UDim2.new(0, 10, 0, 28)
	rarityLabel.BackgroundColor3 = rarityColor
	rarityLabel.BackgroundTransparency = 0.7
	rarityLabel.Text = weaponData.Rarity
	rarityLabel.TextColor3 = rarityColor
	rarityLabel.TextSize = 12
	rarityLabel.Font = Enum.Font.GothamBold
	rarityLabel.Parent = buttonFrame

	local rarityCorner = Instance.new("UICorner")
	rarityCorner.CornerRadius = UDim.new(0, 4)
	rarityCorner.Parent = rarityLabel

	-- Stats
	local statsLabel = Instance.new("TextLabel")
	statsLabel.Name = "Stats"
	statsLabel.Size = UDim2.new(0.55, 0, 0, 40)
	statsLabel.Position = UDim2.new(0, 10, 0, 52)
	statsLabel.BackgroundTransparency = 1
	statsLabel.Text = string.format(
		"DMG: %.1fx  |  SPD: %.1f/s  |  RNG: %d",
		weaponData.DamageMultiplier,
		weaponData.AttackSpeed,
		weaponData.AttackRange
	)
	statsLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	statsLabel.TextSize = 13
	statsLabel.Font = Enum.Font.Gotham
	statsLabel.TextXAlignment = Enum.TextXAlignment.Left
	statsLabel.Parent = buttonFrame

	-- Description
	if weaponData.Description then
		local descLabel = Instance.new("TextLabel")
		descLabel.Name = "Description"
		descLabel.Size = UDim2.new(0.55, 0, 0, 20)
		descLabel.Position = UDim2.new(0, 10, 0, 75)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = weaponData.Description
		descLabel.TextColor3 = Color3.fromRGB(140, 140, 140)
		descLabel.TextSize = 11
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.TextTruncate = Enum.TextTruncate.AtEnd
		descLabel.Parent = buttonFrame
	end

	-- Action button (BUY/EQUIP/EQUIPPED)
	local actionButton = Instance.new("TextButton")
	actionButton.Name = "ActionButton"
	actionButton.Size = UDim2.new(0.38, -10, 0, 70)
	actionButton.Position = UDim2.new(0.62, 0, 0, 15)
	actionButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	actionButton.Text = "BUY"
	actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	actionButton.TextSize = 18
	actionButton.Font = Enum.Font.GothamBold
	actionButton.Parent = buttonFrame

	local actionCorner = Instance.new("UICorner")
	actionCorner.CornerRadius = UDim.new(0, 8)
	actionCorner.Parent = actionButton

	-- Cost label (shown below button text when applicable)
	local costLabel = Instance.new("TextLabel")
	costLabel.Name = "CostLabel"
	costLabel.Size = UDim2.new(1, 0, 0, 20)
	costLabel.Position = UDim2.new(0, 0, 1, -25)
	costLabel.BackgroundTransparency = 1
	local currencyIcon = if weaponData.CostType == "Gems" then "GEMS" else "COINS"
	costLabel.Text = if weaponData.Cost > 0 then `{weaponData.Cost} {currencyIcon}` else "FREE"
	costLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	costLabel.TextSize = 14
	costLabel.Font = Enum.Font.GothamBold
	costLabel.Parent = actionButton

	-- Level requirement label
	if weaponData.RequiredLevel then
		local reqLabel = Instance.new("TextLabel")
		reqLabel.Name = "RequirementLabel"
		reqLabel.Size = UDim2.new(1, 0, 0, 15)
		reqLabel.Position = UDim2.new(0, 0, 0, 2)
		reqLabel.BackgroundTransparency = 1
		reqLabel.Text = `Lv.{weaponData.RequiredLevel}+`
		reqLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		reqLabel.TextSize = 12
		reqLabel.Font = Enum.Font.GothamBold
		reqLabel.Parent = actionButton
	end

	-- Button click handler
	actionButton.MouseButton1Click:Connect(function()
		WeaponShopScreen.OnActionButtonClick(weaponData.ID)
	end)

	-- Hover effects
	actionButton.MouseEnter:Connect(function()
		actionButton.BackgroundTransparency = 0.2
	end)

	actionButton.MouseLeave:Connect(function()
		actionButton.BackgroundTransparency = 0
	end)

	return buttonFrame
end

-- Handle action button click
function WeaponShopScreen.OnActionButtonClick(weaponID: string)
	if not cachedPlayerData then
		return
	end

	local weaponData = WeaponConfig.GetWeapon(weaponID)
	if not weaponData then
		return
	end

	-- Check if owned
	local ownedWeapon = nil
	for _, weapon in cachedPlayerData.Weapons.Owned do
		if weapon.WeaponType == weaponID then
			ownedWeapon = weapon
			break
		end
	end

	if ownedWeapon then
		-- Already owned - equip it
		if cachedPlayerData.Weapons.Equipped == ownedWeapon.ID then
			print("[WeaponShopScreen] Already equipped")
			return
		end

		print(`[WeaponShopScreen] Equipping {weaponID}`)
		local result = ClientNetworker.Functions.EquipWeapon:InvokeServer(ownedWeapon.ID)
		if result and result.Success then
			print(`[WeaponShopScreen] Successfully equipped {weaponID}`)
		else
			warn(`[WeaponShopScreen] Failed to equip: {result.Message or "Unknown error"}`)
		end
	else
		-- Not owned - purchase it
		print(`[WeaponShopScreen] Purchasing {weaponID}`)
		local result = ClientNetworker.Functions.PurchaseWeapon:InvokeServer(weaponID)
		if result and result.Success then
			print(`[WeaponShopScreen] Successfully purchased {weaponID}`)
		else
			warn(`[WeaponShopScreen] Failed to purchase: {result.Message or "Unknown error"}`)
		end
	end
end

-- Update shop with current player data
function WeaponShopScreen.Update(data: any)
	if not data or not shopFrame then
		return
	end

	cachedPlayerData = data

	if not data.Weapons then
		return
	end

	-- Build lookup of owned weapons
	local ownedWeapons: { [string]: any } = {}
	for _, weapon in data.Weapons.Owned do
		ownedWeapons[weapon.WeaponType] = weapon
	end

	-- Update each weapon button
	for weaponID, buttonFrame in weaponButtons do
		local weaponData = WeaponConfig.GetWeapon(weaponID)
		if not weaponData then
			continue
		end

		local actionButton = buttonFrame:FindFirstChild("ActionButton") :: TextButton
		local costLabel = actionButton:FindFirstChild("CostLabel") :: TextLabel
		if not actionButton then
			continue
		end

		local ownedWeapon = ownedWeapons[weaponID]
		local isEquipped = ownedWeapon and data.Weapons.Equipped == ownedWeapon.ID

		if isEquipped then
			-- Currently equipped
			actionButton.Text = "EQUIPPED"
			actionButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			costLabel.Visible = false
		elseif ownedWeapon then
			-- Owned but not equipped
			actionButton.Text = "EQUIP"
			actionButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
			costLabel.Visible = false
		else
			-- Not owned - show buy button
			local canAfford = false
			local meetsLevel = true

			if weaponData.CostType == "Coins" then
				canAfford = data.Currencies.Coins >= weaponData.Cost
			else
				canAfford = data.Currencies.Gems >= weaponData.Cost
			end

			if weaponData.RequiredLevel and data.Progression.Level < weaponData.RequiredLevel then
				meetsLevel = false
			end

			actionButton.Text = "BUY"
			costLabel.Visible = true

			if canAfford and meetsLevel then
				actionButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
				actionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			elseif not meetsLevel then
				actionButton.BackgroundColor3 = Color3.fromRGB(150, 100, 50)
				actionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
			else
				actionButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
				actionButton.TextColor3 = Color3.fromRGB(150, 150, 150)
			end
		end
	end
end

-- Show shop
function WeaponShopScreen.Show()
	if shopFrame then
		shopFrame.Visible = true
	end
end

-- Hide shop
function WeaponShopScreen.Hide()
	if shopFrame then
		shopFrame.Visible = false
	end
end

-- Toggle shop
function WeaponShopScreen.Toggle()
	if shopFrame then
		shopFrame.Visible = not shopFrame.Visible
	end
end

return WeaponShopScreen
