--!strict
-- WeaponConfig.luau
-- Weapon definitions and stats

export type WeaponData = {
	ID: string,
	DisplayName: string,
	Type: "Melee" | "Ranged",
	Rarity: "Common" | "Rare" | "Epic" | "Legendary",
	DamageMultiplier: number,
	AttackSpeed: number, -- attacks per second
	AttackRange: number, -- studs
	Cost: number,
	CostType: "Coins" | "Gems",
	RequiredLevel: number?,
	Description: string?,
}

local WeaponConfig: { [string]: WeaponData } = {
	-- Starter weapon (free)
	WoodenSword = {
		ID = "WoodenSword",
		DisplayName = "Wooden Sword",
		Type = "Melee",
		Rarity = "Common",
		DamageMultiplier = 1.0,
		AttackSpeed = 1.5,
		AttackRange = 8,
		Cost = 0,
		CostType = "Coins",
		Description = "A simple wooden training sword.",
	},

	-- Coin weapons (progression)
	IronSword = {
		ID = "IronSword",
		DisplayName = "Iron Sword",
		Type = "Melee",
		Rarity = "Common",
		DamageMultiplier = 1.15,
		AttackSpeed = 1.6,
		AttackRange = 8,
		Cost = 500,
		CostType = "Coins",
		Description = "A sturdy iron blade.",
	},

	BattleAxe = {
		ID = "BattleAxe",
		DisplayName = "Battle Axe",
		Type = "Melee",
		Rarity = "Rare",
		DamageMultiplier = 1.3,
		AttackSpeed = 1.2,
		AttackRange = 9,
		Cost = 750,
		CostType = "Coins",
		Description = "Heavy but powerful.",
	},

	SteelBlade = {
		ID = "SteelBlade",
		DisplayName = "Steel Blade",
		Type = "Melee",
		Rarity = "Rare",
		DamageMultiplier = 1.35,
		AttackSpeed = 1.8,
		AttackRange = 8,
		Cost = 2500,
		CostType = "Coins",
		Description = "A well-crafted steel sword.",
	},

	Warhammer = {
		ID = "Warhammer",
		DisplayName = "Warhammer",
		Type = "Melee",
		Rarity = "Epic",
		DamageMultiplier = 1.5,
		AttackSpeed = 1.0,
		AttackRange = 7,
		Cost = 3000,
		CostType = "Coins",
		Description = "Slow but devastating.",
	},

	-- Gem weapons (premium)
	MysticBlade = {
		ID = "MysticBlade",
		DisplayName = "Mystic Blade",
		Type = "Melee",
		Rarity = "Epic",
		DamageMultiplier = 1.6,
		AttackSpeed = 1.7,
		AttackRange = 9,
		Cost = 100,
		CostType = "Gems",
		RequiredLevel = 15,
		Description = "Infused with magical energy.",
	},

	DragonSlayer = {
		ID = "DragonSlayer",
		DisplayName = "Dragon Slayer",
		Type = "Melee",
		Rarity = "Legendary",
		DamageMultiplier = 2.0,
		AttackSpeed = 1.5,
		AttackRange = 10,
		Cost = 500,
		CostType = "Gems",
		RequiredLevel = 30,
		Description = "Legendary blade of dragon hunters.",
	},
}

-- Rarity colors for UI
local RarityColors: { [string]: Color3 } = {
	Common = Color3.fromRGB(200, 200, 200),
	Rare = Color3.fromRGB(100, 150, 255),
	Epic = Color3.fromRGB(200, 100, 255),
	Legendary = Color3.fromRGB(255, 200, 50),
}

-- Helper function to get rarity color
local function GetRarityColor(rarity: string): Color3
	return RarityColors[rarity] or RarityColors.Common
end

-- Helper function to get weapon by ID
local function GetWeapon(weaponType: string): WeaponData?
	return WeaponConfig[weaponType]
end

-- Helper function to get all weapons sorted by cost
local function GetWeaponsSorted(): { WeaponData }
	local weapons = {}
	for _, weapon in WeaponConfig do
		table.insert(weapons, weapon)
	end
	table.sort(weapons, function(a, b)
		-- Sort by cost type first (Coins before Gems), then by cost
		if a.CostType ~= b.CostType then
			return a.CostType == "Coins"
		end
		return a.Cost < b.Cost
	end)
	return weapons
end

return {
	Weapons = WeaponConfig,
	RarityColors = RarityColors,
	GetRarityColor = GetRarityColor,
	GetWeapon = GetWeapon,
	GetWeaponsSorted = GetWeaponsSorted,
}
