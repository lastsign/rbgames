--!strict
-- ServerNetworker.luau
-- Server-side network API using standard Roblox RemoteEvents

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerNetworker = {}

-- Create RemoteEvents folder
local RemotesFolder = ReplicatedStorage:FindFirstChild("RemoteEvents")
if not RemotesFolder then
	RemotesFolder = Instance.new("Folder")
	RemotesFolder.Name = "RemoteEvents"
	RemotesFolder.Parent = ReplicatedStorage
end

-- Create RemoteFunctions folder
local FunctionsFolder = ReplicatedStorage:FindFirstChild("RemoteFunctions")
if not FunctionsFolder then
	FunctionsFolder = Instance.new("Folder")
	FunctionsFolder.Name = "RemoteFunctions"
	FunctionsFolder.Parent = ReplicatedStorage
end

-- Helper to create RemoteEvent
local function CreateRemoteEvent(name: string): RemoteEvent
	local existing = RemotesFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = RemotesFolder
	return remote
end

-- Helper to create RemoteFunction
local function CreateRemoteFunction(name: string): RemoteFunction
	local existing = FunctionsFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteFunction") then
		return existing
	end

	local remote = Instance.new("RemoteFunction")
	remote.Name = name
	remote.Parent = FunctionsFolder
	return remote
end

-- Events (server to client)
ServerNetworker.Events = {
	DataReplicated = CreateRemoteEvent("DataReplicated"),
	CombatResult = CreateRemoteEvent("CombatResult"),
	LevelUp = CreateRemoteEvent("LevelUp"),
	ZoneUnlocked = CreateRemoteEvent("ZoneUnlocked"),
	PetEquipped = CreateRemoteEvent("PetEquipped"),
	UpgradePurchased = CreateRemoteEvent("UpgradePurchased"),
	RebirthCompleted = CreateRemoteEvent("RebirthCompleted"),
	DailyRewardClaimed = CreateRemoteEvent("DailyRewardClaimed"),
	WeaponEquipped = CreateRemoteEvent("WeaponEquipped"),
	WeaponPurchased = CreateRemoteEvent("WeaponPurchased"),
}

-- Functions (client to server, with return values)
ServerNetworker.Functions = {
	AttackMob = CreateRemoteFunction("AttackMob"),
	PurchaseUpgrade = CreateRemoteFunction("PurchaseUpgrade"),
	EquipPet = CreateRemoteFunction("EquipPet"),
	UnequipPet = CreateRemoteFunction("UnequipPet"),
	PerformRebirth = CreateRemoteFunction("PerformRebirth"),
	ClaimDailyReward = CreateRemoteFunction("ClaimDailyReward"),
	TeleportToZone = CreateRemoteFunction("TeleportToZone"),
	PurchaseWeapon = CreateRemoteFunction("PurchaseWeapon"),
	EquipWeapon = CreateRemoteFunction("EquipWeapon"),
	UnequipWeapon = CreateRemoteFunction("UnequipWeapon"),
}

-- Utility: Send data update to client
function ServerNetworker.ReplicateData(player: Player, data: any)
	ServerNetworker.Events.DataReplicated:FireClient(player, data)
end

-- Utility: Broadcast combat result
function ServerNetworker.SendCombatResult(player: Player, result: any)
	ServerNetworker.Events.CombatResult:FireClient(player, result)
end

-- Utility: Notify level up
function ServerNetworker.NotifyLevelUp(player: Player, newLevel: number, statIncreases: any)
	ServerNetworker.Events.LevelUp:FireClient(player, newLevel, statIncreases)
end

-- Utility: Notify zone unlocked
function ServerNetworker.NotifyZoneUnlocked(player: Player, zoneName: string)
	ServerNetworker.Events.ZoneUnlocked:FireClient(player, zoneName)
end

return ServerNetworker
