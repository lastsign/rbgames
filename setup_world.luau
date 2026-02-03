--!strict
-- setup_world.luau
-- Временный скрипт для создания базового мира
-- Запустите этот код в Command Bar (View → Command Bar)

-- Очистить workspace
game.Workspace:ClearAllChildren()

-- Создать Baseplate
local baseplate = Instance.new("Part")
baseplate.Name = "Baseplate"
baseplate.Size = Vector3.new(512, 1, 512)
baseplate.Position = Vector3.new(0, 0, 0)
baseplate.Anchored = true
baseplate.BrickColor = BrickColor.new("Dark green")
baseplate.Material = Enum.Material.Grass
baseplate.TopSurface = Enum.SurfaceType.Smooth
baseplate.Parent = game.Workspace

-- Создать SpawnLocation
local spawn = Instance.new("SpawnLocation")
spawn.Size = Vector3.new(12, 1, 12)
spawn.Position = Vector3.new(0, 1, 0)
spawn.Anchored = true
spawn.BrickColor = BrickColor.new("Bright blue")
spawn.TopSurface = Enum.SurfaceType.Smooth
spawn.Parent = game.Workspace

-- Добавить свет
local lighting = game:GetService("Lighting")
lighting.Ambient = Color3.fromRGB(70, 70, 70)
lighting.Brightness = 2
lighting.OutdoorAmbient = Color3.fromRGB(70, 70, 70)

print("World setup complete! Now press Play (F5)")
