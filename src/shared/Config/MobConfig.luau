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

local MobConfig: { [string]: MobData } = {
	Slime = {
		Name = "Slime",
		Level = 1,
		BaseHealth = 50,
		Zones = { "StarterZone" },
	},

	Goblin = {
		Name = "Goblin",
		Level = 5,
		BaseHealth = 120,
		Zones = { "StarterZone", "ForestZone" },
	},

	Wolf = {
		Name = "Wolf",
		Level = 10,
		BaseHealth = 250,
		Zones = { "ForestZone" },
	},

	Orc = {
		Name = "Orc",
		Level = 15,
		BaseHealth = 500,
		Zones = { "ForestZone", "MountainZone" },
	},

	Troll = {
		Name = "Troll",
		Level = 20,
		BaseHealth = 1000,
		Zones = { "MountainZone" },
	},

	Dragon = {
		Name = "Dragon",
		Level = 30,
		BaseHealth = 3000,
		Zones = { "VolcanoZone" },
	},
}

return table.freeze(MobConfig)
