--!strict
-- ZoneScreen.luau
-- Zone selection UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UIManager = require(script.Parent.Parent.UIManager)
local ClientNetworker = require(script.Parent.Parent.Parent.Network.ClientNetworker)
local ZoneConfig = require(ReplicatedStorage.Shared.Config.ZoneConfig)

local ZoneScreen = {}

local zoneFrame: Frame = nil
local zoneButtons: { [string]: Frame } = {}

-- Create zone UI
function ZoneScreen.Create()
	local screen = UIManager.GetScreen("Menus")
	if not screen then
		return
	end

	-- Main zone frame
	zoneFrame = Instance.new("Frame")
	zoneFrame.Name = "ZoneFrame"
	zoneFrame.Size = UDim2.new(0, 600, 0, 450)
	zoneFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
	zoneFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	zoneFrame.BackgroundTransparency = 0.1
	zoneFrame.BorderSizePixel = 3
	zoneFrame.BorderColor3 = Color3.fromRGB(100, 150, 255)
	zoneFrame.Visible = false
	zoneFrame.Parent = screen

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = zoneFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "🗺️ ZONE SELECTION 🗺️"
	title.TextColor3 = Color3.fromRGB(100, 150, 255)
	title.TextSize = 28
	title.Font = Enum.Font.GothamBold
	title.Parent = zoneFrame

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
	closeButton.Parent = zoneFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		ZoneScreen.Hide()
	end)

	-- Grid layout for zones
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(1, -20, 1, -70)
	gridContainer.Position = UDim2.new(0, 10, 0, 60)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = zoneFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.48, 0, 0, 120)
	gridLayout.CellPadding = UDim2.new(0.02, 0, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = gridContainer

	-- Create zone buttons
	local layoutOrder = 0
	for zoneName, zoneData in ZoneConfig do
		layoutOrder += 1
		local zoneButton = ZoneScreen.CreateZoneButton(zoneName, zoneData, layoutOrder)
		zoneButton.Parent = gridContainer
		zoneButtons[zoneName] = zoneButton
	end

	print("[ZoneScreen] Created")
end

-- Create individual zone button
function ZoneScreen.CreateZoneButton(zoneName: string, zoneData: any, layoutOrder: number): Frame
	local buttonFrame = Instance.new("Frame")
	buttonFrame.Name = zoneName
	buttonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	buttonFrame.BorderSizePixel = 0
	buttonFrame.LayoutOrder = layoutOrder

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = buttonFrame

	-- Zone name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "ZoneName"
	nameLabel.Size = UDim2.new(1, -10, 0, 30)
	nameLabel.Position = UDim2.new(0, 5, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = zoneData.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextSize = 18
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Parent = buttonFrame

	-- Requirements
	local reqLabel = Instance.new("TextLabel")
	reqLabel.Name = "Requirements"
	reqLabel.Size = UDim2.new(1, -10, 0, 20)
	reqLabel.Position = UDim2.new(0, 5, 0, 35)
	reqLabel.BackgroundTransparency = 1
	reqLabel.TextSize = 14
	reqLabel.Font = Enum.Font.Gotham
	reqLabel.TextXAlignment = Enum.TextXAlignment.Left
	reqLabel.Parent = buttonFrame

	local reqs = {}
	if zoneData.UnlockLevel > 1 then
		table.insert(reqs, `Level {zoneData.UnlockLevel}`)
	end
	if zoneData.UnlockRebirthLevel > 0 then
		table.insert(reqs, `Rebirth {zoneData.UnlockRebirthLevel}`)
	end
	reqLabel.Text = if #reqs > 0 then `Requires: {table.concat(reqs, ", ")}` else "No requirements"

	-- Multipliers
	local multLabel = Instance.new("TextLabel")
	multLabel.Name = "Multipliers"
	multLabel.Size = UDim2.new(1, -10, 0, 20)
	multLabel.Position = UDim2.new(0, 5, 0, 55)
	multLabel.BackgroundTransparency = 1
	multLabel.Text = `XP: {zoneData.XPMultiplier}x | Coins: {zoneData.CoinMultiplier}x`
	multLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
	multLabel.TextSize = 14
	multLabel.Font = Enum.Font.Gotham
	multLabel.TextXAlignment = Enum.TextXAlignment.Left
	multLabel.Parent = buttonFrame

	-- Teleport button
	local teleportButton = Instance.new("TextButton")
	teleportButton.Name = "TeleportButton"
	teleportButton.Size = UDim2.new(0.8, 0, 0, 30)
	teleportButton.Position = UDim2.new(0.1, 0, 0, 80)
	teleportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
	teleportButton.Text = "TELEPORT"
	teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	teleportButton.TextSize = 16
	teleportButton.Font = Enum.Font.GothamBold
	teleportButton.Parent = buttonFrame

	local teleportCorner = Instance.new("UICorner")
	teleportCorner.CornerRadius = UDim.new(0, 8)
	teleportCorner.Parent = teleportButton

	-- Teleport click
	teleportButton.MouseButton1Click:Connect(function()
		ZoneScreen.TeleportToZone(zoneName)
	end)

	return buttonFrame
end

-- Teleport to zone
function ZoneScreen.TeleportToZone(zoneName: string)
	print(`[ZoneScreen] Teleporting to {zoneName}`)

	local result = ClientNetworker.Functions.TeleportToZone:InvokeServer(zoneName)

	if result and result.Success then
		print(`[ZoneScreen] Successfully teleported to {zoneName}`)
		ZoneScreen.Hide()
	else
		warn(`[ZoneScreen] Failed to teleport: {result.Message or "Unknown error"}`)
	end
end

-- Update zone UI with player data
function ZoneScreen.Update(data: any)
	if not data or not zoneFrame then
		return
	end

	for zoneName, buttonFrame in zoneButtons do
		local zoneData = ZoneConfig[zoneName]
		if not zoneData then
			continue
		end

		local isUnlocked = table.find(data.Zones.UnlockedZones, zoneName) ~= nil
		local isCurrent = data.Zones.CurrentZone == zoneName
		local meetsLevel = data.Progression.Level >= zoneData.UnlockLevel
		local meetsRebirth = data.Progression.RebirthLevel >= zoneData.UnlockRebirthLevel

		-- Update requirements label color
		local reqLabel = buttonFrame:FindFirstChild("Requirements") :: TextLabel
		if reqLabel then
			if isUnlocked then
				reqLabel.TextColor3 = Color3.fromRGB(150, 255, 150)
			else
				reqLabel.TextColor3 = Color3.fromRGB(255, 150, 150)
			end
		end

		-- Update teleport button
		local teleportButton = buttonFrame:FindFirstChild("TeleportButton") :: TextButton
		if teleportButton then
			if isCurrent then
				teleportButton.Text = "CURRENT ZONE"
				teleportButton.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
			elseif isUnlocked then
				teleportButton.Text = "TELEPORT"
				teleportButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
			else
				teleportButton.Text = "🔒 LOCKED"
				teleportButton.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
			end
		end

		-- Update frame color
		if isCurrent then
			buttonFrame.BackgroundColor3 = Color3.fromRGB(50, 100, 50)
		elseif isUnlocked then
			buttonFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
		else
			buttonFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
		end
	end
end

-- Show zone screen
function ZoneScreen.Show()
	if zoneFrame then
		zoneFrame.Visible = true
	end
end

-- Hide zone screen
function ZoneScreen.Hide()
	if zoneFrame then
		zoneFrame.Visible = false
	end
end

-- Toggle zone screen
function ZoneScreen.Toggle()
	if zoneFrame then
		zoneFrame.Visible = not zoneFrame.Visible
	end
end

return ZoneScreen
