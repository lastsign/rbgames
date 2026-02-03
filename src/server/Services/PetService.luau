--!strict
-- PetService.luau
-- Handles pet ownership and equipping

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataService = require(script.Parent.DataService)
local ServerNetworker = require(script.Parent.Parent.Network.ServerNetworker)
local PetConfig = require(ReplicatedStorage.Shared.Config.PetConfig)
local PlayerDataSchema = require(ReplicatedStorage.Shared.Data.PlayerDataSchema)

local PetService = {}

-- Generate unique pet ID
local function GeneratePetID(petType: string): string
	return `{petType}_{os.time()}_{math.random(1000, 9999)}`
end

-- Hatch an egg (gacha system)
function PetService.HatchEgg(player: Player, eggType: string): { Success: boolean, Pet: PlayerDataSchema.Pet?, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	local eggConfig = PetConfig.Eggs[eggType]
	if not eggConfig then
		return { Success = false, Message = "Invalid egg type" }
	end

	-- Check if player has enough currency
	local currency = playerData.Currencies[eggConfig.CostType]
	if not currency or currency < eggConfig.Cost then
		return { Success = false, Message = `Not enough {eggConfig.CostType}` }
	end

	-- Roll for pet from egg pool
	local totalWeight = 0
	local weightedPool: { { Pet: string, Weight: number } } = {}

	for _, petType in eggConfig.PetPool do
		local petData = PetConfig.Pets[petType]
		if petData then
			totalWeight += petData.DropChance
			table.insert(weightedPool, { Pet = petType, Weight = petData.DropChance })
		end
	end

	-- Random selection
	local roll = math.random() * totalWeight
	local currentWeight = 0
	local selectedPet: string? = nil

	for _, entry in weightedPool do
		currentWeight += entry.Weight
		if roll <= currentWeight then
			selectedPet = entry.Pet
			break
		end
	end

	if not selectedPet then
		return { Success = false, Message = "Failed to hatch egg" }
	end

	-- Create pet instance
	local petData = PetConfig.Pets[selectedPet]
	local newPet: PlayerDataSchema.Pet = {
		ID = GeneratePetID(selectedPet),
		Name = petData.Name,
		Rarity = petData.Rarity,
		Bonuses = petData.Bonuses,
	}

	-- Add pet to player inventory
	local success = DataService.UpdateData(player, function(data)
		-- Deduct cost
		data.Currencies[eggConfig.CostType] -= eggConfig.Cost

		-- Add pet
		table.insert(data.Pets.Owned, newPet)
	end)

	if success then
		-- Replicate updated data
		local replicatedData = DataService.GetReplicatedData(player)
		if replicatedData then
			ServerNetworker.ReplicateData(player, replicatedData)
		end

		return { Success = true, Pet = newPet }
	else
		return { Success = false, Message = "Failed to update data" }
	end
end

-- Equip a pet
function PetService.EquipPet(player: Player, petID: string): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	-- Check if player owns the pet
	local ownsPet = false
	for _, pet in playerData.Pets.Owned do
		if pet.ID == petID then
			ownsPet = true
			break
		end
	end

	if not ownsPet then
		return { Success = false, Message = "Pet not owned" }
	end

	-- Check if already equipped
	if table.find(playerData.Pets.Equipped, petID) then
		return { Success = false, Message = "Pet already equipped" }
	end

	-- Check max equipped limit
	if #playerData.Pets.Equipped >= PetConfig.MaxEquipped then
		return { Success = false, Message = `Maximum {PetConfig.MaxEquipped} pets can be equipped` }
	end

	-- Equip pet
	local success = DataService.UpdateData(player, function(data)
		table.insert(data.Pets.Equipped, petID)
	end)

	if success then
		-- Notify client
		ServerNetworker.Events.PetEquipped:FireClient(player, petID, true)

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

-- Unequip a pet
function PetService.UnequipPet(player: Player, petID: string): { Success: boolean, Message: string? }
	local playerData = DataService.GetData(player)
	if not playerData then
		return { Success = false, Message = "Player data not found" }
	end

	-- Check if pet is equipped
	local equippedIndex = table.find(playerData.Pets.Equipped, petID)
	if not equippedIndex then
		return { Success = false, Message = "Pet not equipped" }
	end

	-- Unequip pet
	local success = DataService.UpdateData(player, function(data)
		table.remove(data.Pets.Equipped, equippedIndex)
	end)

	if success then
		-- Notify client
		ServerNetworker.Events.PetEquipped:FireClient(player, petID, false)

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
ServerNetworker.Functions.EquipPet.OnServerInvoke = function(player, petID)
	return PetService.EquipPet(player, petID)
end

ServerNetworker.Functions.UnequipPet.OnServerInvoke = function(player, petID)
	return PetService.UnequipPet(player, petID)
end

return PetService
