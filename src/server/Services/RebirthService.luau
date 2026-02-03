--!strict
-- RebirthService.luau
-- Handles rebirth/prestige system

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ProgressionService = require(script.Parent.ProgressionService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)
local RebirthConfig = require(ReplicatedStorage.Shared.Config.RebirthConfig)

local RebirthService = {}

-- Perform rebirth
function RebirthService.PerformRebirth(player: Player): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	-- Check if player meets level requirement
	if not FormulaCalculator.CanRebirth(playerData.Progression.Level, RebirthConfig.RequiredLevel) then
		return { Success = false, Message = `Reach level {RebirthConfig.RequiredLevel} to rebirth` }
	end

	-- Perform rebirth
	local newRebirthLevel = playerData.Progression.RebirthLevel + 1

	-- Reset progression
	if RebirthConfig.ResetsProgression then
		ProgressionService.ResetProgression(player)
	end

	-- Update rebirth level
	DataService.UpdateData(player, function(data)
		data.Progression.RebirthLevel = newRebirthLevel

		-- Unlock rebirth-specific zones
		if RebirthConfig.ZoneUnlocks[newRebirthLevel] then
			for _, zoneName in RebirthConfig.ZoneUnlocks[newRebirthLevel] do
				if not table.find(data.Zones.UnlockedZones, zoneName) then
					table.insert(data.Zones.UnlockedZones, zoneName)
				end
			end
		end
	end)

	-- Notify client
	ServerNetworker.Events.RebirthCompleted:FireClient(player, newRebirthLevel)

	-- Replicate updated data
	local replicatedData = DataService.GetReplicatedData(player)
	if replicatedData then
		ServerNetworker.ReplicateData(player, replicatedData)
	end

	return { Success = true }
end

-- Setup network handlers
ServerNetworker.Functions.PerformRebirth.OnServerInvoke = function(player)
	return RebirthService.PerformRebirth(player)
end

return RebirthService
