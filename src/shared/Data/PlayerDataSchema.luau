--!strict
-- PlayerDataSchema.luau
-- Defines the complete data structure for player data in ProfileService

export type PlayerData = {
	-- Progression
	Progression: {
		Level: number,
		Experience: number,
		RebirthLevel: number,
	},

	-- Stats
	Stats: {
		Strength: number,
		Speed: number,
		Defense: number,
		CritChance: number,
		CritMultiplier: number,
	},

	-- Currencies
	Currencies: {
		Coins: number,
		Gems: number,
	},

	-- Upgrades (number of times purchased)
	Upgrades: {
		Strength: number,
		Speed: number,
		Defense: number,
		CritChance: number,
		CritMultiplier: number,
	},

	-- Zones
	Zones: {
		UnlockedZones: { string },
		CurrentZone: string,
	},

	-- Pets
	Pets: {
		Owned: { Pet },
		Equipped: { string }, -- Pet IDs (max 3-5)
	},

	-- Weapons
	Weapons: {
		Owned: { Weapon },
		Equipped: string?, -- Weapon ID
	},

	-- Daily Rewards
	DailyRewards: {
		LastClaimDate: string, -- ISO 8601 date string
		CurrentStreak: number,
		TotalDaysClaimed: number,
	},

	-- Metadata
	_Version: number,
}

export type Pet = {
	ID: string,
	Name: string,
	Rarity: string,
	Bonuses: {
		DamageMultiplier: number?,
		XPMultiplier: number?,
		CoinMultiplier: number?,
	},
}

export type Weapon = {
	ID: string, -- unique instance ID
	WeaponType: string, -- config key
	AcquiredAt: number, -- Unix timestamp
}

return {}
