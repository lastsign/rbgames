--!strict
-- ProgressionService.luau
-- Handles player leveling and stat progression

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)
local DefaultData = require(ReplicatedStorage.Shared.Data.DefaultData)

local ProgressionService = {}

-- Stat increases per level
local STAT_INCREASE_PER_LEVEL = {
	Strength = 2,
	Speed = 2,
	Defense = 1,
}

-- Award experience to player
function ProgressionService.AwardExperience(player: Player, amount: number)
	local playerData = DataService.GetData(player)
	if not playerData then
		return
	end

	local leveledUp = false
	local newLevel = playerData.Progression.Level
	local statIncreases = {}

	-- Update data
	DataService.UpdateData(player, function(data)
		data.Progression.Experience += amount

		-- Check for level up(s)
		while true do
			local xpNeeded = FormulaCalculator.GetExperienceForLevel(data.Progression.Level)

			if data.Progression.Experience >= xpNeeded then
				-- Level up!
				data.Progression.Experience -= xpNeeded
				data.Progression.Level += 1
				leveledUp = true
				newLevel = data.Progression.Level

				-- Increase stats
				for statName, increase in STAT_INCREASE_PER_LEVEL do
					if data.Stats[statName] then
						data.Stats[statName] += increase
						statIncreases[statName] = (statIncreases[statName] or 0) + increase
					end
				end
			else
				break
			end
		end
	end)

	-- Notify client of level up
	if leveledUp then
		ServerNetworker.NotifyLevelUp(player, newLevel, statIncreases)

		-- Check for zone unlocks
		ProgressionService.CheckZoneUnlocks(player)

		-- Replicate updated data
		local replicatedData = DataService.GetReplicatedData(player)
		if replicatedData then
			ServerNetworker.ReplicateData(player, replicatedData)
		end
	end
end

-- Check and unlock zones based on level/rebirth
function ProgressionService.CheckZoneUnlocks(player: Player)
	local playerData = DataService.GetData(player)
	if not playerData then
		return
	end

	local ZoneConfig = require(ReplicatedStorage.Shared.Config.ZoneConfig)

	for zoneName, zoneData in ZoneConfig do
		-- Check if zone is already unlocked
		if table.find(playerData.Zones.UnlockedZones, zoneName) then
			continue
		end

		-- Check unlock requirements
		local meetsLevelReq = playerData.Progression.Level >= zoneData.UnlockLevel
		local meetsRebirthReq = playerData.Progression.RebirthLevel >= zoneData.UnlockRebirthLevel

		if meetsLevelReq and meetsRebirthReq then
			-- Unlock zone
			DataService.UpdateData(player, function(data)
				table.insert(data.Zones.UnlockedZones, zoneName)
			end)

			-- Notify client
			ServerNetworker.NotifyZoneUnlocked(player, zoneName)
		end
	end
end

-- Reset player progression (used by rebirth)
function ProgressionService.ResetProgression(player: Player)
	DataService.UpdateData(player, function(data)
		data.Progression.Level = 1
		data.Progression.Experience = 0

		-- Reset stats to default
		data.Stats = {
			Strength = DefaultData.Stats.Strength,
			Speed = DefaultData.Stats.Speed,
			Defense = DefaultData.Stats.Defense,
			CritChance = DefaultData.Stats.CritChance,
			CritMultiplier = DefaultData.Stats.CritMultiplier,
		}

		-- Reset upgrades
		data.Upgrades = {
			Strength = 0,
			Speed = 0,
			Defense = 0,
			CritChance = 0,
			CritMultiplier = 0,
		}

		-- Reset zones (keep StarterZone)
		data.Zones.UnlockedZones = { "StarterZone" }
		data.Zones.CurrentZone = "StarterZone"
	end)
end

return ProgressionService
