--!strict
-- init.server.luau
-- Server entry point

local Players = game:GetService("Players")

local DataService = require(script.Services.DataService)
local CombatService = require(script.Services.CombatService)
local ProgressionService = require(script.Services.ProgressionService)
local UpgradeService = require(script.Services.UpgradeService)
local PetService = require(script.Services.PetService)
local RebirthService = require(script.Services.RebirthService)
local DailyRewardService = require(script.Services.DailyRewardService)
local ZoneService = require(script.Services.ZoneService)
local WeaponService = require(script.Services.WeaponService)
local ProductService = require(script.Services.ProductService)
local ServerNetworker = require(script.Network.ServerNetworker)
local MobSpawner = require(script.Systems.MobSpawner)
local WorldBuilder = require(script.Systems.WorldBuilder)

print("[Server] RPG Game initializing...")

-- Build the world first
WorldBuilder.Initialize()

-- Initialize mob spawning (after world is built)
MobSpawner.Initialize()

-- Initialize Robux purchase handling
ProductService.Initialize()

-- Player joined
Players.PlayerAdded:Connect(function(player)
	print(`[Server] Player {player.Name} joining...`)

	-- Load player data
	DataService.LoadProfileAsync(player)
		:andThen(function()
			print(`[Server] Profile loaded for {player.Name}`)

			-- Replicate initial data to client
			local replicatedData = DataService.GetReplicatedData(player)
			if replicatedData then
				ServerNetworker.ReplicateData(player, replicatedData)
			end

			-- Initialize player services
			CombatService.InitializePlayer(player)

			-- Check for daily reward
			DailyRewardService.CheckDailyReward(player)
		end)
		:catch(function(err)
			warn(`[Server] Failed to load profile for {player.Name}: {err}`)
			player:Kick("Failed to load player data. Please rejoin.")
		end)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player)
	print(`[Server] Player {player.Name} leaving...`)

	-- Save and release profile
	DataService.ReleaseProfile(player)
	CombatService.CleanupPlayer(player)
end)

print("[Server] RPG Game initialized!")
