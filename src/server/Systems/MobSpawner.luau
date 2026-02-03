--!strict
-- MobSpawner.luau
-- Spawns mobs in zones

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local MobConfig = require(ReplicatedStorage.Shared.Config.MobConfig)
local ZoneConfig = require(ReplicatedStorage.Shared.Config.ZoneConfig)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)

local MobSpawner = {}

-- Create a basic mob model
local function CreateMobModel(mobType: string, position: Vector3): Model
	local mobConfig = MobConfig[mobType]
	local maxHealth = FormulaCalculator.CalculateMobHealth(mobConfig.BaseHealth, mobConfig.Level)

	local model = Instance.new("Model")
	model.Name = mobConfig.Name

	-- Create mob part (simple cube for now)
	local part = Instance.new("Part")
	part.Name = "MobBody"
	part.Size = Vector3.new(4, 5, 4)
	part.Position = position
	part.Anchored = true
	part.Parent = model

	-- Color based on level
	if mobConfig.Level <= 5 then
		part.BrickColor = BrickColor.new("Bright red")
	elseif mobConfig.Level <= 15 then
		part.BrickColor = BrickColor.new("Bright orange")
	elseif mobConfig.Level <= 25 then
		part.BrickColor = BrickColor.new("Bright violet")
	else
		part.BrickColor = BrickColor.new("Really black")
	end

	-- Add mob type identifier
	local mobTypeValue = Instance.new("StringValue")
	mobTypeValue.Name = "MobType"
	mobTypeValue.Value = mobType
	mobTypeValue.Parent = model

	-- Add level display
	local levelValue = Instance.new("IntValue")
	levelValue.Name = "Level"
	levelValue.Value = mobConfig.Level
	levelValue.Parent = model

	-- Add health display
	local healthGui = Instance.new("BillboardGui")
	healthGui.Name = "HealthDisplay"
	healthGui.Size = UDim2.new(5, 0, 1.5, 0)
	healthGui.StudsOffset = Vector3.new(0, 3.5, 0)
	healthGui.AlwaysOnTop = true
	healthGui.Parent = part

	-- Name label
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.Size = UDim2.new(1, 0, 0.4, 0)
	nameLabel.Position = UDim2.new(0, 0, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = `{mobConfig.Name} [Lv.{mobConfig.Level}]`
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0.5
	nameLabel.Parent = healthGui

	-- Health bar background
	local healthBarBg = Instance.new("Frame")
	healthBarBg.Name = "HealthBarBg"
	healthBarBg.Size = UDim2.new(0.9, 0, 0.25, 0)
	healthBarBg.Position = UDim2.new(0.05, 0, 0.5, 0)
	healthBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	healthBarBg.BorderSizePixel = 2
	healthBarBg.BorderColor3 = Color3.fromRGB(0, 0, 0)
	healthBarBg.Parent = healthGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0.3, 0)
	corner.Parent = healthBarBg

	-- Health bar fill
	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.new(1, 0, 1, 0)
	healthBar.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBarBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0.3, 0)
	fillCorner.Parent = healthBar

	-- Health text
	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.new(1, 0, 0.35, 0)
	healthText.Position = UDim2.new(0, 0, 0.8, 0)
	healthText.BackgroundTransparency = 1
	healthText.Text = `{maxHealth} / {maxHealth}`
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextScaled = true
	healthText.Font = Enum.Font.Gotham
	healthText.TextStrokeTransparency = 0.5
	healthText.Parent = healthGui

	model.PrimaryPart = part

	-- Add ClickDetector for easier clicking
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 32
	clickDetector.Parent = part

	return model
end

-- Spawn mobs in a zone
function MobSpawner.SpawnMobsInZone(zoneName: string, mobFolder: Folder)
	local zoneConfig = ZoneConfig[zoneName]
	if not zoneConfig then
		warn(`Invalid zone: {zoneName}`)
		return
	end

	local spawnLocation = zoneConfig.SpawnLocation or Vector3.new(0, 5, 0)

	-- Spawn 5 mobs of each type in the zone
	for _, mobType in zoneConfig.MobTypes do
		for i = 1, 5 do
			-- Random position around spawn location
			local offset = Vector3.new(
				math.random(-30, 30),
				0,
				math.random(-30, 30)
			)
			local position = spawnLocation + offset

			local mobModel = CreateMobModel(mobType, position)
			mobModel.Parent = mobFolder
		end
	end
end

-- Initialize mob spawning
function MobSpawner.Initialize()
	-- Create mob folder in workspace
	local mobFolder = Workspace:FindFirstChild("Mobs")
	if not mobFolder then
		mobFolder = Instance.new("Folder")
		mobFolder.Name = "Mobs"
		mobFolder.Parent = Workspace
	end

	-- Spawn mobs in all zones
	for zoneName, _ in ZoneConfig do
		MobSpawner.SpawnMobsInZone(zoneName, mobFolder)
	end

	print("[MobSpawner] Mobs spawned in all zones")
end

return MobSpawner
