--!strict
-- WeaponService.luau
-- Handles weapon purchase, equip, and management

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local DataService = require(script.Parent.DataService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local WeaponConfig = require(ReplicatedStorage.Shared.Config.WeaponConfig)

local WeaponService = {}

-- Generate unique weapon instance ID
local function GenerateWeaponID(weaponType: string): string
	return `{weaponType}_{HttpService:GenerateGUID(false)}`
end

-- Check if player owns a weapon type
local function PlayerOwnsWeaponType(playerData: any, weaponType: string): boolean
	for _, weapon in playerData.Weapons.Owned do
		if weapon.WeaponType == weaponType then
			return true
		end
	end
	return false
end

-- Get weapon instance by ID
local function GetWeaponByID(playerData: any, weaponID: string): any?
	for _, weapon in playerData.Weapons.Owned do
		if weapon.ID == weaponID then
			return weapon
		end
	end
	return nil
end

-- Purchase a weapon
function WeaponService.PurchaseWeapon(player: Player, weaponType: string): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	-- Validate weapon exists
	local weaponData = WeaponConfig.GetWeapon(weaponType)
	if not weaponData then
		return { Success = false, Message = "Invalid weapon type" }
	end

	-- Check if already owned
	if PlayerOwnsWeaponType(playerData, weaponType) then
		return { Success = false, Message = "You already own this weapon" }
	end

	-- Check level requirement
	if weaponData.RequiredLevel and playerData.Progression.Level < weaponData.RequiredLevel then
		return { Success = false, Message = `Requires level {weaponData.RequiredLevel}` }
	end

	-- Check currency
	local currencyKey = weaponData.CostType
	if playerData.Currencies[currencyKey] < weaponData.Cost then
		return { Success = false, Message = `Not enough {currencyKey}` }
	end

	-- Deduct cost and add weapon
	DataService.UpdateData(player, function(data)
		data.Currencies[currencyKey] -= weaponData.Cost

		local newWeapon = {
			ID = GenerateWeaponID(weaponType),
			WeaponType = weaponType,
			AcquiredAt = os.time(),
		}
		table.insert(data.Weapons.Owned, newWeapon)
	end)

	-- Notify client
	ServerNetworker.Events.WeaponPurchased:FireClient(player, weaponType)

	-- Replicate updated data
	local replicatedData = DataService.GetReplicatedData(player)
	if replicatedData then
		ServerNetworker.ReplicateData(player, replicatedData)
	end

	print(`[WeaponService] {player.Name} purchased {weaponType}`)
	return { Success = true }
end

-- Equip a weapon by ID
function WeaponService.EquipWeapon(player: Player, weaponID: string): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	-- Validate ownership
	local weapon = GetWeaponByID(playerData, weaponID)
	if not weapon then
		return { Success = false, Message = "You don't own this weapon" }
	end

	-- Equip weapon
	DataService.UpdateData(player, function(data)
		data.Weapons.Equipped = weaponID
	end)

	-- Notify client
	ServerNetworker.Events.WeaponEquipped:FireClient(player, weaponID)

	-- Replicate updated data
	local replicatedData = DataService.GetReplicatedData(player)
	if replicatedData then
		ServerNetworker.ReplicateData(player, replicatedData)
	end

	print(`[WeaponService] {player.Name} equipped weapon {weaponID}`)
	return { Success = true }
end

-- Unequip current weapon
function WeaponService.UnequipWeapon(player: Player): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	-- Clear equipped
	DataService.UpdateData(player, function(data)
		data.Weapons.Equipped = nil
	end)

	-- Replicate updated data
	local replicatedData = DataService.GetReplicatedData(player)
	if replicatedData then
		ServerNetworker.ReplicateData(player, replicatedData)
	end

	print(`[WeaponService] {player.Name} unequipped weapon`)
	return { Success = true }
end

-- Get equipped weapon data for combat calculations
function WeaponService.GetEquippedWeaponData(player: Player): WeaponConfig.WeaponData?
	local playerData = DataService.GetData(player)
	if not playerData or not playerData.Weapons.Equipped then
		return nil
	end

	local equippedWeapon = GetWeaponByID(playerData, playerData.Weapons.Equipped)
	if not equippedWeapon then
		return nil
	end

	return WeaponConfig.GetWeapon(equippedWeapon.WeaponType)
end

-- Setup network handlers
ServerNetworker.Functions.PurchaseWeapon.OnServerInvoke = function(player, weaponType)
	return WeaponService.PurchaseWeapon(player, weaponType)
end

ServerNetworker.Functions.EquipWeapon.OnServerInvoke = function(player, weaponID)
	return WeaponService.EquipWeapon(player, weaponID)
end

ServerNetworker.Functions.UnequipWeapon.OnServerInvoke = function(player)
	return WeaponService.UnequipWeapon(player)
end

return WeaponService
