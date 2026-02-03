--!strict
-- CombatController.luau
-- Client-side combat interface with melee auto-targeting

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientNetworker = require(script.Parent.Parent.Network.ClientNetworker)
local DamageNumbers = require(script.Parent.Parent.UI.Components.DamageNumbers)
local MobHealthController = require(script.Parent.MobHealthController)
local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)

local CombatController = {}

local player = Players.LocalPlayer
local playerData: any = nil
local currentTarget: Instance? = nil
local lastAttackTime: number = 0

-- Update player data cache
function CombatController.UpdatePlayerData(data: any)
	playerData = data
	print(`[CombatController] Player data updated - Level: {data.Progression.Level}, Strength: {data.Stats.Strength}`)
end

-- Get equipped weapon config from player data
local function GetEquippedWeaponConfig(): WeaponConfig.WeaponData?
	if not playerData or not playerData.Weapons or not playerData.Weapons.Equipped then
		return nil
	end

	-- Find equipped weapon in owned list
	for _, weapon in playerData.Weapons.Owned do
		if weapon.ID == playerData.Weapons.Equipped then
			return WeaponConfig.GetWeapon(weapon.WeaponType)
		end
	end

	return nil
end

-- Get attack cooldown based on weapon
local function GetAttackCooldown(): number
	local weaponData = GetEquippedWeaponConfig()
	if weaponData then
		return 1 / weaponData.AttackSpeed
	end
	return 0.67 -- Default: 1.5 attacks per second
end

-- Get attack range based on weapon
local function GetAttackRange(): number
	local weaponData = GetEquippedWeaponConfig()
	if weaponData then
		return weaponData.AttackRange
	end
	return 8 -- Default range
end

-- Find closest mob within attack range
local function FindClosestMobInRange(): (Model?, number)
	local character = player.Character
	if not character then
		return nil, math.huge
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not humanoidRootPart then
		return nil, math.huge
	end

	local playerPosition = humanoidRootPart.Position
	local attackRange = GetAttackRange()
	local closestMob: Model? = nil
	local closestDistance = math.huge

	local mobsFolder = workspace:FindFirstChild("Mobs")
	if not mobsFolder then
		return nil, math.huge
	end

	for _, mob in mobsFolder:GetChildren() do
		if not mob:IsA("Model") then
			continue
		end

		-- Check if mob has MobType identifier
		local mobType = mob:FindFirstChild("MobType")
		if not mobType or not mobType:IsA("StringValue") then
			continue
		end

		-- Get mob position
		local mobBody = mob:FindFirstChild("MobBody") :: BasePart?
		local mobPosition: Vector3
		if mobBody then
			mobPosition = mobBody.Position
		elseif mob.PrimaryPart then
			mobPosition = mob.PrimaryPart.Position
		else
			continue
		end

		-- Calculate distance
		local distance = (mobPosition - playerPosition).Magnitude

		-- Check if within range and closer than current closest
		if distance <= attackRange and distance < closestDistance then
			closestMob = mob
			closestDistance = distance
		end
	end

	return closestMob, closestDistance
end

-- Show attack swing effect
local function ShowAttackEffect()
	local character = player.Character
	if not character then
		return
	end

	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
	if not humanoidRootPart then
		return
	end

	-- Create swing effect
	local effect = Instance.new("Part")
	effect.Name = "SwingEffect"
	effect.Size = Vector3.new(0.2, 0.2, GetAttackRange())
	effect.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, -GetAttackRange() / 2)
	effect.Anchored = true
	effect.CanCollide = false
	effect.Transparency = 0.5
	effect.Material = Enum.Material.Neon

	-- Color based on weapon rarity
	local weaponData = GetEquippedWeaponConfig()
	if weaponData then
		effect.Color = WeaponConfig.RarityColors[weaponData.Rarity] or Color3.fromRGB(255, 255, 255)
	else
		effect.Color = Color3.fromRGB(200, 200, 200)
	end

	effect.Parent = workspace

	-- Animate and remove
	task.spawn(function()
		for i = 1, 5 do
			effect.Transparency = 0.5 + (i * 0.1)
			task.wait(0.02)
		end
		effect:Destroy()
	end)
end

-- Try to attack (main function)
local function TryAttack()
	-- Check cooldown
	local currentTime = tick()
	local cooldown = GetAttackCooldown()
	if currentTime - lastAttackTime < cooldown then
		return
	end

	-- Find closest mob in range
	local closestMob, distance = FindClosestMobInRange()

	-- Show attack effect regardless
	ShowAttackEffect()

	-- If no mob in range, just show the swing
	if not closestMob then
		print("[CombatController] No mob in range")
		return
	end

	-- Update last attack time
	lastAttackTime = currentTime
	currentTarget = closestMob

	-- Get mob type from model
	local mobTypeValue = closestMob:FindFirstChild("MobType")
	if not mobTypeValue or not mobTypeValue:IsA("StringValue") then
		return
	end

	local mobType = mobTypeValue.Value
	print(`[CombatController] Attacking {mobType} at distance {string.format("%.1f", distance)} studs`)

	-- Call server
	local result = ClientNetworker.Functions.AttackMob:InvokeServer(mobType)

	if result and result.Success and result.Result then
		CombatController.ShowCombatResult(result.Result)
	elseif result and result.Message then
		warn(`[CombatController] Attack failed: {result.Message}`)
	end
end

-- Setup character for combat
function CombatController.SetupCharacter(character: Model)
	print("[CombatController] Setting up character")

	-- Setup click-anywhere-to-attack using UserInputService
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			TryAttack()
		end
	end)
end

-- Show combat result (damage numbers, etc.)
function CombatController.ShowCombatResult(result: any)
	print(`[Combat] Dealt {result.Damage} damage{if result.IsCrit then " (CRIT!)" else ""}`)

	if result.MobKilled and result.Rewards then
		print(`[Combat] Mob killed! +{result.Rewards.XP} XP, +{result.Rewards.Coins} Coins`)
	end

	-- Show damage numbers and update health bar on target mob
	if currentTarget and currentTarget.Parent then
		local position: Vector3
		local mobModel: Model?

		if currentTarget:IsA("BasePart") then
			position = currentTarget.Position
			mobModel = currentTarget.Parent :: Model
		elseif currentTarget:IsA("Model") then
			position = currentTarget:GetPivot().Position
			mobModel = currentTarget
		else
			position = Vector3.new(0, 0, 0)
		end

		-- Show floating damage number
		DamageNumbers.Show(result.Damage, position, result.IsCrit)

		-- Update mob health bar
		if mobModel and mobModel:IsA("Model") then
			MobHealthController.UpdateMobHealthBar(mobModel, result.MobHealth, result.MobMaxHealth)

			-- Show death effect if killed
			if result.MobKilled then
				MobHealthController.ShowMobDeath(mobModel, result.MobMaxHealth)
			end
		end
	end
end

-- Get current weapon info for UI
function CombatController.GetCurrentWeaponInfo(): { Name: string, Range: number, Speed: number, Multiplier: number }?
	local weaponData = GetEquippedWeaponConfig()
	if weaponData then
		return {
			Name = weaponData.DisplayName,
			Range = weaponData.AttackRange,
			Speed = weaponData.AttackSpeed,
			Multiplier = weaponData.DamageMultiplier,
		}
	end
	return nil
end

return CombatController
