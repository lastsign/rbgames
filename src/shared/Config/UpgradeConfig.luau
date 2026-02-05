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

-- BALANCE: Upgrades are powerful to incentivize purchase
-- Each upgrade gives noticeable boost (equivalent to 2-3 level ups)
local UpgradeConfig: { [string]: UpgradeData } = {
	Strength = {
		Name = "Strength",
		DisplayName = "Strength Upgrade",
		Description = "Increase your damage output",
		BaseCost = 75, -- Cheaper to start buying early (was 100)
		BaseIncrease = 8, -- Bigger impact (was 5)
		StatType = "Strength",
	},

	Speed = {
		Name = "Speed",
		DisplayName = "Speed Upgrade",
		Description = "Increase your attack speed",
		BaseCost = 100,
		BaseIncrease = 6, -- (was 5)
		StatType = "Speed",
	},

	Defense = {
		Name = "Defense",
		DisplayName = "Defense Upgrade",
		Description = "Reduce damage taken",
		BaseCost = 100,
		BaseIncrease = 4, -- (was 3)
		StatType = "Defense",
	},

	CritChance = {
		Name = "CritChance",
		DisplayName = "Crit Chance Upgrade",
		Description = "Increase critical hit chance",
		BaseCost = 150, -- More accessible (was 200)
		BaseIncrease = 0.02, -- +2% per upgrade (was 1%)
		StatType = "CritChance",
	},

	CritMultiplier = {
		Name = "CritMultiplier",
		DisplayName = "Crit Damage Upgrade",
		Description = "Increase critical hit damage",
		BaseCost = 200, -- (was 250)
		BaseIncrease = 0.15, -- +0.15x per upgrade (was 0.1)
		StatType = "CritMultiplier",
	},
}

return table.freeze(UpgradeConfig)
