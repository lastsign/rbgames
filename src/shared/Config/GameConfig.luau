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
	-- First few upgrades cheap, then scaling kicks in hard
	UpgradeCostScaling = 1.20, -- Steeper scaling (was 1.15)

	-- Rebirth settings - achievable earlier for faster loop
	RebirthLevelRequirement = 35, -- Lower requirement (was 50)
	RebirthBonusPerLevel = 0.15, -- 15% bonus per rebirth (was 10%)

	-- Daily rewards
	DailyRewardCooldown = 24, -- Hours
	DailyStreakWindow = 48, -- Hours to maintain streak

	-- Performance settings
	MaxMobsPerZone = 25,
	MobRespawnTime = 1, -- Seconds
}

return table.freeze(GameConfig)
