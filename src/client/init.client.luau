--!strict
-- init.client.luau
-- Client entry point

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientNetworker = require(script.Network.ClientNetworker)
local CombatController = require(script.Controllers.CombatController)
local MobHealthController = require(script.Controllers.MobHealthController)
local UIManager = require(script.UI.UIManager)
local HUD = require(script.UI.Components.HUD)
local MenuButtons = require(script.UI.Components.MenuButtons)
local ShopScreen = require(script.UI.Screens.ShopScreen)
local ZoneScreen = require(script.UI.Screens.ZoneScreen)
local RebirthScreen = require(script.UI.Screens.RebirthScreen)
local WeaponShopScreen = require(script.UI.Screens.WeaponShopScreen)
local RobuxShopScreen = require(script.UI.Screens.RobuxShopScreen)

local player = Players.LocalPlayer

print("[Client] RPG Game initializing...")

-- Initialize UI
UIManager.Initialize()
HUD.Create()
MenuButtons.Create()
ShopScreen.Create()
ZoneScreen.Create()
RebirthScreen.Create()
WeaponShopScreen.Create()
RobuxShopScreen.Create()

-- Initialize controllers
MobHealthController.Initialize()

-- Listen for data replication from server
ClientNetworker.Events.DataReplicated.OnClientEvent:Connect(function(data)
	print("[Client] Received player data")

	-- Update all systems with new data
	UIManager.UpdatePlayerData(data)
	CombatController.UpdatePlayerData(data)
	HUD.Update(data)
	ShopScreen.Update(data)
	ZoneScreen.Update(data)
	RebirthScreen.Update(data)
	WeaponShopScreen.Update(data)
end)

-- Listen for combat results
ClientNetworker.Events.CombatResult.OnClientEvent:Connect(function(result)
	CombatController.ShowCombatResult(result)
end)

-- Listen for level up
ClientNetworker.Events.LevelUp.OnClientEvent:Connect(function(newLevel, statIncreases)
	print(`[Client] Level up! New level: {newLevel}`)
	HUD.ShowLevelUp(newLevel)
end)

-- Listen for zone unlocked
ClientNetworker.Events.ZoneUnlocked.OnClientEvent:Connect(function(zoneName)
	print(`[Client] Zone unlocked: {zoneName}`)
	-- TODO: Show unlock notification
end)

-- Listen for daily reward claimed
ClientNetworker.Events.DailyRewardClaimed.OnClientEvent:Connect(function(rewardData)
	print(`[Client] Daily reward claimed! Streak: {rewardData.Streak}`)
	-- TODO: Show reward UI
end)

-- Wait for character
player.CharacterAdded:Connect(function(character)
	print("[Client] Character spawned")
	CombatController.SetupCharacter(character)
end)

if player.Character then
	CombatController.SetupCharacter(player.Character)
end

print("[Client] RPG Game initialized!")
