--!strict
-- UpgradeConfig.luau
-- Configuration for stat upgrades

export type UpgradeData = {
	Name: string,
	DisplayName: string,
	Description: string,
	BaseCost: number,
	BaseIncrease: number,
	StatType: string, -- Maps to Stats field
}

local UpgradeConfig: { [string]: UpgradeData } = {
	Strength = {
		Name = "Strength",
		DisplayName = "Strength Upgrade",
		Description = "Increase your damage output",
		BaseCost = 100,
		BaseIncrease = 5,
		StatType = "Strength",
	},

	Speed = {
		Name = "Speed",
		DisplayName = "Speed Upgrade",
		Description = "Increase your attack speed",
		BaseCost = 100,
		BaseIncrease = 5,
		StatType = "Speed",
	},

	Defense = {
		Name = "Defense",
		DisplayName = "Defense Upgrade",
		Description = "Reduce damage taken",
		BaseCost = 100,
		BaseIncrease = 3,
		StatType = "Defense",
	},

	CritChance = {
		Name = "CritChance",
		DisplayName = "Crit Chance Upgrade",
		Description = "Increase critical hit chance",
		BaseCost = 200,
		BaseIncrease = 0.01, -- +1% per upgrade
		StatType = "CritChance",
	},

	CritMultiplier = {
		Name = "CritMultiplier",
		DisplayName = "Crit Damage Upgrade",
		Description = "Increase critical hit damage",
		BaseCost = 250,
		BaseIncrease = 0.1, -- +0.1x per upgrade
		StatType = "CritMultiplier",
	},
}

return table.freeze(UpgradeConfig)
