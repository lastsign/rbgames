-- Скопируйте в Client Console (F9, вкладка Client) для проверки UI

-- 1. Проверить что модули загружены
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

print("PlayerGui exists:", playerGui ~= nil)

-- 2. Проверить UI экраны
local hudScreen = playerGui:FindFirstChild("HUD")
print("HUD Screen:", hudScreen ~= nil)

if hudScreen then
    print("HUD Frame:", hudScreen:FindFirstChild("HUDFrame") ~= nil)
    print("Menu Buttons:", hudScreen:FindFirstChild("MenuButtons") ~= nil)
end

local menuScreen = playerGui:FindFirstChild("Menus")
print("Menu Screen:", menuScreen ~= nil)

if menuScreen then
    print("Shop:", menuScreen:FindFirstChild("ShopFrame") ~= nil)
    print("Zones:", menuScreen:FindFirstChild("ZoneFrame") ~= nil)
    print("Rebirth:", menuScreen:FindFirstChild("RebirthFrame") ~= nil)
end

-- 3. Проверить клиентские скрипты
local StarterPlayer = game:GetService("StarterPlayer")
local scripts = player.PlayerScripts:FindFirstChild("Client")
print("Client scripts loaded:", scripts ~= nil)

-- 4. Проверить NetworkerClient
local ReplicatedStorage = game:GetService("ReplicatedStorage")
print("Packages:", ReplicatedStorage:FindFirstChild("Packages") ~= nil)

if ReplicatedStorage:FindFirstChild("Packages") then
    print("Networker:", ReplicatedStorage.Packages:FindFirstChild("Networker") ~= nil)
    print("Promise:", ReplicatedStorage.Packages:FindFirstChild("Promise") ~= nil)
end

print("\n=== If everything is 'true', the game should work! ===")
