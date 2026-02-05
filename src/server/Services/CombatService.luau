--!strict
-- CombatService.luau
-- Handles combat calculations and mob interactions

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ProgressionService = require(script.Parent.ProgressionService)
local WeaponService = require(script.Parent.WeaponService)
local ProductService = require(script.Parent.ProductService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local FormulaCalculator = require(ReplicatedStorage.Shared.Utils.FormulaCalculator)
local MobConfig = require(ReplicatedStorage.Shared.Config.MobConfig)

local CombatService = {}

-- Track active mobs per player
local ActiveMobs: { [Player]: { [string]: MobInstance } } = {}

-- Track attack cooldowns per player (anti-cheat)
local LastAttackTime: { [Player]: number } = {}

type MobInstance = {
	MobType: string,
	CurrentHealth: number,
	MaxHealth: number,
	Level: number,
}

-- Initialize player combat state
function CombatService.InitializePlayer(player: Player)
	ActiveMobs[player] = {}
end

-- Cleanup player combat state
function CombatService.CleanupPlayer(player: Player)
	ActiveMobs[player] = nil
	LastAttackTime[player] = nil
end

-- Spawn a mob for the player
function CombatService.SpawnMob(player: Player, mobType: string): MobInstance?
	local mobConfig = MobConfig[mobType]
	if not mobConfig then
		warn(`Invalid mob type: {mobType}`)
		return nil
	end

	local maxHealth = FormulaCalculator.CalculateMobHealth(mobConfig.BaseHealth, mobConfig.Level)

	local mobInstance: MobInstance = {
		MobType = mobType,
		CurrentHealth = maxHealth,
		MaxHealth = maxHealth,
		Level = mobConfig.Level,
	}

	-- Store mob instance (use unique ID if multiple mobs per player)
	ActiveMobs[player][mobType] = mobInstance

	return mobInstance
end

-- Get equipped pet multipliers
local function GetPetMultipliers(playerData: any): { Damage: number, XP: number, Coin: number }
	local multipliers = {
		Damage = 1.0,
		XP = 1.0,
		Coin = 1.0,
	}

	-- Calculate bonuses from equipped pets
	for _, petID in playerData.Pets.Equipped do
		for _, pet in playerData.Pets.Owned do
			if pet.ID == petID then
				if pet.Bonuses.DamageMultiplier then
					multipliers.Damage *= pet.Bonuses.DamageMultiplier
				end
				if pet.Bonuses.XPMultiplier then
					multipliers.XP *= pet.Bonuses.XPMultiplier
				end
				if pet.Bonuses.CoinMultiplier then
					multipliers.Coin *= pet.Bonuses.CoinMultiplier
				end
			end
		end
	end

	return multipliers
end

-- Attack mob (called by client)
function CombatService.AttackMob(player: Player, mobType: string): { Success: boolean, Result: any? }
	local playerData = DataService.GetData(player)
	if not playerData then
		warn("[CombatService] Player data not found for", player.Name)
		return { Success = false }
	end

	-- Get equipped weapon data
	local weaponData = WeaponService.GetEquippedWeaponData(player)
	local weaponMultiplier = if weaponData then weaponData.DamageMultiplier else 1.0
	local attackSpeed = if weaponData then weaponData.AttackSpeed else 1.5

	-- Validate attack cooldown (anti-cheat)
	local currentTime = tick()
	local lastAttack = LastAttackTime[player] or 0
	local cooldown = 1 / attackSpeed
	if currentTime - lastAttack < cooldown * 0.9 then -- Allow 10% tolerance
		return { Success = false, Message = "Attack on cooldown" }
	end
	LastAttackTime[player] = currentTime

	-- Ensure player has ActiveMobs table
	if not ActiveMobs[player] then
		warn("[CombatService] ActiveMobs not initialized for", player.Name, "- initializing now")
		CombatService.InitializePlayer(player)
	end

	-- Get or spawn mob
	local mob = ActiveMobs[player][mobType]
	if not mob then
		print(`[CombatService] Spawning new {mobType} for {player.Name}`)
		mob = CombatService.SpawnMob(player, mobType)
		if not mob then
			warn("[CombatService] Failed to spawn mob:", mobType)
			return { Success = false }
		end
	else
		print(`[CombatService] Using existing {mobType} - HP: {mob.CurrentHealth}/{mob.MaxHealth}`)
	end

	-- Calculate damage (including GamePass bonuses)
	local petMultipliers = GetPetMultipliers(playerData)
	local gamePassMultipliers = ProductService.GetGamePassMultipliers(player)
	local isCrit = math.random() < playerData.Stats.CritChance
	local damage = FormulaCalculator.CalculateDamage(
		playerData.Stats.Strength,
		playerData.Progression.RebirthLevel,
		petMultipliers.Damage * gamePassMultipliers.Damage, -- Apply GamePass damage boost
		isCrit,
		playerData.Stats.CritMultiplier,
		weaponMultiplier
	)

	-- Apply damage to mob
	mob.CurrentHealth = math.max(0, mob.CurrentHealth - damage)

	local result = {
		Damage = damage,
		IsCrit = isCrit,
		MobHealth = mob.CurrentHealth,
		MobMaxHealth = mob.MaxHealth,
		MobKilled = mob.CurrentHealth <= 0,
	}

	-- Check if mob is killed
	if mob.CurrentHealth <= 0 then
		-- Calculate rewards
		local mobConfig = MobConfig[mobType]
		local zoneMultiplier = 1.0 -- TODO: Get from ZoneConfig based on current zone

		local xpReward = FormulaCalculator.CalculateXPReward(
			mobConfig.Level,
			zoneMultiplier,
			petMultipliers.XP * gamePassMultipliers.XP, -- Apply GamePass XP boost
			playerData.Progression.RebirthLevel
		)

		local coinReward = FormulaCalculator.CalculateCoinReward(
			mobConfig.Level,
			zoneMultiplier,
			petMultipliers.Coin * gamePassMultipliers.Coins, -- Apply GamePass coin boost
			playerData.Progression.RebirthLevel
		)

		-- Award rewards
		DataService.UpdateData(player, function(data)
			data.Currencies.Coins += coinReward
		end)

		-- Award XP (may trigger level up)
		ProgressionService.AwardExperience(player, xpReward)

		-- Add rewards to result
		result.Rewards = {
			XP = xpReward,
			Coins = coinReward,
		}

		-- Remove killed mob
		if ActiveMobs[player] then
			ActiveMobs[player][mobType] = nil
		end

		-- Replicate updated data to client
		local replicatedData = DataService.GetReplicatedData(player)
		if replicatedData then
			ServerNetworker.ReplicateData(player, replicatedData)
		end

		-- Spawn new mob
		task.delay(1, function()
			CombatService.SpawnMob(player, mobType)
		end)
	end

	return { Success = true, Result = result }
end

-- Setup network handlers
ServerNetworker.Functions.AttackMob.OnServerInvoke = function(player, mobType)
	return CombatService.AttackMob(player, mobType)
end

return CombatService
