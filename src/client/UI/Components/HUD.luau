--!strict
-- HUD.luau
-- Main HUD displaying player stats, level, currencies

local UIManager = require(script.Parent.Parent.UIManager)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)

local HUD = {}

local hudFrame: Frame = nil
local labels: { [string]: TextLabel } = {}

-- Create HUD UI
function HUD.Create()
	local screen = UIManager.GetScreen("HUD")
	if not screen then
		return
	end

	-- Main HUD frame (top-left corner)
	hudFrame = Instance.new("Frame")
	hudFrame.Name = "HUDFrame"
	hudFrame.Size = UDim2.new(0, 300, 0, 200)
	hudFrame.Position = UDim2.new(0, 10, 0, 10)
	hudFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	hudFrame.BackgroundTransparency = 0.3
	hudFrame.BorderSizePixel = 2
	hudFrame.BorderColor3 = Color3.fromRGB(255, 200, 0)
	hudFrame.Parent = screen

	-- Add rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = hudFrame

	-- Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.Parent = hudFrame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, 0, 0, 30)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "RPG GRIND GAME"
	title.TextColor3 = Color3.fromRGB(255, 200, 0)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Center
	title.Parent = hudFrame

	-- Create stat labels
	local yOffset = 35
	local labelHeight = 20
	local spacing = 5

	local stats = {
		{ key = "Level", text = "Level: 1" },
		{ key = "XP", text = "XP: 0 / 100" },
		{ key = "Rebirth", text = "Rebirth: 0" },
		{ key = "Coins", text = "Coins: 0" },
		{ key = "Gems", text = "Gems: 0" },
		{ key = "Strength", text = "Strength: 10" },
		{ key = "Zone", text = "Zone: Starter Plains" },
	}

	for i, stat in stats do
		local label = Instance.new("TextLabel")
		label.Name = stat.key
		label.Size = UDim2.new(1, -20, 0, labelHeight)
		label.Position = UDim2.new(0, 0, 0, yOffset)
		label.BackgroundTransparency = 1
		label.Text = stat.text
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 16
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = hudFrame

		labels[stat.key] = label
		yOffset += labelHeight + spacing
	end

	print("[HUD] Created")
end

-- Update HUD with player data
function HUD.Update(data: any)
	if not data or not labels then
		return
	end

	-- Update level
	if labels.Level then
		labels.Level.Text = `Level: {data.Progression.Level}`
	end

	-- Update XP with progress
	if labels.XP then
		local currentXP = data.Progression.Experience
		local requiredXP = FormulaCalculator.GetExperienceForLevel(data.Progression.Level)
		labels.XP.Text = `XP: {currentXP} / {requiredXP}`
	end

	-- Update rebirth
	if labels.Rebirth then
		labels.Rebirth.Text = `Rebirth: {data.Progression.RebirthLevel}`
		if data.Progression.RebirthLevel > 0 then
			labels.Rebirth.TextColor3 = Color3.fromRGB(255, 100, 255)
		end
	end

	-- Update currencies
	if labels.Coins then
		labels.Coins.Text = `💰 Coins: {data.Currencies.Coins}`
		labels.Coins.TextColor3 = Color3.fromRGB(255, 215, 0)
	end

	if labels.Gems then
		labels.Gems.Text = `💎 Gems: {data.Currencies.Gems}`
		labels.Gems.TextColor3 = Color3.fromRGB(100, 200, 255)
	end

	-- Update strength
	if labels.Strength then
		labels.Strength.Text = `⚔️ Strength: {data.Stats.Strength}`
	end

	-- Update zone
	if labels.Zone then
		local ZoneConfig = require(ReplicatedStorage.Shared.Config.ZoneConfig)
		local zoneData = ZoneConfig[data.Zones.CurrentZone]
		if zoneData then
			labels.Zone.Text = `📍 {zoneData.DisplayName}`
		end
	end
end

-- Show level up animation
function HUD.ShowLevelUp(newLevel: number)
	if not hudFrame then
		return
	end

	-- Create level up notification
	local notification = Instance.new("TextLabel")
	notification.Name = "LevelUpNotification"
	notification.Size = UDim2.new(0, 300, 0, 60)
	notification.Position = UDim2.new(0.5, -150, 0.3, 0)
	notification.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
	notification.BackgroundTransparency = 0.2
	notification.Text = `🎉 LEVEL UP!\nLevel {newLevel}`
	notification.TextColor3 = Color3.fromRGB(255, 255, 255)
	notification.TextSize = 28
	notification.Font = Enum.Font.GothamBold
	notification.TextYAlignment = Enum.TextYAlignment.Center
	notification.Parent = UIManager.GetScreen("HUD")

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = notification

	-- Animate and remove
	task.spawn(function()
		-- Scale up
		notification:TweenSize(
			UDim2.new(0, 350, 0, 80),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Elastic,
			0.5,
			true
		)

		task.wait(2)

		-- Fade out
		notification:TweenPosition(
			UDim2.new(0.5, -150, 0.2, 0),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.5,
			true
		)

		local tween = game:GetService("TweenService"):Create(
			notification,
			TweenInfo.new(0.5),
			{ BackgroundTransparency = 1, TextTransparency = 1 }
		)
		tween:Play()

		task.wait(0.5)
		notification:Destroy()
	end)
end

return HUD
