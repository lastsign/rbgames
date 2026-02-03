--!strict
-- UIManager.luau
-- Manages all UI screens and components

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIManager = {}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Store references to UI screens
local screens: { [string]: ScreenGui } = {}
local currentPlayerData: any = nil

-- Create main ScreenGui container
function UIManager.Initialize()
	-- Create HUD container
	local hudScreen = Instance.new("ScreenGui")
	hudScreen.Name = "HUD"
	hudScreen.ResetOnSpawn = false
	hudScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	hudScreen.Parent = playerGui
	screens.HUD = hudScreen

	-- Create Menus container
	local menuScreen = Instance.new("ScreenGui")
	menuScreen.Name = "Menus"
	menuScreen.ResetOnSpawn = false
	menuScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	menuScreen.Parent = playerGui
	screens.Menus = menuScreen

	print("[UIManager] Initialized")
end

-- Update player data cache
function UIManager.UpdatePlayerData(data: any)
	currentPlayerData = data
end

-- Get current player data
function UIManager.GetPlayerData(): any?
	return currentPlayerData
end

-- Get screen by name
function UIManager.GetScreen(name: string): ScreenGui?
	return screens[name]
end

-- Show/hide menu
function UIManager.ToggleMenu(menuName: string, visible: boolean?)
	local menuScreen = screens.Menus
	if not menuScreen then
		return
	end

	local menu = menuScreen:FindFirstChild(menuName)
	if menu and menu:IsA("Frame") then
		if visible == nil then
			menu.Visible = not menu.Visible
		else
			menu.Visible = visible
		end
	end
end

return UIManager
