--!strict
-- ClientNetworker.luau
-- Client-side network interface using standard Roblox RemoteEvents

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientNetworker = {}

-- Wait for RemoteEvents folder
local RemotesFolder = ReplicatedStorage:WaitForChild("RemoteEvents", 10)
local FunctionsFolder = ReplicatedStorage:WaitForChild("RemoteFunctions", 10)

if not RemotesFolder or not FunctionsFolder then
	error("[ClientNetworker] Failed to find remote folders!")
end

-- Helper to get RemoteEvent
local function GetRemoteEvent(name: string): RemoteEvent
	local remote = RemotesFolder:WaitForChild(name, 10) :: RemoteEvent
	if not remote then
		error(`[ClientNetworker] Failed to find RemoteEvent: {name}`)
	end
	return remote
end

-- Helper to get RemoteFunction
local function GetRemoteFunction(name: string): RemoteFunction
	local remote = FunctionsFolder:WaitForChild(name, 10) :: RemoteFunction
	if not remote then
		error(`[ClientNetworker] Failed to find RemoteFunction: {name}`)
	end
	return remote
end

-- Events (listening to server)
ClientNetworker.Events = {
	DataReplicated = GetRemoteEvent("DataReplicated"),
	CombatResult = GetRemoteEvent("CombatResult"),
	LevelUp = GetRemoteEvent("LevelUp"),
	ZoneUnlocked = GetRemoteEvent("ZoneUnlocked"),
	PetEquipped = GetRemoteEvent("PetEquipped"),
	UpgradePurchased = GetRemoteEvent("UpgradePurchased"),
	RebirthCompleted = GetRemoteEvent("RebirthCompleted"),
	DailyRewardClaimed = GetRemoteEvent("DailyRewardClaimed"),
	WeaponEquipped = GetRemoteEvent("WeaponEquipped"),
	WeaponPurchased = GetRemoteEvent("WeaponPurchased"),
}

-- Functions (calling server)
ClientNetworker.Functions = {
	AttackMob = GetRemoteFunction("AttackMob"),
	PurchaseUpgrade = GetRemoteFunction("PurchaseUpgrade"),
	EquipPet = GetRemoteFunction("EquipPet"),
	UnequipPet = GetRemoteFunction("UnequipPet"),
	PerformRebirth = GetRemoteFunction("PerformRebirth"),
	ClaimDailyReward = GetRemoteFunction("ClaimDailyReward"),
	TeleportToZone = GetRemoteFunction("TeleportToZone"),
	PurchaseWeapon = GetRemoteFunction("PurchaseWeapon"),
	EquipWeapon = GetRemoteFunction("EquipWeapon"),
	UnequipWeapon = GetRemoteFunction("UnequipWeapon"),
}

return ClientNetworker
