--!strict
-- DataService.luau
-- ProfileService integration for player data persistence

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileService = require(ServerScriptService.ServerPackages.ProfileService)
local Promise = require(ReplicatedStorage.Packages.Promise)
local DefaultData = require(ReplicatedStorage.Shared.Data.DefaultData)
local PlayerDataSchema = require(ReplicatedStorage.Shared.Data.PlayerDataSchema)

local DataService = {}
DataService.__index = DataService

local PROFILE_STORE_NAME = "PlayerData"
local PROFILE_STORE_SCOPE = nil -- Global scope

type Profile = {
	Data: PlayerDataSchema.PlayerData,
	Release: (self: any) -> (),
	ListenToRelease: (self: any, callback: () -> ()) -> (),
	Reconcile: (self: any) -> (),
}

local ProfileStore = ProfileService.GetProfileStore(PROFILE_STORE_NAME, DefaultData)
local Profiles: { [Player]: Profile } = {}

-- Load player profile
function DataService.LoadProfileAsync(player: Player): typeof(Promise.new())
	return Promise.new(function(resolve, reject)
		local profileKey = `Player_{player.UserId}`
		local profile = ProfileStore:LoadProfileAsync(profileKey) :: Profile?

		if not profile then
			reject("Failed to load profile")
			return
		end

		-- Handle profile session lock
		profile:Reconcile()

		profile:ListenToRelease(function()
			Profiles[player] = nil
			player:Kick("Profile session ended")
		end)

		if player:IsDescendantOf(Players) then
			Profiles[player] = profile
			resolve(profile)
		else
			-- Player left before profile loaded
			profile:Release()
			reject("Player left")
		end
	end)
end

-- Get player profile
function DataService.GetProfile(player: Player): Profile?
	return Profiles[player]
end

-- Get player data
function DataService.GetData(player: Player): PlayerDataSchema.PlayerData?
	local profile = Profiles[player]
	return if profile then profile.Data else nil
end

-- Update player data (safe mutation)
function DataService.UpdateData(
	player: Player,
	updater: (data: PlayerDataSchema.PlayerData) -> ()
): boolean
	local profile = Profiles[player]
	if not profile then
		return false
	end

	updater(profile.Data)
	return true
end

-- Save and release profile on player leave
function DataService.ReleaseProfile(player: Player)
	local profile = Profiles[player]
	if profile then
		profile:Release()
		Profiles[player] = nil
	end
end

-- Get replicated data for client (selective fields)
function DataService.GetReplicatedData(player: Player)
	local data = DataService.GetData(player)
	if not data then
		return nil
	end

	-- Only send necessary data to client
	return {
		Progression = {
			Level = data.Progression.Level,
			Experience = data.Progression.Experience,
			RebirthLevel = data.Progression.RebirthLevel,
		},
		Stats = {
			Strength = data.Stats.Strength,
			Speed = data.Stats.Speed,
			Defense = data.Stats.Defense,
			CritChance = data.Stats.CritChance,
			CritMultiplier = data.Stats.CritMultiplier,
		},
		Currencies = {
			Coins = data.Currencies.Coins,
			Gems = data.Currencies.Gems,
		},
		Upgrades = {
			Strength = data.Upgrades.Strength,
			Speed = data.Upgrades.Speed,
			Defense = data.Upgrades.Defense,
			CritChance = data.Upgrades.CritChance,
			CritMultiplier = data.Upgrades.CritMultiplier,
		},
		Zones = {
			UnlockedZones = data.Zones.UnlockedZones,
			CurrentZone = data.Zones.CurrentZone,
		},
		Pets = {
			Owned = data.Pets.Owned,
			Equipped = data.Pets.Equipped,
		},
		DailyRewards = {
			LastClaimDate = data.DailyRewards.LastClaimDate,
			CurrentStreak = data.DailyRewards.CurrentStreak,
			TotalDaysClaimed = data.DailyRewards.TotalDaysClaimed,
		},
		Weapons = {
			Owned = data.Weapons.Owned,
			Equipped = data.Weapons.Equipped,
		},
	}
end

return DataService
