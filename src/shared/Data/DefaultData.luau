--!strict
-- DefaultData.luau
-- Default player data for new profiles

local PlayerDataSchema = require(script.Parent.PlayerDataSchema)

local DefaultData: PlayerDataSchema.PlayerData = {
	Progression = {
		Level = 1,
		Experience = 0,
		RebirthLevel = 0,
	},

	Stats = {
		Strength = 10,
		Speed = 10,
		Defense = 5,
		CritChance = 0.05, -- 5%
		CritMultiplier = 1.5,
	},

	Currencies = {
		Coins = 0,
		Gems = 0,
	},

	Upgrades = {
		Strength = 0,
		Speed = 0,
		Defense = 0,
		CritChance = 0,
		CritMultiplier = 0,
	},

	Zones = {
		UnlockedZones = { "StarterZone" },
		CurrentZone = "StarterZone",
	},

	Pets = {
		Owned = {},
		Equipped = {},
	},

	Weapons = {
		Owned = { { ID = "WoodenSword_starter", WeaponType = "WoodenSword", AcquiredAt = 0 } },
		Equipped = "WoodenSword_starter",
	},

	DailyRewards = {
		LastClaimDate = "",
		CurrentStreak = 0,
		TotalDaysClaimed = 0,
	},

	_Version = 1,
}

return table.freeze(DefaultData)
