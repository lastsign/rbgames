--!strict
-- RebirthConfig.luau
-- Configuration for rebirth/prestige system

local RebirthConfig = {
	-- Level required to rebirth
	RequiredLevel = 50,

	-- Bonuses per rebirth level
	DamageMultiplierPerRebirth = 0.1, -- +10% damage per rebirth
	XPMultiplierPerRebirth = 0.15, -- +15% XP per rebirth
	CoinMultiplierPerRebirth = 0.1, -- +10% coins per rebirth

	-- What gets reset on rebirth
	ResetsProgression = true, -- Level and XP
	ResetsStats = true, -- Back to base stats
	ResetsUpgrades = true, -- All upgrade purchases
	ResetsPets = false, -- Keep pets
	ResetsZones = false, -- Keep unlocked zones (except rebirth-only zones)

	-- Zone unlocks per rebirth
	ZoneUnlocks = {
		[1] = { "VolcanoZone" }, -- First rebirth unlocks Volcano Zone
		[5] = { "CelestialZone" }, -- Fifth rebirth unlocks Celestial Zone
		[10] = { "VoidZone" }, -- Tenth rebirth unlocks Void Zone
	},
}

return table.freeze(RebirthConfig)
