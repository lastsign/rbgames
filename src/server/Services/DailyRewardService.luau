--!strict
-- DailyRewardService.luau
-- Handles daily login rewards and streaks

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)
local DailyRewardConfig = require(ReplicatedStorage.Shared.Config.DailyRewardConfig)

local DailyRewardService = {}

-- Get reward for specific day
local function GetRewardForDay(day: number): { Coins: number, Gems: number }
	-- Check if we have a defined reward for this day
	if day <= DailyRewardConfig.MaxDefinedDays then
		local reward = DailyRewardConfig.Rewards[day]
		return { Coins = reward.Coins, Gems = reward.Gems }
	else
		-- Use formula for days beyond defined rewards
		return FormulaCalculator.CalculateDailyReward(day)
	end
end

-- Claim daily reward
function DailyRewardService.ClaimDailyReward(player: Player): { Success: boolean, Reward: any?, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	local currentDate = DateTime.now():ToIsoDate()

	-- Check if can claim
	if not FormulaCalculator.CanClaimDailyReward(playerData.DailyRewards.LastClaimDate, currentDate) then
		return { Success = false, Message = "Already claimed today. Come back tomorrow!" }
	end

	-- Calculate new streak
	local newStreak: number
	if FormulaCalculator.ShouldContinueStreak(playerData.DailyRewards.LastClaimDate, currentDate) then
		newStreak = playerData.DailyRewards.CurrentStreak + 1
	else
		-- Streak broken
		newStreak = 1
	end

	-- Get reward for current streak day
	local reward = GetRewardForDay(newStreak)

	-- Award rewards
	local success = DataService.UpdateData(player, function(data)
		-- Award currency
		data.Currencies.Coins += reward.Coins
		data.Currencies.Gems += reward.Gems

		-- Update daily reward data
		data.DailyRewards.LastClaimDate = currentDate
		data.DailyRewards.CurrentStreak = newStreak
		data.DailyRewards.TotalDaysClaimed += 1
	end)

	if success then
		-- Notify client
		ServerNetworker.Events.DailyRewardClaimed:FireClient(player, {
			Streak = newStreak,
			Reward = reward,
		})

		-- Replicate updated data
		local replicatedData = DataService.GetReplicatedData(player)
		if replicatedData then
			ServerNetworker.ReplicateData(player, replicatedData)
		end

		return { Success = true, Reward = reward }
	else
		return { Success = false, Message = "Failed to update data" }
	end
end

-- Check if player can claim (called on login)
function DailyRewardService.CheckDailyReward(player: Player)
	local playerData = DataService.GetData(player)
	if not playerData then
		return
	end

	local currentDate = DateTime.now():ToIsoDate()

	if FormulaCalculator.CanClaimDailyReward(playerData.DailyRewards.LastClaimDate, currentDate) then
		-- Show daily reward UI to client
		-- (Client will display notification/popup)
		print(`[DailyReward] Player {player.Name} can claim daily reward`)
	end
end

-- Setup network handlers
ServerNetworker.Functions.ClaimDailyReward.OnServerInvoke = function(player)
	return DailyRewardService.ClaimDailyReward(player)
end

return DailyRewardService
