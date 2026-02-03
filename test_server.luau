-- Скопируйте в Server Console (F9) для быстрой проверки

-- 1. Проверить что сервис загружен
local ServerScriptService = game:GetService("ServerScriptService")
local serverFolder = ServerScriptService:FindFirstChild("Server")
print("Server folder exists:", serverFolder ~= nil)

if serverFolder then
    print("Server init script:", serverFolder:FindFirstChild("init") ~= nil)
    print("Services folder:", serverFolder:FindFirstChild("Services") ~= nil)
end

-- 2. Проверить ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
print("Packages:", ReplicatedStorage:FindFirstChild("Packages") ~= nil)
print("Shared:", ReplicatedStorage:FindFirstChild("Shared") ~= nil)

-- 3. Проверить мобов
print("Mobs in workspace:", #workspace:FindFirstChild("Mobs"):GetChildren() or 0)

-- 4. Проверить игрока
local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]
if player then
    print("Player found:", player.Name)

    -- Проверить ProfileService
    local success, err = pcall(function()
        local DataService = require(ServerScriptService.Server.Services.DataService)
        local data = DataService.GetData(player)
        print("Player data loaded:", data ~= nil)
        if data then
            print("Level:", data.Progression.Level)
            print("Coins:", data.Currencies.Coins)
        end
    end)

    if not success then
        warn("Error:", err)
    end
end
