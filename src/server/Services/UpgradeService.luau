--!strict
-- UpgradeService.luau
-- Handles stat upgrade purchases

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)
local UpgradeConfig = require(ReplicatedStorage.Shared.Config.UpgradeConfig)

local UpgradeService = {}

-- Purchase an upgrade
function UpgradeService.PurchaseUpgrade(player: Player, upgradeName: string): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	local upgradeConfig = UpgradeConfig[upgradeName]
	if not upgradeConfig then
		return { Success = false, Message = "Invalid upgrade" }
	end

	-- Get current upgrade level
	local currentLevel = playerData.Upgrades[upgradeName] or 0

	-- Calculate cost
	local cost = FormulaCalculator.CalculateUpgradeCost(upgradeConfig.BaseCost, currentLevel)

	-- Check if player has enough coins
	if playerData.Currencies.Coins < cost then
		return { Success = false, Message = "Not enough coins" }
	end

	-- Calculate stat increase
	local statIncrease = FormulaCalculator.CalculateStatIncrease(upgradeConfig.BaseIncrease, currentLevel)

	-- Purchase upgrade
	local success = DataService.UpdateData(player, function(data)
		-- Deduct cost
		data.Currencies.Coins -= cost

		-- Increment upgrade level
		data.Upgrades[upgradeName] += 1

		-- Increase stat
		local statType = upgradeConfig.StatType
		if data.Stats[statType] then
			data.Stats[statType] += statIncrease
		end
	end)

	if success then
		-- Notify client
		ServerNetworker.Events.UpgradePurchased:FireClient(player, upgradeName, currentLevel + 1)

		-- Replicate updated data
		local replicatedData = DataService.GetReplicatedData(player)
		if replicatedData then
			ServerNetworker.ReplicateData(player, replicatedData)
		end

		return { Success = true }
	else
		return { Success = false, Message = "Failed to update data" }
	end
end

-- Setup network handlers
ServerNetworker.Functions.PurchaseUpgrade.OnServerInvoke = function(player, upgradeName)
	return UpgradeService.PurchaseUpgrade(player, upgradeName)
end

return UpgradeService
