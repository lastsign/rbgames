--!strict
-- GameConfig.luau
-- General game configuration

local GameConfig = {
	-- Game info
	GameName = "RPG Grind Game",
	Version = "0.1.0",

	-- Combat settings
	AttackCooldown = 0.5, -- Seconds between attacks
	CritChanceMax = 0.75, -- Maximum crit chance (75%)
	CritMultiplierMax = 5.0, -- Maximum crit multiplier

	-- Progression settings
	MaxLevel = 100, -- Maximum level before requiring rebirth
	BaseXPRequirement = 100, -- Base XP for level 2
	XPScalingExponent = 1.5, -- Exponential scaling for XP requirements

	-- Currency settings
	StartingCoins = 0,
	StartingGems = 0,

	-- Pet settings
	MaxEquippedPets = 3,
	PetVisualOffset = Vector3.new(3, 0, 0), -- Offset for pet position

	-- Zone settings
	TeleportCooldown = 2, -- Seconds between zone teleports

	-- Shop settings
	UpgradeCostScaling = 1.15, -- Multiplier for each upgrade level

	-- Rebirth settings
	RebirthLevelRequirement = 50,
	RebirthBonusPerLevel = 0.1, -- 10% bonus per rebirth

	-- Daily rewards
	DailyRewardCooldown = 24, -- Hours
	DailyStreakWindow = 48, -- Hours to maintain streak

	-- Performance settings
	MaxMobsPerZone = 25,
	MobRespawnTime = 1, -- Seconds
}

return table.freeze(GameConfig)
