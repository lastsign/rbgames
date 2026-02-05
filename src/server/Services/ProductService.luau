--!strict
-- ProductService.luau
-- Handles Robux purchases via MarketplaceService

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ProductConfig = require(ReplicatedStorage.Shared.Config.ProductConfig)

local ProductService = {}

-- Track pending purchases (for receipt processing)
local PendingPurchases: { [string]: boolean } = {}

-- Process Developer Product purchase
local function ProcessProductPurchase(player: Player, productId: number): boolean
	local product = ProductConfig.GetProductById(productId)
	if not product then
		warn(`[ProductService] Unknown product ID: {productId}`)
		return false
	end

	local playerData = DataService.GetData(player)
	if not playerData then
		warn(`[ProductService] No data for player: {player.Name}`)
		return false
	end

	print(`[ProductService] Processing purchase: {product.Name} for {player.Name}`)

	-- Special handling for PowerBoost
	if product.Name == "Instant Power Boost" then
		DataService.UpdateData(player, function(data)
			data.Stats.Strength += 50
		end)
		print(`[ProductService] Granted +50 Strength to {player.Name}`)
		return true
	end

	-- Grant gems and coins
	DataService.UpdateData(player, function(data)
		if product.GemAmount and product.GemAmount > 0 then
			data.Currencies.Gems += product.GemAmount
		end
		if product.CoinAmount and product.CoinAmount > 0 then
			data.Currencies.Coins += product.CoinAmount
		end
	end)

	print(`[ProductService] Granted {product.GemAmount or 0} Gems, {product.CoinAmount or 0} Coins to {player.Name}`)
	return true
end

-- Receipt processor (called by MarketplaceService)
local function ProcessReceipt(receiptInfo: { [string]: any }): Enum.ProductPurchaseDecision
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player left, we'll process when they rejoin
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Check for duplicate processing
	local receiptKey = `{receiptInfo.PlayerId}_{receiptInfo.PurchaseId}`
	if PendingPurchases[receiptKey] then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	PendingPurchases[receiptKey] = true

	-- Process the purchase
	local success = ProcessProductPurchase(player, receiptInfo.ProductId)

	-- Cleanup
	PendingPurchases[receiptKey] = nil

	if success then
		-- Replicate updated data to client
		local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
		local replicatedData = DataService.GetReplicatedData(player)
		if replicatedData then
			ServerNetworker.ReplicateData(player, replicatedData)
		end

		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

-- Check if player owns a GamePass
function ProductService.OwnsGamePass(player: Player, gamePassName: string): boolean
	local gamePass = ProductConfig.GamePasses[gamePassName]
	if not gamePass or gamePass.GamePassId == 0 then
		return false
	end

	local success, owns = pcall(function()
		return MarketplaceService:UserOwnsGamePassAsync(player.UserId, gamePass.GamePassId)
	end)

	if success then
		return owns
	end

	warn(`[ProductService] Failed to check GamePass ownership for {player.Name}`)
	return false
end

-- Get player's GamePass multipliers
function ProductService.GetGamePassMultipliers(player: Player): { XP: number, Coins: number, Damage: number }
	local multipliers = {
		XP = 1.0,
		Coins = 1.0,
		Damage = 1.0,
	}

	-- VIP Pass
	if ProductService.OwnsGamePass(player, "VIP") then
		multipliers.XP *= 1.25
		multipliers.Coins *= 1.25
		multipliers.Damage *= 1.10
	end

	-- 2x XP
	if ProductService.OwnsGamePass(player, "DoubleXP") then
		multipliers.XP *= 2.0
	end

	-- 2x Coins
	if ProductService.OwnsGamePass(player, "DoubleCoins") then
		multipliers.Coins *= 2.0
	end

	return multipliers
end

-- Get extra pet slots from GamePass
function ProductService.GetExtraPetSlots(player: Player): number
	if ProductService.OwnsGamePass(player, "ExtraPetSlot") then
		return 3
	end
	return 0
end

-- Check if player has auto-farm
function ProductService.HasAutoFarm(player: Player): boolean
	return ProductService.OwnsGamePass(player, "AutoFarm")
end

-- Prompt player to buy a product
function ProductService.PromptPurchase(player: Player, productName: string)
	local product = ProductConfig.DeveloperProducts[productName]
	if product and product.ProductId ~= 0 then
		MarketplaceService:PromptProductPurchase(player, product.ProductId)
	else
		warn(`[ProductService] Cannot prompt purchase for: {productName}`)
	end
end

-- Prompt player to buy a GamePass
function ProductService.PromptGamePassPurchase(player: Player, gamePassName: string)
	local gamePass = ProductConfig.GamePasses[gamePassName]
	if gamePass and gamePass.GamePassId ~= 0 then
		MarketplaceService:PromptGamePassPurchase(player, gamePass.GamePassId)
	else
		warn(`[ProductService] Cannot prompt GamePass purchase for: {gamePassName}`)
	end
end

-- Initialize the service
function ProductService.Initialize()
	-- Set up receipt processor
	MarketplaceService.ProcessReceipt = ProcessReceipt

	-- Handle GamePass purchase prompts
	MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, purchased)
		if purchased then
			print(`[ProductService] {player.Name} purchased GamePass {gamePassId}`)
			-- Could add notification here
		end
	end)

	print("[ProductService] Initialized")
end

return ProductService
