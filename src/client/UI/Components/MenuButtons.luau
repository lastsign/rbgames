--!strict
-- MenuButtons.luau
-- Buttons to open different menus

local UIManager = require(script.Parent.Parent.UIManager)

local MenuButtons = {}

local buttonsFrame: Frame = nil

-- Create menu buttons
function MenuButtons.Create()
	local screen = UIManager.GetScreen("HUD")
	if not screen then
		return
	end

	-- Buttons container (right side)
	buttonsFrame = Instance.new("Frame")
	buttonsFrame.Name = "MenuButtons"
	buttonsFrame.Size = UDim2.new(0, 120, 0, 300)
	buttonsFrame.Position = UDim2.new(1, -130, 0.5, -150)
	buttonsFrame.BackgroundTransparency = 1
	buttonsFrame.Parent = screen

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = buttonsFrame

	-- Create buttons
	local buttons = {
		{ Name = "Shop", Icon = "🛒", Color = Color3.fromRGB(255, 200, 0), Order = 1 },
		{ Name = "Weapons", Icon = "⚔️", Color = Color3.fromRGB(150, 100, 200), Order = 2 },
		{ Name = "Zones", Icon = "🗺️", Color = Color3.fromRGB(100, 150, 255), Order = 3 },
		{ Name = "Pets", Icon = "🐾", Color = Color3.fromRGB(255, 150, 200), Order = 4 },
		{ Name = "Rebirth", Icon = "♻️", Color = Color3.fromRGB(200, 100, 255), Order = 5 },
		{ Name = "Daily", Icon = "🎁", Color = Color3.fromRGB(150, 255, 150), Order = 6 },
	}

	for _, buttonData in buttons do
		MenuButtons.CreateButton(buttonData.Name, buttonData.Icon, buttonData.Color, buttonData.Order)
	end

	print("[MenuButtons] Created")
end

-- Create individual button
function MenuButtons.CreateButton(name: string, icon: string, color: Color3, order: number)
	local button = Instance.new("TextButton")
	button.Name = `{name}Button`
	button.Size = UDim2.new(1, 0, 0, 60)
	button.BackgroundColor3 = color
	button.BackgroundTransparency = 0.2
	button.BorderSizePixel = 2
	button.BorderColor3 = Color3.fromRGB(255, 255, 255)
	button.Text = `{icon}\n{name}`
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.TextSize = 18
	button.Font = Enum.Font.GothamBold
	button.LayoutOrder = order
	button.Parent = buttonsFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = button

	-- Click handler
	button.MouseButton1Click:Connect(function()
		MenuButtons.OnButtonClick(name)
	end)

	-- Hover effect
	button.MouseEnter:Connect(function()
		button.BackgroundTransparency = 0
	end)

	button.MouseLeave:Connect(function()
		button.BackgroundTransparency = 0.2
	end)
end

-- Handle button clicks
function MenuButtons.OnButtonClick(menuName: string)
	print(`[MenuButtons] Clicked {menuName}`)

	-- Import screens dynamically
	local ShopScreen = require(script.Parent.Parent.Screens.ShopScreen)
	local ZoneScreen = require(script.Parent.Parent.Screens.ZoneScreen)
	local RebirthScreen = require(script.Parent.Parent.Screens.RebirthScreen)
	local WeaponShopScreen = require(script.Parent.Parent.Screens.WeaponShopScreen)

	if menuName == "Shop" then
		ShopScreen.Toggle()
	elseif menuName == "Weapons" then
		WeaponShopScreen.Toggle()
	elseif menuName == "Zones" then
		ZoneScreen.Toggle()
	elseif menuName == "Pets" then
		-- TODO: Implement PetScreen
		print("Pets menu not yet implemented")
	elseif menuName == "Rebirth" then
		RebirthScreen.Toggle()
	elseif menuName == "Daily" then
		-- TODO: Implement DailyScreen
		print("Daily rewards menu not yet implemented")
	end
end

return MenuButtons
