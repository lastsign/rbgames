--!strict
-- ZoneService.luau
-- Handles zone management and teleportation

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local ZoneConfig = require(ReplicatedStorage.Shared.Config.ZoneConfig)

local ZoneService = {}

-- Teleport player to zone
function ZoneService.TeleportToZone(player: Player, zoneName: string): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	local zoneConfig = ZoneConfig[zoneName]
	if not zoneConfig then
		return { Success = false, Message = "Invalid zone" }
	end

	-- Check if zone is unlocked
	if not table.find(playerData.Zones.UnlockedZones, zoneName) then
		return { Success = false, Message = "Zone not unlocked" }
	end

	-- Update current zone
	DataService.UpdateData(player, function(data)
		data.Zones.CurrentZone = zoneName
	end)

	-- Teleport player character
	local character = player.Character
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart and zoneConfig.SpawnLocation then
			humanoidRootPart.CFrame = CFrame.new(zoneConfig.SpawnLocation)
		end
	end

	return { Success = true }
end

-- Setup network handlers
ServerNetworker.Functions.TeleportToZone.OnServerInvoke = function(player, zoneName)
	return ZoneService.TeleportToZone(player, zoneName)
end

return ZoneService
