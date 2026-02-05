--!strict
-- ProductConfig.luau
-- Robux products and GamePasses configuration
-- NOTE: Replace placeholder IDs with real Developer Product/GamePass IDs from Roblox Creator Dashboard

export type DeveloperProduct = {
	ProductId: number,
	Name: string,
	Description: string,
	GemAmount: number?,
	CoinAmount: number?,
	DisplayPrice: string, -- For UI display
}

export type GamePassData = {
	GamePassId: number,
	Name: string,
	Description: string,
	Perks: { string },
}

local ProductConfig = {
	-- Developer Products (one-time purchases, can buy multiple times)
	-- These grant Gems which can be spent on premium items
	DeveloperProducts = {
		-- Starter pack - cheap entry point
		StarterGems = {
			ProductId = 0, -- REPLACE with real ID from Creator Dashboard
			Name = "Starter Gems",
			Description = "Perfect for beginners!",
			GemAmount = 50,
			CoinAmount = 500, -- Bonus coins
			DisplayPrice = "49 R$",
		} :: DeveloperProduct,

		-- Small gem pack
		SmallGems = {
			ProductId = 0, -- REPLACE with real ID
			Name = "Small Gem Pack",
			Description = "A handful of gems",
			GemAmount = 100,
			CoinAmount = 0,
			DisplayPrice = "79 R$",
		} :: DeveloperProduct,

		-- Medium gem pack - best value indicator
		MediumGems = {
			ProductId = 0, -- REPLACE with real ID
			Name = "Medium Gem Pack",
			Description = "BEST VALUE! +20% bonus gems",
			GemAmount = 300, -- 250 base + 50 bonus
			CoinAmount = 1000,
			DisplayPrice = "199 R$",
		} :: DeveloperProduct,

		-- Large gem pack
		LargeGems = {
			ProductId = 0, -- REPLACE with real ID
			Name = "Large Gem Pack",
			Description = "For serious players! +30% bonus",
			GemAmount = 750, -- 575 base + 175 bonus
			CoinAmount = 5000,
			DisplayPrice = "449 R$",
		} :: DeveloperProduct,

		-- Mega gem pack
		MegaGems = {
			ProductId = 0, -- REPLACE with real ID
			Name = "MEGA Gem Pack",
			Description = "ULTIMATE VALUE! +50% bonus gems",
			GemAmount = 2000, -- 1333 base + 667 bonus
			CoinAmount = 25000,
			DisplayPrice = "999 R$",
		} :: DeveloperProduct,

		-- Instant power boost
		PowerBoost = {
			ProductId = 0, -- REPLACE with real ID
			Name = "Instant Power Boost",
			Description = "+50 Strength instantly!",
			GemAmount = 0,
			CoinAmount = 0,
			DisplayPrice = "149 R$",
		} :: DeveloperProduct,
	},

	-- GamePasses (one-time permanent purchases)
	GamePasses = {
		-- VIP - permanent bonuses
		VIP = {
			GamePassId = 0, -- REPLACE with real ID
			Name = "VIP Pass",
			Description = "Permanent bonuses for true champions!",
			Perks = {
				"+25% XP from all sources",
				"+25% Coins from all sources",
				"+10% Damage boost",
				"Exclusive VIP chat tag",
				"Access to VIP-only zone",
			},
		} :: GamePassData,

		-- 2x XP permanent
		DoubleXP = {
			GamePassId = 0, -- REPLACE with real ID
			Name = "2x XP Forever",
			Description = "Double your experience gains permanently!",
			Perks = {
				"2x XP from killing mobs",
				"2x XP from quests",
				"Level up twice as fast!",
			},
		} :: GamePassData,

		-- 2x Coins permanent
		DoubleCoins = {
			GamePassId = 0, -- REPLACE with real ID
			Name = "2x Coins Forever",
			Description = "Double your coin earnings permanently!",
			Perks = {
				"2x Coins from killing mobs",
				"2x Coins from daily rewards",
				"Get upgrades faster!",
			},
		} :: GamePassData,

		-- Auto-farm
		AutoFarm = {
			GamePassId = 0, -- REPLACE with real ID
			Name = "Auto-Farm",
			Description = "Your character attacks automatically!",
			Perks = {
				"Automatic attacks on nearby mobs",
				"Works while AFK",
				"Never miss a hit!",
			},
		} :: GamePassData,

		-- Extra pet slot
		ExtraPetSlot = {
			GamePassId = 0, -- REPLACE with real ID
			Name = "+3 Pet Slots",
			Description = "Equip more pets at once!",
			Perks = {
				"+3 pet equipment slots (6 total)",
				"More pet bonuses active",
				"Stronger than ever!",
			},
		} :: GamePassData,
	},

	-- Helper: Get product by ID
	GetProductById = function(productId: number): DeveloperProduct?
		for _, product in ProductConfig.DeveloperProducts do
			if product.ProductId == productId then
				return product
			end
		end
		return nil
	end,

	-- Helper: Get gamepass by ID
	GetGamePassById = function(gamePassId: number): GamePassData?
		for _, gamePass in ProductConfig.GamePasses do
			if gamePass.GamePassId == gamePassId then
				return gamePass
			end
		end
		return nil
	end,
}

return table.freeze(ProductConfig)
