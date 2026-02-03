--!strict
-- PetConfig.luau
-- Configuration for pets

export type PetData = {
	ID: string,
	Name: string,
	DisplayName: string,
	Rarity: string,
	Bonuses: {
		DamageMultiplier: number?,
		XPMultiplier: number?,
		CoinMultiplier: number?,
	},
	DropChance: number, -- Chance to obtain from egg (0-1)
}

local PetConfig: { [string]: PetData } = {
	-- Common Pets
	Dog = {
		ID = "Dog",
		Name = "Dog",
		DisplayName = "Loyal Dog",
		Rarity = "Common",
		Bonuses = {
			DamageMultiplier = 1.1, -- +10% damage
		},
		DropChance = 0.5,
	},

	Cat = {
		ID = "Cat",
		Name = "Cat",
		DisplayName = "Swift Cat",
		Rarity = "Common",
		Bonuses = {
			XPMultiplier = 1.15, -- +15% XP
		},
		DropChance = 0.5,
	},

	-- Rare Pets
	Hawk = {
		ID = "Hawk",
		Name = "Hawk",
		DisplayName = "Hunting Hawk",
		Rarity = "Rare",
		Bonuses = {
			DamageMultiplier = 1.25,
			CoinMultiplier = 1.1,
		},
		DropChance = 0.25,
	},

	Bear = {
		ID = "Bear",
		Name = "Bear",
		DisplayName = "Grizzly Bear",
		Rarity = "Rare",
		Bonuses = {
			DamageMultiplier = 1.3,
		},
		DropChance = 0.25,
	},

	-- Epic Pets
	Phoenix = {
		ID = "Phoenix",
		Name = "Phoenix",
		DisplayName = "Blazing Phoenix",
		Rarity = "Epic",
		Bonuses = {
			DamageMultiplier = 1.5,
			XPMultiplier = 1.3,
		},
		DropChance = 0.1,
	},

	Unicorn = {
		ID = "Unicorn",
		Name = "Unicorn",
		DisplayName = "Mystic Unicorn",
		Rarity = "Epic",
		Bonuses = {
			XPMultiplier = 1.5,
			CoinMultiplier = 1.4,
		},
		DropChance = 0.1,
	},

	-- Legendary Pets
	Dragon = {
		ID = "Dragon",
		Name = "Dragon",
		DisplayName = "Ancient Dragon",
		Rarity = "Legendary",
		Bonuses = {
			DamageMultiplier = 2.0,
			XPMultiplier = 1.8,
			CoinMultiplier = 1.5,
		},
		DropChance = 0.01,
	},
}

-- Egg configuration
export type EggData = {
	Name: string,
	DisplayName: string,
	Cost: number,
	CostType: string, -- "Coins" or "Gems"
	PetPool: { string }, -- Pet IDs that can be obtained
}

local EggConfig: { [string]: EggData } = {
	BasicEgg = {
		Name = "BasicEgg",
		DisplayName = "Basic Egg",
		Cost = 500,
		CostType = "Coins",
		PetPool = { "Dog", "Cat" },
	},

	RareEgg = {
		Name = "RareEgg",
		DisplayName = "Rare Egg",
		Cost = 2000,
		CostType = "Coins",
		PetPool = { "Dog", "Cat", "Hawk", "Bear" },
	},

	EpicEgg = {
		Name = "EpicEgg",
		DisplayName = "Epic Egg",
		Cost = 100,
		CostType = "Gems",
		PetPool = { "Hawk", "Bear", "Phoenix", "Unicorn" },
	},

	LegendaryEgg = {
		Name = "LegendaryEgg",
		DisplayName = "Legendary Egg",
		Cost = 500,
		CostType = "Gems",
		PetPool = { "Phoenix", "Unicorn", "Dragon" },
	},
}

return {
	Pets = table.freeze(PetConfig),
	Eggs = table.freeze(EggConfig),
	MaxEquipped = 3, -- Maximum pets that can be equipped at once
}
