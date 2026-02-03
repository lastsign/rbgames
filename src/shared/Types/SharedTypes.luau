--!strict
-- SharedTypes.luau
-- Shared type definitions used across the codebase

-- Re-export PlayerData types
export type PlayerData = {
	Progression: {
		Level: number,
		Experience: number,
		RebirthLevel: number,
	},
	Stats: {
		Strength: number,
		Speed: number,
		Defense: number,
		CritChance: number,
		CritMultiplier: number,
	},
	Currencies: {
		Coins: number,
		Gems: number,
	},
	Upgrades: {
		Strength: number,
		Speed: number,
		Defense: number,
		CritChance: number,
		CritMultiplier: number,
	},
	Zones: {
		UnlockedZones: { string },
		CurrentZone: string,
	},
	Pets: {
		Owned: { Pet },
		Equipped: { string },
	},
	DailyRewards: {
		LastClaimDate: string,
		CurrentStreak: number,
		TotalDaysClaimed: number,
	},
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

-- Combat types
export type CombatResult = {
	Damage: number,
	IsCrit: boolean,
	MobHealth: number,
	MobMaxHealth: number,
	MobKilled: boolean,
	Rewards: {
		XP: number,
		Coins: number,
	}?,
}

-- Network response types
export type NetworkResponse = {
	Success: boolean,
	Message: string?,
	Data: any?,
}

return {}
