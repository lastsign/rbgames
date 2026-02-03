--!strict
-- ZoneConfig.luau
-- Configuration for all game zones

export type ZoneData = {
	Name: string,
	DisplayName: string,
	UnlockLevel: number,
	UnlockRebirthLevel: number,
	XPMultiplier: number,
	CoinMultiplier: number,
	SpawnLocation: Vector3?,
	MobTypes: { string },
}

local ZoneConfig: { [string]: ZoneData } = {
	StarterZone = {
		Name = "StarterZone",
		DisplayName = "Starter Plains",
		UnlockLevel = 1,
		UnlockRebirthLevel = 0,
		XPMultiplier = 1.0,
		CoinMultiplier = 1.0,
		SpawnLocation = Vector3.new(0, 5, 0),
		MobTypes = { "Slime", "Goblin" },
	},

	ForestZone = {
		Name = "ForestZone",
		DisplayName = "Dark Forest",
		UnlockLevel = 10,
		UnlockRebirthLevel = 0,
		XPMultiplier = 1.5,
		CoinMultiplier = 1.5,
		SpawnLocation = Vector3.new(200, 5, 0),
		MobTypes = { "Goblin", "Wolf", "Orc" },
	},

	MountainZone = {
		Name = "MountainZone",
		DisplayName = "Rocky Mountains",
		UnlockLevel = 20,
		UnlockRebirthLevel = 0,
		XPMultiplier = 2.0,
		CoinMultiplier = 2.0,
		SpawnLocation = Vector3.new(400, 50, 0),
		MobTypes = { "Orc", "Troll" },
	},

	VolcanoZone = {
		Name = "VolcanoZone",
		DisplayName = "Volcanic Wasteland",
		UnlockLevel = 30,
		UnlockRebirthLevel = 1,
		XPMultiplier = 3.0,
		CoinMultiplier = 3.0,
		SpawnLocation = Vector3.new(600, 5, 200),
		MobTypes = { "Dragon" },
	},
}

return table.freeze(ZoneConfig)
