--!strict
-- MobConfig.luau
-- Configuration for all mob types

export type MobData = {
	Name: string,
	Level: number,
	BaseHealth: number,
	Zones: { string },
	Model: string?, -- Path to mob model in workspace
}

-- BALANCE: Early mobs die fast (1-3 hits), mid-game mobs require upgrades
local MobConfig: { [string]: MobData } = {
	Slime = {
		Name = "Slime",
		Level = 1,
		BaseHealth = 15, -- Dies in 1-2 hits at start (was 50)
		Zones = { "StarterZone" },
	},

	Goblin = {
		Name = "Goblin",
		Level = 5,
		BaseHealth = 40, -- Dies in 2-3 hits early game (was 120)
		Zones = { "StarterZone", "ForestZone" },
	},

	Wolf = {
		Name = "Wolf",
		Level = 12,
		BaseHealth = 150, -- Requires some upgrades (was 250)
		Zones = { "ForestZone" },
	},

	Orc = {
		Name = "Orc",
		Level = 18,
		BaseHealth = 400, -- Mid-game wall - upgrades needed (was 500)
		Zones = { "ForestZone", "MountainZone" },
	},

	Troll = {
		Name = "Troll",
		Level = 25,
		BaseHealth = 1200, -- Hard wall - paid upgrades attractive (was 1000)
		Zones = { "MountainZone" },
	},

	Dragon = {
		Name = "Dragon",
		Level = 35,
		BaseHealth = 5000, -- Endgame boss - requires investment (was 3000)
		Zones = { "VolcanoZone" },
	},
}

return table.freeze(MobConfig)
